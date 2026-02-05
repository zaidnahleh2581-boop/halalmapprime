//
//  AdhanAudioManager.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 2/5/26.
//

import AVFoundation

final class AdhanAudioManager {

    static let shared = AdhanAudioManager()
    private var player: AVAudioPlayer?

    private init() {}

    func playAdhan() {
        guard let url = Bundle.main.url(forResource: "adhan", withExtension: "mp3")
            ?? Bundle.main.url(forResource: "adhan", withExtension: "wav") else {
            print("❌ Adhan sound file not found in bundle")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
            print("✅ Adhan playing")
        } catch {
            print("❌ Failed to play adhan:", error)
        }
    }

    func stop() {
        player?.stop()
    }
}
