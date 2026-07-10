// SPDX-FileCopyrightText: 2026 Wuhan Yilihua Software Development Co., Ltd. <yilihuasoftware@outlook.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var monitor: StatusMonitor
    @EnvironmentObject private var windowMode: WindowModeManager

    var body: some View {
        VStack(spacing: 18) {
            StatusLightView(status: monitor.snapshot.status, size: 72)

            VStack(spacing: 6) {
                Text(monitor.snapshot.status.label)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))

                Text(monitor.snapshot.status.detail)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Text(monitor.snapshot.message ?? "")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 32)
                    .opacity(
                        (monitor.snapshot.message?.isEmpty == false) ? 1 : 0
                    )
            }

            HStack(spacing: 6) {
                Circle()
                    .fill(monitor.isConnected ? Color.green : Color.orange)
                    .frame(width: 7, height: 7)
                Text(monitor.isConnected ? "已连接 Cursor Hooks" : "等待 Hooks 信号")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)

            Button {
                windowMode.mode = .floating
            } label: {
                Label("悬浮窗模式", systemImage: "pip.enter")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .padding(.top, 8)

            VStack(spacing: 2) {
                Text("© 2026 Wuhan Yilihua Software Development Co., Ltd.")
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("All rights reserved.")
            }
            .font(.caption2)
            .foregroundStyle(.quaternary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
        .padding(24)
        .frame(width: 360)
    }
}

#Preview {
    ContentView()
        .environmentObject(StatusMonitor())
        .environmentObject(WindowModeManager())
}
