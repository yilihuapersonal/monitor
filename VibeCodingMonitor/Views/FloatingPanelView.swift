// SPDX-FileCopyrightText: 2026 Wuhan Yilihua Software Development Co., Ltd. <yilihuasoftware@outlook.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI
import AppKit

struct FloatingPanelView: View {
    @EnvironmentObject private var monitor: StatusMonitor
    @EnvironmentObject private var windowMode: WindowModeManager

    @State private var isHovering = false

    var body: some View {
        ZStack {
            if isHovering {
                Text(monitor.snapshot.status.label)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .offset(y: 38)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }

            StatusLightView(status: monitor.snapshot.status, size: 48)
        }
        .frame(width: 80, height: 80)
        .background {
            Circle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
        }
        .onHover { isHovering = $0 }
        .help("\(monitor.snapshot.status.label) — \(monitor.snapshot.status.detail)")
        .contextMenu {
            Button("标准窗口") {
                windowMode.mode = .standard
            }
            Divider()
            Button("退出") {
                NSApp.terminate(nil)
            }
        }
        .onTapGesture(count: 2) {
            windowMode.mode = .standard
        }
    }
}

#Preview {
    FloatingPanelView()
        .environmentObject(StatusMonitor())
        .environmentObject(WindowModeManager())
        .padding()
        .background(Color.gray.opacity(0.3))
}
