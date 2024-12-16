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
import NukeUI
import MediaPlayer

struct FullscreenVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.beginAppearanceTransition(true, animated: false)
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) { }
}

class VideoPlayerSegmentViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var played: Bool = false
    @Published var artwork: UIImage? = nil
    
    func setupVideoPlayer(_ url: URL, _ title: String? = nil) {
        let playerItem = AVPlayerItem(url: url)
        
        if let title = title {
            let titleMetadata = AVMutableMetadataItem()
            titleMetadata.identifier = AVMetadataIdentifier.commonIdentifierTitle
            titleMetadata.value = title as NSString
            
            playerItem.externalMetadata = [titleMetadata]
        }
        
        player = AVPlayer(playerItem: playerItem)
    }
        
    func setupVideoPlayer(_ video: VideoClipSegment) {
        let playerItem = AVPlayerItem(url: video.hls ?? video.src)
        
        var items: [AVMutableMetadataItem] = []
        
        if let title = video.title {
            let titleMetadata = AVMutableMetadataItem()
            titleMetadata.identifier = AVMetadataIdentifier.commonIdentifierTitle
            titleMetadata.value = title as NSString
            items.append(titleMetadata)
        }
        
        if let artist = video.artist {
            let artistMetadata = AVMutableMetadataItem()
            artistMetadata.identifier = AVMetadataIdentifier.commonIdentifierArtist
            artistMetadata.value = artist as NSString
            items.append(artistMetadata)
        }
        
        if items.count > 0 {
            playerItem.externalMetadata = items
        }
        
        player = AVPlayer(playerItem: playerItem)
    }
    
    func play() {
        played = true
        player?.play()
        
        if artwork != nil {
            setThumbnail()
        }
    }
    
    func setThumbnail () {
        if let artwork = artwork {
            let artworkMetadata = AVMutableMetadataItem()
            artworkMetadata.identifier = AVMetadataIdentifier.commonIdentifierArtwork
            artworkMetadata.value = artwork.pngData() as (NSCopying & NSObjectProtocol)?
            
            player?.currentItem?.externalMetadata.append(artworkMetadata)
        }
    }
    
    func getPlayer() -> AVPlayer? {
        return player
    }
}

struct SegmentViewVideo: View {
    var video: [VideoClipSegment]?
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject private var viewModel = VideoPlayerSegmentViewModel()
    
    @State private var selectedVideo: VideoClipSegment
    @State private var isFullscreen = false
    
    init(video: [VideoClipSegment]?) {
        self.video = video
        
        // TODO: avoid ugly code
        self.selectedVideo = self.video?[safe: 0] ?? VideoClipSegment(
            src: URL(string: "https://this-should-not-happen.com")!,
            artist: nil,
            title: nil,
            thumbnail: nil,
            hls: nil
        )
    }
    
    var body: some View {
        if let _ = video {
            VStack {
                if let _ = viewModel.player {
                    FullscreenVideoPlayer(player: viewModel.player!)
                        .background(Color.black)
                        .cornerRadius(6)
                        .overlay {
                            if !viewModel.played {
                                ZStack(alignment: .center) {
                                    if let thumbnail = video?.first?.thumbnail {
                                        LazyImage(url: thumbnail) { image in
                                            image.image?.resizable()
                                                .scaledToFill()
                                                .onAppear {
                                                    if let thumbnail = image.imageContainer?.image {
                                                        viewModel.artwork = thumbnail
                                                    }
                                                }
                                        }
                                    }
                                    
                                    Color.black.opacity(0.5)
                                    
                                    Button {
                                        viewModel.play()
                                    } label: {
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 53))
                                            .foregroundColor(.white)
                                    }.buttonStyle(.plain)
                                }.cornerRadius(6)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .aspectRatio(16/9, contentMode: .fill)
                }
            }
            .padding()
            .task {
                if viewModel.player == nil {
                    viewModel.setupVideoPlayer(selectedVideo)
                }
            }
        }
    }
}
