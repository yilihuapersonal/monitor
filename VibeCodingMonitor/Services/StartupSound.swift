import AVFoundation

enum StartupSound {
    private static var player: AVAudioPlayer?

    static func play() {
        guard let url = Bundle.main.url(forResource: "startup", withExtension: "mp3"),
              let audioPlayer = try? AVAudioPlayer(contentsOf: url)
        else {
            return
        }

        player = audioPlayer
        audioPlayer.volume = 1.0
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
}
