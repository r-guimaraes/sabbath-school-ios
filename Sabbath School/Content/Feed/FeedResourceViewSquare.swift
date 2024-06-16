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

struct FeedResourceViewSquare: View {
    var resource: Resource
    var direction: FeedGroupDirection
    
    var body: some View {
        FeedResourceViewBase(direction: direction,
                             viewType: .square,
                             coverType: .square,
                             content: { dimensions in
            VStack(spacing: 0) {
                if direction == .horizontal {
                    VStack (spacing: 10) {
                        FeedResourceViewCover(url: resource.covers.square, dimensions: dimensions)
                        
                        VStack (alignment: .leading) {
                            if direction == .horizontal {
                                Text(AppStyle.Resources.Text.resourceTitle(string: resource.title)).lineLimit(2).multilineTextAlignment(.leading)
                                Text(AppStyle.Resources.Text.resourceSubTitle(string: resource.subtitle)).lineLimit(2).multilineTextAlignment(.leading)
                                Spacer()
                            }
                        }.frame(width: dimensions.width, alignment: .leading)
                    }
                }
                if direction == .vertical {
                    HStack(spacing: 10) {
                        FeedResourceViewCover(url: resource.covers.square, dimensions: dimensions)
                        
                        VStack (alignment: .leading) {
                            Text(AppStyle.Resources.Text.resourceTitle(string: resource.title)).lineLimit(2).multilineTextAlignment(.leading)
                            Text(AppStyle.Resources.Text.resourceSubTitle(string: resource.subtitle)).lineLimit(2).multilineTextAlignment(.leading)
                        }
                    }.frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
        })
    }
}
