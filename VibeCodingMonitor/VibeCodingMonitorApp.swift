import SwiftUI
import AppKit

@main
struct VibeCodingMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var monitor = StatusMonitor()
    @StateObject private var windowMode = WindowModeManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(monitor)
                .environmentObject(windowMode)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 360, height: 280)

        MenuBarExtra("Vibe Coding", systemImage: menuBarIcon) {
            MenuBarContent()
                .environmentObject(monitor)
                .environmentObject(windowMode)
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarIcon: String {
        switch monitor.snapshot.status {
        case .idle: return "circle.fill"
        case .thinking: return "brain.head.profile"
        case .executing: return "chevron.left.forwardslash.chevron.right"
        case .processing: return "hourglass"
        case .error: return "exclamationmark.triangle.fill"
        case .waiting: return "hand.raised.fill"
        }
    }
}

private struct MenuBarContent: View {
    @EnvironmentObject private var monitor: StatusMonitor
    @EnvironmentObject private var windowMode: WindowModeManager

    var body: some View {
        VStack(spacing: 14) {
            StatusLightView(status: monitor.snapshot.status, size: 48)

            Text(monitor.snapshot.status.label)
                .font(.headline)

            Text(monitor.snapshot.status.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Divider()

            Button(windowMode.mode == .floating ? "标准窗口" : "悬浮窗模式") {
                windowMode.toggle()
                activateMainWindow()
            }

            Button("打开主窗口") {
                activateMainWindow()
            }

            Button("退出") {
                NSApp.terminate(nil)
            }
        }
        .padding()
        .frame(width: 220)
    }

    private func activateMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows where window.canBecomeMain {
            window.makeKeyAndOrderFront(nil)
            break
        }
    }
}
