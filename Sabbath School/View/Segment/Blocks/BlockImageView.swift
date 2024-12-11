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

struct BlockImageViewFullScreen: StyledBlock, View {
    var block: BlockImage
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    @Binding var isFullScreen: Bool
    @State private var dragOffset: CGSize = .zero
    @State private var cumulativeDragOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            LazyImage(url: block.src) { image in
                image.image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .scaleEffect(scale)
            .offset(x: cumulativeDragOffset.width + dragOffset.width, y: cumulativeDragOffset.height + dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        if scale <= 1 && (abs(value.translation.height) > 100 || abs(value.translation.width) > 100) {
                            withAnimation {
                                isFullScreen = false
                            }
                        } else {
                            cumulativeDragOffset.width += dragOffset.width
                            cumulativeDragOffset.height += dragOffset.height
                            dragOffset = .zero
                        }
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = max(1.0, lastScale * value)
                    }
                    .onEnded { value in
                        lastScale = scale
                    }
            )
            .gesture(
                TapGesture(count: 2)
                    .onEnded {
                        withAnimation {
                            if scale > 1 {
                                scale = 1
                                lastScale = 1
                                cumulativeDragOffset = .zero
                            } else {
                                scale = 2
                                lastScale = 2
                            }
                        }
                    }
            )
            .animation(.interactiveSpring(), value: scale)
        }
    }
}

struct BlockImageView: StyledBlock, View {
    var block: BlockImage
    
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    @State var width: CGFloat = 0
    @State var height: CGFloat = 0
    
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    @State private var isFullScreen: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                LazyImage(url: block.src) { image in
                    image.image?
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .frame(width: width, height: height)
                .onTapGesture {
                    withAnimation {
                        isFullScreen.toggle()
                    }
                }
                .fullScreenCover(isPresented: $isFullScreen) {
                    BlockImageViewFullScreen(block: block, isFullScreen: $isFullScreen)
                }
            }
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
    }
    
    private func calculateHeight(width: CGFloat) {
        self.width = width
        height = width / (block.style?.image?.aspectRatio ?? 16/9)
    }
}

