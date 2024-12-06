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

struct DocumentLoadingView: View {
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    let cornerRadius: CGFloat = 10.0
    let coverSize = AppStyle.Resources.Resource.Cover.size(.portrait)
    let horizontalPading = AppStyle.Resources.Resource.Spacing.paddingForSplashHeader
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading, spacing: 25) {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: screenSizeMonitor.screenSize.height * 0.5)
                    .shimmering()
                
                ForEach(0..<20, id: \.self) { _ in
                    VStack(alignment: .leading) {
                        Rectangle()
                            .cornerRadius(cornerRadius)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(width: screenSizeMonitor.screenSize.width * Double.random(in: 0.5...0.9))
                            .frame(height: 15)
                            .shimmering()
                    }
                    .frame(alignment: .leading)
                    .padding([.horizontal], horizontalPading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .edgesIgnoringSafeArea(.top)
        .scrollIndicators(.hidden)
    }
}
