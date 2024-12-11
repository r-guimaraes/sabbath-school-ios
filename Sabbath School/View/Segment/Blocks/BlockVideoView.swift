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
import AVKit

class VideoPlayerViewModel: ObservableObject {
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    @Published var played: Bool = false
    
    
    init(url: URL) {
        setupVideoPlayer(url: url)
    }
    
    private func setupVideoPlayer(url: URL) {
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
    }
    
    func getPlayer() -> AVPlayer? {
        return player
    }
}

struct BlockVideoView: View {
    var block: VideoBlock
    
    @ObservedObject var viewModel: VideoPlayerViewModel
    
    @State var width: CGFloat = 0
    @State var height: CGFloat = 0
    
    init(block: VideoBlock) {
        self.block = block
        viewModel = VideoPlayerViewModel(url: block.src)
    }
    
    var body: some View {
        VStack (spacing: 10) {
            GeometryReader { geometry in
                VideoPlayer(player: viewModel.getPlayer())
                    .background(Color.black)
                    .cornerRadius(6)
                    .overlay {
                        if !viewModel.played {
                            Button {
                                viewModel.played = true
                                viewModel.getPlayer()?.play()
                            } label: {
                                Image(systemName: "play.fill").tint(.white).font(.system(size: 53))
                            }
                        }
                    }
                    .frame(width: width, height: height)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        calculateHeight(width: geometry.size.width)
                    }
                    .onChange(of: geometry.size) { _ in
                        calculateHeight(width: geometry.size.width)
                    }
                    
            }
            .frame(maxHeight: .infinity)
            .frame(height: height)
            
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
    
    private func calculateHeight(width: CGFloat) {
        self.width = width
        
        height = width / (16/9)
    }
}

struct MultipleVideoPlayersView: View {
    var body: some View {
        ScrollView {
            VStack {
                BlockVideoView(
                    block: VideoBlock(
                        id: "video-block",
                        type: .video,
                        style: nil,
                        data: nil,
                        src: URL(string: "https://www.w3schools.com/html/mov_bbb.mp4")!,
                        caption: "Caption",
                        nested: false
                    )
                )
            }
        }
    }
}

struct MultipleVideoPlayersView_Previews: PreviewProvider {
    static var previews: some View {
        MultipleVideoPlayersView()
    }
}
