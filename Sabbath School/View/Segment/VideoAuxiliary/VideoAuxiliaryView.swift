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

import Foundation
import SwiftUI
import AVKit
import Nuke
import NukeUI

extension View {
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        condition ? AnyView(transform(self)) : AnyView(self)
    }
}

struct VideoAuxiliaryView: View {
    var videos: [VideoAux]
    var targetIndex: String
    
    var featuredMode: Bool {
        return videos.count == 1
    }
    
    var featuredIndex: Int {
        if let featuredArtist = videos.first, featuredMode {
            return featuredArtist.clips.firstIndex { $0.targetIndex == self.targetIndex } ?? 0
        }
        return 0
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                Rectangle()
                    .fill(Color(uiColor: .baseGray1 | .baseGray2))
                    .cornerRadius(3)
                    .frame(width: 50, height: 5)
    
                VStack (spacing: 40) {
                    Text(AppStyle.Base.navigationTitle("Video".localized()))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if featuredMode {
                        featuredView()
                    } else {
                        multipleView()
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(maxHeight: .infinity)
            }.padding(.top, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @MainActor
    func thumbnailView (_ url: URL, _ size: CGSize? = nil) -> some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                image.resizable().aspectRatio(contentMode: .fill)
            } else if state.error != nil {
                
            } else {
                Color(hex: "#cccccc")
            }
        }
        .if(size != nil) { view in
            view.frame(width: size?.width ?? 0, height: size?.height ?? 0)
        }
        .if(size == nil) { view in
            view
                .frame(maxWidth: .infinity)
                .aspectRatio(16 / 9, contentMode: .fill)
        }
        
        .cornerRadius(6)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
    }
    
    func titleView (_ title: String) -> some View {
        Text(AppStyle.VideoAux.Text.title(title))
            .lineLimit(1)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            
    }
    
