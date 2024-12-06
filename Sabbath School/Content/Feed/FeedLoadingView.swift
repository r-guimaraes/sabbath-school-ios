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

struct FeedLoadingView: View {
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    let cornerRadius: CGFloat = 10.0
    let coverSize = AppStyle.Resources.Feed.Cover.size(.portrait, .vertical, .folio)
    let horizontalPading = AppStyle.Resources.Feed.Spacing.horizontalPadding
    let spaceBetweenCoverAndTitle = AppStyle.Resources.Feed.Spacing.betweenCoverAndTitle(FeedGroupDirection.vertical)
    
    var body: some View {
        ScrollView {
            VStack (spacing: 20) {
                HStack {
                    Rectangle()
                        .cornerRadius(cornerRadius)
                        .frame(width: screenSizeMonitor.screenSize.width * 0.4, height: 30, alignment: .leading)
                        .shimmering()
                    Spacer()
                }.padding(.top, 20)
                
                ForEach(0..<5, id: \.self) { _ in
                    HStack (spacing: spaceBetweenCoverAndTitle) {
                        Rectangle()
                            .cornerRadius(cornerRadius)
                            .frame(
                                width: coverSize.width,
                                height: coverSize.height)
                            .shimmering()
                        
                        VStack (alignment: .leading) {
                            ForEach(0..<2, id: \.self) { _ in
                                Rectangle()
                                    .cornerRadius(cornerRadius)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(width: CGFloat.random(in: 150...200))
                                    .frame(height: 15)
                                    .shimmering()
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
            }.padding(.bottom, 20)
        }
        .padding(.horizontal, horizontalPading)
        .scrollIndicators(.hidden)
    }
}
