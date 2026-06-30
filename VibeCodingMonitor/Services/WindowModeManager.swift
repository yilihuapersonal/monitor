// SPDX-FileCopyrightText: 2026 Wuhan Yilihua Software Development Co., Ltd. <yilihuasoftware@outlook.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

enum WindowMode: String, CaseIterable {
    case standard
    case floating

    var label: String {
        switch self {
        case .standard: return "标准窗口"
        case .floating: return "悬浮窗"
        }
    }
}

@MainActor
final class WindowModeManager: ObservableObject {
    private static let storageKey = "windowMode"

    @Published var mode: WindowMode {
        didSet {
            UserDefaults.standard.set(mode.rawValue, forKey: Self.storageKey)
        }
    }

    init() {
        let raw = UserDefaults.standard.string(forKey: Self.storageKey) ?? WindowMode.standard.rawValue
        mode = WindowMode(rawValue: raw) ?? .standard
    }

    func toggle() {
        mode = mode == .standard ? .floating : .standard
    }
}