    func subtitleView (_ subtitle: String) -> some View {
        Text(AppStyle.VideoAux.Text.subtitle(subtitle))
            .lineLimit(1)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @State private var availableWidth: CGFloat = 0.0
    
    @MainActor @ViewBuilder
    func featuredView () -> some View {
        if let featuredArtist = videos.first,
           let featuredVideo = videos.first?.clips[featuredIndex] {
            
            VStack (spacing: 20) {
                VStack (spacing: 10) {
                    Button(action: {
                        VideoPlaybackV2.shared.play(featuredVideo)
                    }) {
                        thumbnailView(featuredVideo.thumbnail)
                    }
                    
                    
                    VStack (spacing: 5) {
                        titleView(featuredVideo.title)
                        subtitleView(featuredVideo.artist)
                    }
                }
                
                ForEach(Array(featuredArtist.clips.enumerated().filter { $0.offset != featuredIndex }), id: \.offset) { index, clip in
                    Button(action: {
                        VideoPlaybackV2.shared.play(clip)
                    }) {
                        HStack (spacing: 10) {
                            thumbnailView(clip.thumbnail, AppStyle.VideoAux.Size.thumbnail(viewMode: .vertical))
                            
                            VStack (spacing: 5) {
                                titleView(clip.title)
                                subtitleView(clip.artist)
                            }.frame(maxWidth: .infinity)
                            
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                    
            }
            .padding(.horizontal, 20)
        }
    }
    
    @MainActor @ViewBuilder
    func multipleView () -> some View {
        ForEach(videos, id: \.self) { video in
            VStack (spacing: 20) {
                Text(AppStyle.VideoAux.Text.collectionArtist(video.artist))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(video.clips, id: \.self) { clip in
                            Button(action: {
                                VideoPlaybackV2.shared.play(clip)
                            }) {
                                VStack (spacing: 10) {
                                    thumbnailView(clip.thumbnail, AppStyle.VideoAux.Size.thumbnail())
                                    
                                    VStack (spacing: 5) {
                                        titleView(clip.title)
                                        subtitleView(clip.artist)
                                    }
                                }.frame(maxWidth: AppStyle.VideoAux.Size.thumbnail().width)
                            }
                        }
                    }
                    .targetLayout(safeAreaPadding: 20)
                }.scrollViewPaging(safeAreaPadding: 20)
            }
        }
    }
}

struct VideoAuxiliaryView_Previews: PreviewProvider {
    static var previews: some View {
        VideoAuxiliaryView(videos: [
            VideoAux(artist: "Hope Sabbath School", clips: [
                VideoAuxArtist(
                    id: "test",
                    artist: "Hope Sabbath School",
                    title: "Title 1 fsda fds fdsa fdsa fds afdsa fdsafsda",
                    target: "en/ss/2024-04/07",
                    targetIndex: "en-ss-2024-04-07",
                    src: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/64597a1b632ea6349af54eb4f637f0fce16237eb76b892fe5303d6acdb471b08/64597a1b632ea6349af54eb4f637f0fce16237eb76b892fe5303d6acdb471b08.mp4")!,
                    thumbnail: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/64597a1b632ea6349af54eb4f637f0fce16237eb76b892fe5303d6acdb471b08/thumb/64597a1b632ea6349af54eb4f637f0fce16237eb76b892fe5303d6acdb471b08.webp")!),
                
                VideoAuxArtist(
                    id: "117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472",
                    artist: "Hope Sabbath School",
                    title: "Title 1f dsa fds fds afds fdsa fdsafdsa fds fds afds",
                    target: "en/ss/2024-04/06",
                    targetIndex: "en-ss-2024-04-06",
                    src: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.mp4")!,
                    thumbnail: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/thumb/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.webp")!)
            ]),
            
            VideoAux(artist: "Hope Sabbath School", clips: [
                VideoAuxArtist(
                    id: "test",
                    artist: "Hope Sabbath School",
                    title: "Title 1 fdsa fdsa fdsa fdsa fdsa",
                    target: "en/ss/2024-04/07",
                    targetIndex: "en-ss-2024-04-07",
                    src: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/64597a1b632ea6349af54eb4f637f0fce16237eb76b892fe5303d6acdb471b08/64597a1b632ea6349af54eb4f637f0fce16237eb76b892fe5303d6acdb471b08.mp4")!,
                    thumbnail: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/64597a1b632ea6349af54eb4f637f0fce16237eb76b892fe5303d6acdb471b08/thumb/64597a1b632ea6349af54eb4f637f0fce16237eb76b892fe5303d6acdb471b08.webp")!),

                VideoAuxArtist(
                    id: "117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472",
                    artist: "Hope Sabbath School",
                    title: "Title 1 fdsa fds afds afdsa fdsa",
                    target: "en/ss/2024-04/06",
                    targetIndex: "en-ss-2024-04-06",
                    src: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.mp4")!,
                    thumbnail: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/thumb/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.webp")!)
            ])
        ],
                           targetIndex: "en-ss-2024-04-06"
        ).environmentObject(ScreenSizeMonitor())
    }
}

struct VideoAuxiliaryView_Previews_FeaturedView: PreviewProvider {
    static var previews: some View {
        Text("test").sheet(isPresented: .constant(true)) {
            VideoAuxiliaryView(videos: [
                VideoAux(artist: "Hope Sabbath School", clips: [
                    VideoAuxArtist(
                        id: "test",
                        artist: "Hope Sabbath School",
                        title: "Title 1 dsf fdsa fdsa fdsa fdsa fdsa fdsa fdsad",
                        target: "en/ss/2024-04/07",
                        targetIndex: "en-ss-2024-04-07",
                        src: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/64597a1b632ea6349af54eb4f637f0fce16237eb76b892fe5303d6acdb471b08/64597a1b632ea6349af54eb4f637f0fce16237eb76b892fe5303d6acdb471b08.mp4")!,
                        thumbnail: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/64597a1b632ea6349af54eb4f637f0fce16237eb76b892fe5303d6acdb471b08/thumb/64597a1b632ea6349af54eb4f637f0fce16237eb76b892fe5303d6acdb471b08.webp")!),
                    
                    VideoAuxArtist(
                        id: "117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472",
                        artist: "Hope Sabbath School",
                        title: "Title 1 fsda fdsa fdsa fdsa fdsa fsd",
                        target: "en/ss/2024-04/06",
                        targetIndex: "en-ss-2024-04-06",
                        src: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.mp4")!,
                        thumbnail: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/thumb/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.webp")!),
                    
                    VideoAuxArtist(
                        id: "117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472",
                        artist: "Hope Sabbath School",
                        title: "Title 1 fsda fdsa fdsa fdsa fdsa fsd",
                        target: "en/ss/2024-04/06",
                        targetIndex: "en-ss-2024-04-06",
                        src: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.mp4")!,
                        thumbnail: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/thumb/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.webp")!),
                    
                    VideoAuxArtist(
                        id: "117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472",
                        artist: "Hope Sabbath School",
                        title: "Title 1 fsda fdsa fdsa fdsa fdsa fsd",
                        target: "en/ss/2024-04/06",
                        targetIndex: "en-ss-2024-04-06",
                        src: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.mp4")!,
                        thumbnail: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/thumb/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.webp")!),
                    
                    VideoAuxArtist(
                        id: "117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472",
                        artist: "Hope Sabbath School",
                        title: "Title 1 fsda fdsa fdsa fdsa fdsa fsd",
                        target: "en/ss/2024-04/06",
                        targetIndex: "en-ss-2024-04-06",
                        src: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.mp4")!,
                        thumbnail: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/thumb/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.webp")!),
                    
                    VideoAuxArtist(
                        id: "117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472",
                        artist: "Hope Sabbath School",
                        title: "Title 1 fsda fdsa fdsa fdsa fdsa fsd",
                        target: "en/ss/2024-04/06",
                        targetIndex: "en-ss-2024-04-06",
                        src: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.mp4")!,
                        thumbnail: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/thumb/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.webp")!),
                    
                    VideoAuxArtist(
                        id: "117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472",
                        artist: "Hope Sabbath School",
                        title: "Title 1 fsda fdsa fdsa fdsa fdsa fsd",
                        target: "en/ss/2024-04/06",
                        targetIndex: "en-ss-2024-04-06",
                        src: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.mp4")!,
                        thumbnail: URL(string: "https://sabbath-school-media-stage.adventech.io/video/en/2024-04/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472/thumb/117a60a7a8e00cf5047713bc42108622eeb84dc5f69343fcc2d167a41f620472.webp")!)
                ])
            ],
                               targetIndex: "en-ss-2024-04-06"
            )
        }
    }
}
