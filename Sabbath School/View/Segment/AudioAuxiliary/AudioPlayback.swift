/*
 * Copyright (c) 2024 Adventech <info@adventech.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import AVFoundation
import SwiftAudioEx
import MediaPlayer

extension Audio {
    func audioItem() -> AudioItem {
        return DefaultAudioItem(
            audioUrl: self.src.absoluteString,
            artist: self.artist,
            title: self.title,
            sourceType: .stream
        )
    }
}

enum PlaybackRate {
    case slow
    case normal
    case fast
    case fastest
    
    var val: Float {
        switch self {
        case .slow: return 0.75
        case .normal: return 1
        case .fast: return 1.5
        case .fastest: return 2
        }
    }
    
    var label: String {
        switch self {
        case .slow: return "¾×"
        case .normal: return "1×"
        case .fast: return "1½×"
        case .fastest: return "2×"
        }
    }
}

class AudioPlayback: ObservableObject {
    let player = QueuedAudioPlayer()
    
    @Published var documentIndex: String? = nil
    @Published var state: AudioPlayerState = .idle
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isScrubbing = false
    @Published var rate: PlaybackRate = .normal
    
    init () {
        player.event.stateChange.addListener(self, updatePlayPauseState)
        player.event.updateDuration.addListener(self, handleAudioPlayerUpdateDuration)
        player.event.secondElapse.addListener(self, handleAudioPlayerSecondElapsed)
        
        try? AVAudioSession.sharedInstance().setMode(.default)
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
        
        player.remoteCommands = [
            .play,
            .pause,
            .next,
            .skipForward(preferredIntervals: [30]),
            .skipBackward(preferredIntervals: [15]),
            .changePlaybackPosition
        ]
    }
    
    func handleAudioPlayerSecondElapsed(data: AudioPlayer.SecondElapseEventData) {
        if isScrubbing { return }
        DispatchQueue.main.async {
            self.currentTime = self.player.currentTime
        }
    }
    
    func handleAudioPlayerUpdateDuration(data: AudioPlayer.UpdateDurationEventData) {
        if isScrubbing { return }
        DispatchQueue.main.async {
            self.duration = self.player.duration
        }
    }
    
    func updatePlayPauseState(state: AudioPlayerState) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
    
    func play() {
        if player.nextItems.count == 0 && player.currentTime == player.duration {
            player.seek(to: 0)
        }
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.stop()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    func togglePlay() {
        if state == .playing {
            pause()
        } else {
            play()
        }
    }
    
    func shouldShowMiniPlayer() -> Bool {
        return state == .paused || state == .playing || state == .loading || state == .buffering
    }
    
    func updateRate(_ newRate: PlaybackRate) {
        rate = newRate
        self.player.rate = newRate.val
    }
    
    func updateArtwork(_ image: UIImage) {
        let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (size) -> UIImage in
            return image
        })
        player.nowPlayingInfoController.set(keyValue: MediaItemProperty.artwork(artwork))
    }
}
