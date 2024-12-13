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

struct BlockVideoView: View {
    var block: VideoBlock
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject private var viewModel = VideoPlayerSegmentViewModel()
    
    var body: some View {
        VStack (spacing: 10) {
            if let player = viewModel.player {
                FullscreenVideoPlayer(player: player)
                    .background(Color.black)
                    .cornerRadius(6)
                    .overlay {
                        if !viewModel.played {
                            Button {
                                viewModel.play()
                            } label: {
                                Image(systemName: "play.fill").tint(.white).font(.system(size: 53))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(16/9, contentMode: .fill)
                
                if let caption = block.caption {
                    Text(caption)
                        .font(.custom("Lato-Italic", size: 14))
                        .foregroundColor(themeManager.getTextColor().opacity(0.7))
                }
            }
        }.task {
            if viewModel.player == nil {
                viewModel.setupVideoPlayer(block.src, block.caption)
            }
        }
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
