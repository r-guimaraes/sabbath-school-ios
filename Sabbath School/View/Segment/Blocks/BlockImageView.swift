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
import NukeUI

struct BlockImageView: StyledBlock, View {
    var block: BlockImage
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    @State private var isFullScreen: Bool = false
    @State private var image: Image? = nil
    
    var body: some View {
        VStack {
            LazyImage(url: block.src) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .onAppear {
                            self.image = image
                        }
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                if image != nil {
                    withAnimation {
                        isFullScreen.toggle()
                    }
                }
            }
            
            if let caption = block.caption {
                Text(caption)
                    .font(.custom("Lato-Italic", size: 14))
                    .foregroundColor((.black | .white).opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fullScreenCover(isPresented: $isFullScreen) {
            FullScreenImageViewer(image: self.$image, viewerShown: self.$isFullScreen, caption: block.caption)
        }
    }
}
