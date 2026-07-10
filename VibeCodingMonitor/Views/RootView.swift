// SPDX-FileCopyrightText: 2026 Wuhan Yilihua Software Development Co., Ltd. <yilihuasoftware@outlook.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var windowMode: WindowModeManager

    var body: some View {
        Group {
            switch windowMode.mode {
            case .floating:
                FloatingPanelView()
            case .standard:
                ContentView()
            }
        }
        .background(WindowStyleConfigurator())
        .animation(nil, value: windowMode.mode)
    }
}
