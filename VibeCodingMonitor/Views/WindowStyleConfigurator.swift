import SwiftUI
import AppKit

struct WindowStyleConfigurator: NSViewRepresentable {
    @EnvironmentObject private var windowMode: WindowModeManager

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                applyStyle(to: window, mode: windowMode.mode)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                applyStyle(to: window, mode: windowMode.mode)
            }
        }
    }

    private func applyStyle(to window: NSWindow, mode: WindowMode) {
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden

        switch mode {
        case .floating:
            window.styleMask = [.borderless, .fullSizeContentView]
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            if window.frame.size != NSSize(width: 80, height: 80) {
                window.setContentSize(NSSize(width: 80, height: 80))
            }
        case .standard:
            window.styleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView]
            window.isOpaque = true
            window.backgroundColor = .windowBackgroundColor
            window.hasShadow = true
            window.standardWindowButton(.closeButton)?.isHidden = false
            window.standardWindowButton(.miniaturizeButton)?.isHidden = false
            window.standardWindowButton(.zoomButton)?.isHidden = false
            if window.frame.size != NSSize(width: 360, height: 280) {
                window.setContentSize(NSSize(width: 360, height: 280))
            }
        }
    }
}
