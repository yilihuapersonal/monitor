// SPDX-FileCopyrightText: 2026 Wuhan Yilihua Software Development Co., Ltd. <yilihuasoftware@outlook.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

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

        let contentRect = window.contentRect(forFrameRect: window.frame)
        let center = NSPoint(x: contentRect.midX, y: contentRect.midY)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0
            context.allowsImplicitAnimation = false

            switch mode {
            case .floating:
                window.styleMask = [.borderless, .fullSizeContentView]
                window.isOpaque = false
                window.backgroundColor = .clear
                window.hasShadow = false
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
                setContentSize(NSSize(width: 100, height: 100), centeredAt: center, in: window)
            case .standard:
                window.styleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView]
                window.isOpaque = true
                window.backgroundColor = .windowBackgroundColor
                window.hasShadow = true
                window.standardWindowButton(.closeButton)?.isHidden = false
                window.standardWindowButton(.miniaturizeButton)?.isHidden = false
                window.standardWindowButton(.zoomButton)?.isHidden = false
                setContentSize(NSSize(width: 360, height: 280), centeredAt: center, in: window)
            }
        }

        // SwiftUI may resize again after this pass; clamp once more on the next turn.
        DispatchQueue.main.async {
            self.ensureOnScreen(window)
        }
    }

    private func setContentSize(_ size: NSSize, centeredAt center: NSPoint, in window: NSWindow) {
        let current = window.contentRect(forFrameRect: window.frame).size
        if abs(current.width - size.width) > 0.5 || abs(current.height - size.height) > 0.5 {
            var contentRect = NSRect(origin: .zero, size: size)
            contentRect.origin.x = round(center.x - size.width / 2)
            contentRect.origin.y = round(center.y - size.height / 2)
            window.setFrame(window.frameRect(forContentRect: contentRect), display: false, animate: false)
        }
        ensureOnScreen(window)
    }

    /// Pull the window fully into the visible desktop area (avoids Dock / menu bar / screen edges).
    private func ensureOnScreen(_ window: NSWindow) {
        guard let screen = screen(for: window) else { return }

        var frame = window.constrainFrameRect(window.frame, to: screen)
        let visible = screen.visibleFrame

        if frame.width > visible.width {
            frame.size.width = visible.width
            frame.origin.x = visible.minX
        } else {
            frame.origin.x = min(max(frame.origin.x, visible.minX), visible.maxX - frame.width)
        }

        if frame.height > visible.height {
            frame.size.height = visible.height
            frame.origin.y = visible.minY
        } else {
            frame.origin.y = min(max(frame.origin.y, visible.minY), visible.maxY - frame.height)
        }

        frame.origin.x = round(frame.origin.x)
        frame.origin.y = round(frame.origin.y)

        guard !NSEqualRects(frame, window.frame) else { return }
        window.setFrame(frame, display: true, animate: false)
    }

    private func screen(for window: NSWindow) -> NSScreen? {
        let frame = window.frame
        let center = NSPoint(x: frame.midX, y: frame.midY)
        if let match = NSScreen.screens.first(where: { NSMouseInRect(center, $0.frame, false) }) {
            return match
        }
        return window.screen
            ?? NSScreen.screens.max(by: { lhs, rhs in
                lhs.frame.intersection(frame).area < rhs.frame.intersection(frame).area
            })
            ?? NSScreen.main
    }
}

private extension NSRect {
    var area: CGFloat { max(0, width) * max(0, height) }
}
