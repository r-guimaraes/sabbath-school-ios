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
import AVKit

struct FullscreenVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No update needed
    }
}

struct SegmentViewVideo: View {
    var video: [VideoClipSegment]
    
    @ObservedObject var viewModel: VideoPlayerViewModel
    
    @State private var isFullscreen = false
    
    init(video: [VideoClipSegment]) {
        self.video = video
        print("SSDEBUG", video.first!.src)
        viewModel = VideoPlayerViewModel(url: URL(string: "https://sabbath-school-media-tmp.s3.amazonaws.com/en/365/365-en-2024-04-08.mp4")!)
    }
    
    var body: some View {
        VStack {
            Button("Go Fullscreen") {
                    isFullscreen.toggle()
                }
            
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
                }.frame(width: 300, height: 300/1.5)
                .fullScreenCover(isPresented: $isFullscreen) {
                    FullscreenVideoPlayer(player: viewModel.getPlayer()!)
                        .edgesIgnoringSafeArea(.all)
                }
        }
    }
}
