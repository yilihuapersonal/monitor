import Foundation
import Combine

@MainActor
final class StatusMonitor: ObservableObject {
    @Published private(set) var snapshot: StatusSnapshot = .default
    @Published private(set) var isConnected = false

    private var fileDescriptor: Int32 = -1
    private var source: DispatchSourceFileSystemObject?
    private var staleTimer: Timer?
    private var hasLoadedInitialStatus = false

    static let statusDirectory: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("VibeCodingMonitor", isDirectory: true)
    }()

    static let statusFileURL: URL = statusDirectory.appendingPathComponent("status.json")

    init() {
        ensureDirectoryExists()
        readStatus()
        startWatching()
        startStaleCheck()
    }

    deinit {
        staleTimer?.invalidate()
        source?.cancel()
        source = nil
    }

    private func ensureDirectoryExists() {
        try? FileManager.default.createDirectory(
            at: Self.statusDirectory,
            withIntermediateDirectories: true
        )
    }

    private func startWatching() {
        let path = Self.statusFileURL.path
        if !FileManager.default.fileExists(atPath: path) {
            writeDefaultStatus()
        }

        fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor >= 0 else { return }

        let dispatchSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .rename, .delete, .attrib],
            queue: .main
        )

        dispatchSource.setEventHandler { [weak self] in
            Task { @MainActor in
                self?.readStatus()
            }
        }

        dispatchSource.setCancelHandler { [weak self] in
            guard let self else { return }
            if self.fileDescriptor >= 0 {
                close(self.fileDescriptor)
                self.fileDescriptor = -1
            }
        }

        source = dispatchSource
        dispatchSource.resume()
    }

    private func startStaleCheck() {
        staleTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.readStatus()
                self?.checkConnection()
            }
        }
    }

    private func checkConnection() {
        let age = Date().timeIntervalSince1970 - snapshot.timestamp
        isConnected = age < 120
    }

    private func writeDefaultStatus() {
        let data = (try? JSONEncoder().encode(StatusSnapshot.default)) ?? Data()
        try? data.write(to: Self.statusFileURL, options: .atomic)
    }

    func readStatus() {
        guard let data = try? Data(contentsOf: Self.statusFileURL),
              let decoded = try? JSONDecoder().decode(StatusSnapshot.self, from: data)
        else {
            return
        }

        let previousStatus = snapshot.status
        let wasConnected = isConnected

        snapshot = decoded
        checkConnection()

        guard hasLoadedInitialStatus else {
            hasLoadedInitialStatus = true
            return
        }

        if isConnected && !wasConnected {
            StartupSound.play()
        }

        if decoded.status != previousStatus {
            if decoded.status == .idle {
                StatusSound.beepThrice()
            } else {
                StatusSound.beepTwice()
            }
        }
    }
}
