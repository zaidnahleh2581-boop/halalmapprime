//
//  AdhanPlayer.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/11/26.
//

import Foundation
import AVFoundation

@MainActor
final class AdhanPlayer {

    static let shared = AdhanPlayer()

    private var player: AVAudioPlayer?

    private init() {}

    func play() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)

            guard let url = Bundle.main.url(forResource: "adhan", withExtension: "caf") else {
                print("❌ adhan.caf not found")
                return
            }

            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()

            print("✅ Adhan playing")

        } catch {
            print("❌ Adhan error:", error.localizedDescription)
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}
