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

struct FeedResourceViewBase<Content: View>: View {
    var direction: FeedGroupDirection
    var viewType: FeedGroupViewType
    var coverType: ResourceCoverType
    
    @State var dimensions: CGSize = CGSizeMake(0.0, 0.0)
    
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    var content: (CGSize) -> Content
    
    var body: some View {
        content(dimensions).onAppear {
            updateDimensions()
        }.onChange(of: screenSizeMonitor.screenSize.width) { _ in
            updateDimensions()
        }
    }
    
    private func updateDimensions() {
        dimensions = AppStyle.Resources.Size.coverSize(coverType: coverType, direction: direction, viewType: viewType, initialWidth: screenSizeMonitor.screenSize.width)
    }
}

struct FeedResourceView: View {
    var resource: Resource
    var feedGroupViewType: FeedGroupViewType
    var feedGroupDirection: FeedGroupDirection
    
    var body: some View {
        switch feedGroupViewType {
        case .banner:
            FeedResourceViewBanner(resource: resource, direction: feedGroupDirection)
        case .folio:
            FeedResourceViewFolio(resource: resource, direction: feedGroupDirection)
        case .square:
            FeedResourceViewSquare(resource: resource, direction: feedGroupDirection)
        case .tile:
            FeedResourceViewTile(resource: resource, direction: feedGroupDirection)
        }
    }
}
