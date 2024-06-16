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

struct FeedResourceViewBanner: View {
    var resource: Resource
    var direction: FeedGroupDirection
    
    var body: some View {
        FeedResourceViewBase(direction: direction,
                             viewType: .banner,
                             coverType: .landscape,
                             content: { dimensions in
            ZStack (alignment: .bottomLeading) {
                FeedResourceViewCover(url: resource.covers.landscape, dimensions: dimensions)
                
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(width: dimensions.width, height: dimensions.height*0.4)
                    .mask {
                        VStack(spacing: 0){
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0),
                                    Color.white.opacity(0.303),
                                    Color.white.opacity(0.707),
                                    Color.white.opacity(0.924),
                                    Color.white
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            Rectangle()
                                .frame(height: dimensions.height*0.1)
                        }.cornerRadius(6)

                    }
//
                    
                
                VStack (alignment: .leading, spacing: 5) {
                    Text(AppStyle.Resources.Text.resourceTitle(string: resource.title, viewType: .banner)).lineLimit(2)
                    Text(AppStyle.Resources.Text.resourceSubTitle(string: resource.subtitle, viewType: .banner)).lineLimit(2)
                    
                }
                // TODO: spacing * 2
                .frame(width: dimensions.width-40, alignment: .leading)
                .padding(15)
                
            }.frame(width: dimensions.width)
        })
    }
}
