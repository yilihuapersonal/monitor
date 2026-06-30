// SPDX-FileCopyrightText: 2026 Wuhan Yilihua Software Development Co., Ltd. <yilihuasoftware@outlook.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import AVFoundation
import AudioToolbox

enum StatusSound {
    private static let soundURL = URL(fileURLWithPath: "/System/Library/Sounds/Ping.aiff")
    private static var activePlayers: [AVAudioPlayer] = []

    static func prepare() {
        _ = makePlayer()
    }

    static func beepTwice() {
        beep(count: 2, interval: 0.3)
    }

    static func beepThrice() {
        beep(count: 3, interval: 0.3)
    }

    private static func beep(count: Int, interval: TimeInterval) {
        for index in 0..<count {
            let delay = TimeInterval(index) * interval
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                play()
            }
        }
    }

    private static func play() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_UserPreferredAlert))

        guard let player = makePlayer() else { return }
        player.volume = 1.0
        player.prepareToPlay()
        player.play()

        activePlayers.append(player)
        activePlayers.removeAll { !$0.isPlaying }
    }

    private static func makePlayer() -> AVAudioPlayer? {
        try? AVAudioPlayer(contentsOf: soundURL)
    }
}
