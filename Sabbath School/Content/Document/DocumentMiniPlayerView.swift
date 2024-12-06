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
import SwiftAudio

extension DocumentView {
    func miniPlayerView () -> some View {
        Button(action: {
            showAudioAux = true
        }) {
            VStack {
                HStack {
                    Button (action: {
                        miniPlayerStop()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                    
                    VStack {
                        Text(AppStyle.Resources.Audio.miniPlayerTitle(AudioPlayback.shared.currentItem?.getTitle() ?? ""))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                        Text(AppStyle.Resources.Audio.miniPlayerArtist(AudioPlayback.shared.currentItem?.getArtist() ?? ""))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }.frame(alignment: .leading)
                    
                    Spacer()
                    
                    Button (action: {
                        miniPlayerRewind()
                    }) {
                        Image(systemName: "gobackward.15")
                            .imageScale(.medium)
                    }
                    
                    Button (action: {
                        miniPlayerPausePlay()
                    }) {
                        Image(systemName: documentViewOperator.miniPlayerStatus == .playing ? "pause.fill" : "play.fill")
                            .imageScale(.large)
                    }
                }
                .frame(height: AppStyle.Resources.Audio.miniPlayerHeight)
                .padding(AppStyle.Resources.Audio.miniPlayerContentPadding)
                .background(Color(uiColor: .baseGray1) | .black.opacity(0.9))
                .cornerRadius(AppStyle.Resources.Audio.miniPlayerCornerRadius)
            }
            .frame(height: AppStyle.Resources.Audio.miniPlayerHeight)
            .frame(maxWidth: screenSizeMonitor.screenSize.width - AppStyle.Resources.Audio.miniPlayerWrapperPadding * 2)
            .background(.black | .white)
            .cornerRadius(AppStyle.Resources.Audio.miniPlayerCornerRadius)
            .padding(.bottom, documentViewOperator.tabBarHeight + documentViewOperator.bottomSafeAreaInset + AppStyle.Resources.Segment.Spacing.verticalPaddingContent)
            .padding(.horizontal, AppStyle.Resources.Audio.miniPlayerWrapperPadding)
            .buttonStyle(PlainButtonStyle())
        }.buttonStyle(PlainButtonStyle())
    }
    
    func miniPlayerPausePlay () {
        AudioPlayback.shared.togglePlaying()
    }
    
    func miniPlayerRewind () {
        AudioPlayback.shared.seek(to: AudioPlayback.shared.currentTime - 15)
    }
    
    func miniPlayerStop () {
        AudioPlayback.shared.stop()
        documentViewOperator.showMiniPlayer = false
    }
}
