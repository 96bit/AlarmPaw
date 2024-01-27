//
//  audioManager.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/24.
//

import Foundation
import AVFoundation

class AudioPlayerManager: ObservableObject {
    @Published var currentlyPlayingURL: URL?
    private var audioPlayer: AVAudioPlayer?
    
    func togglePlay(audioURL: URL) {
        if let currentlyPlayingURL = currentlyPlayingURL, currentlyPlayingURL == audioURL {
            stop()
        } else {
            play(audioURL)
        }
    }
    
    private func play(_ audioURL: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.play()
            currentlyPlayingURL = audioURL
        } catch {
            print("playFail: \(error)")
        }
    }
    
    private func stop() {
        audioPlayer?.stop()
        currentlyPlayingURL = nil
    }
}
