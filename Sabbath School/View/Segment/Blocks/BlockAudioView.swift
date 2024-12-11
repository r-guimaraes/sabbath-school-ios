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

import SwiftUI
import AVFoundation

class AudioPlayerViewModel: ObservableObject {
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserverToken: Any?
    private var statusObserver: NSKeyValueObservation?
    
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    
    init(url: URL) {
        setupAudioPlayer(url: url)
    }
    
    private func setupAudioPlayer(url: URL) {
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self = self, let currentItem = self.player?.currentItem else { return }
            self.currentTime = time.seconds
            self.duration = currentItem.duration.seconds
        }
        
        statusObserver = playerItem?.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
            if item.status == .readyToPlay {
                self?.duration = item.duration.seconds
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    func playPause() {
        guard let player = player else { return }
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    func seek(to time: Double) {
        let time = CMTime(seconds: time, preferredTimescale: 1)
        player?.seek(to: time)
    }
    
    @objc private func audioDidFinishPlaying() {
        player?.seek(to: .zero)
        isPlaying = false
        currentTime = 0
    }
    
    deinit {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
        }
        NotificationCenter.default.removeObserver(self)
    }
}

struct BlockAudioView: View {
    var block: AudioBlock
    @ObservedObject var viewModel: AudioPlayerViewModel
    
    init(block: AudioBlock) {
        self.block = block
        viewModel = AudioPlayerViewModel(url: block.src)
    }
    
    var body: some View {
        VStack (spacing: 10){
            HStack {
                Button(action: {
                    viewModel.playPause()
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                
                Text("\(formatTime(viewModel.currentTime))")
                    .font(.custom("Lato-Regular", size: 14))
                
                Spacer()
                
                if viewModel.duration > 0 {
                    Slider(value: $viewModel.currentTime, in: 0...viewModel.duration, onEditingChanged: { editing in
                        if !editing {
                            viewModel.seek(to: viewModel.currentTime)
                        }
                    }).onAppear {
                        let progressCircleConfig = UIImage.SymbolConfiguration(scale: .small)
                        UISlider.appearance()
                            .setThumbImage(UIImage(systemName: "circle.fill",
                                                   withConfiguration: progressCircleConfig), for: .normal)
                    }
                }
            }.padding(10).background(.gray.opacity(0.15)).cornerRadius(6)
            
            if let caption = block.caption {
                Text(caption)
                    .font(.custom("Lato-Italic", size: 14))
                    .foregroundColor((.black | .white).opacity(0.7))
            }
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BlockAudioView(
            block: AudioBlock(
                id: "audio-block",
                type: .audio,
                style: nil,
                data: nil,
                src: URL(string: "https://sabbath-school-media-stage.adventech.io/audio/en/2024-02/00b0f29167d9677ddcf832ddf7f94ec7f50184b45ee7926242cd99d4a53a00c3/00b0f29167d9677ddcf832ddf7f94ec7f50184b45ee7926242cd99d4a53a00c3.mp3")!,
                caption: "Caption",
                nested: false
            )
        )
    }
}
