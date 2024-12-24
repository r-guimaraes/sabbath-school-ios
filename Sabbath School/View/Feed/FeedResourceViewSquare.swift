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
    var title: String
    var subtitle: String?
    var cover: URL
    var externalURL: URL?
    var primaryColor: String?
    var direction: FeedGroupDirection
    var scaleFactor: CGFloat = 1
    var backgroundColorEnabled: Bool = false
    var showTitle: Bool = true
    
    var body: some View {
        FeedResourceViewBase(direction: direction,
                             viewType: .square,
                             coverType: .square,
                             showTitle: showTitle,
                             content: { dimensions in
            VStack(spacing: 0) {
                FeedResourceConditionalStack(
                    spacing: AppStyle.Feed.Spacing.betweenCoverAndTitle(direction),
                    direction: direction
                ) {
                    FeedGroupItemCoverView(cover, dimensions, primaryColor ?? "#000000", scaleFactor)
                    if showTitle {
                        FeedGroupItemTitleView(title, subtitle, direction == .horizontal ? dimensions : nil, direction, direction == .vertical, externalURL: externalURL, scaleFactor, backgroundColorEnabled)
                    }
                    
                }
                .frame(maxWidth: direction == .vertical ? .infinity : nil, alignment: .topLeading)
            }
        })
    }
}
