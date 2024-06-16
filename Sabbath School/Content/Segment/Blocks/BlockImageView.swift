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

struct BlockImageView: StyledBlock, View {
    var block: BlockImage
    
    @Environment(\.nested) var nested: Bool
    @Environment(\.defaultBlockStyles) var defaultStyles: DefaultBlockStyles
    
    @State var width: CGFloat = 0
    @State var height: CGFloat = 0
    
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                AsyncImage(url: block.src) { image in
                    image.image?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }.frame(width: width, height: height)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    calculateHeight(width: geometry.size.width)
                }
                .onChange(of: geometry.size) { _ in
                    calculateHeight(width: geometry.size.width)
                }
        }
        .frame(maxHeight: .infinity)
        .frame(height: height)
    }
    
    private func calculateHeight(width: CGFloat) {
        self.width = width
        height = width / (block.style?.image?.aspectRatio ?? 16/9)
    }
}

