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

struct ResourceLoadingView: View {
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    let cornerRadius: CGFloat = 10.0
    let coverSize = AppStyle.Resources.Resource.Cover.size(.portrait)
    let horizontalPading = AppStyle.Resources.Resource.Spacing.paddingForSplashHeader
    
    var body: some View {
        ScrollView {
            VStack (spacing: 50) {
                VStack (spacing: 20) {
                    Rectangle()
                        .cornerRadius(cornerRadius)
                        .frame(
                            width: coverSize.width,
                            height: coverSize.height)
                        .shimmering()
                    
                    Rectangle()
                        .cornerRadius(cornerRadius)
                        .frame(width: screenSizeMonitor.screenSize.width * 0.8, height: 20, alignment: .center)
                        .shimmering()
                    
                    Rectangle()
                        .cornerRadius(cornerRadius)
                        .frame(width: screenSizeMonitor.screenSize.width * 0.57, height: 15, alignment: .center)
                        .shimmering()
                }
                
                VStack (spacing: 5) {
                    Rectangle()
                        .cornerRadius(cornerRadius)
                        .frame(width: screenSizeMonitor.screenSize.width * 0.9, height: 8, alignment: .center)
                        .shimmering()
                    
                    Rectangle()
                        .cornerRadius(cornerRadius)
                        .frame(width: screenSizeMonitor.screenSize.width * 0.9, height: 8, alignment: .center)
                        .shimmering()
                    
                    Rectangle()
                        .cornerRadius(cornerRadius)
                        .frame(width: screenSizeMonitor.screenSize.width * 0.5, height: 8, alignment: .center)
                        .shimmering()
                    
                }
                
                VStack (alignment: .leading, spacing: 25) {
                    ForEach(0..<13, id: \.self) { _ in
                        HStack (spacing: 20) {
                            VStack {
                                Rectangle()
                                    .cornerRadius(cornerRadius)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(width: 15)
                                    .frame(height: 15)
                                    .shimmering()
                                Spacer()
                            }
                            
                            VStack(alignment: .leading) {
                                Rectangle()
                                    .cornerRadius(cornerRadius)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(width: screenSizeMonitor.screenSize.width * 0.6)
                                    .frame(height: 15)
                                    .shimmering()
                                
                                Rectangle()
                                    .cornerRadius(cornerRadius)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(width: screenSizeMonitor.screenSize.width * 0.3)
                                    .frame(height: 10)
                                    .shimmering()
                            }.frame(alignment: .leading)
                        }
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, horizontalPading)
        .scrollIndicators(.hidden)
        .background(.white | .black)
    }
}
