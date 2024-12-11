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

@MainActor @ViewBuilder
func FeedResourceCoverView(_ url: URL, _ dimensions: CGSize, _ placeholderColor: String? = nil) -> some View {
    LazyImage(url: url) { state in
        if let image = state.image {
            image.resizable().aspectRatio(contentMode: .fill)
        } else if state.error != nil {

        } else {
            Color(hex: placeholderColor ?? "#cccccc")
        }
    }
    .frame(width: dimensions.width, height: dimensions.height)
    .cornerRadius(6)
    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
}

@ViewBuilder
func FeedResourceTitleView(_ title: String, _ subtitle: String?, _ dimensions: CGSize? = nil, _ direction: FeedGroupDirection, _ enlarge: Bool = false, externalURL: URL? = nil) -> some View {
    HStack {
        VStack(alignment: .leading, spacing: AppStyle.Feed.Spacing.betweenTitleAndSubtitle) {
            Text(AppStyle.Feed.Title.text(title, enlarge))
                .lineLimit(AppStyle.Feed.Title.lineLimit)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            if let subtitle = subtitle, direction == .vertical {
                Text(AppStyle.Feed.Subtitle.text(subtitle))
                    .lineLimit(AppStyle.Feed.Subtitle.lineLimit)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }.frame(alignment: .leading)
        
        Spacer()
        if externalURL != nil {
            Image(systemName: "arrow.up.forward.square")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.secondary)
        }
    }.frame(width: dimensions?.width, alignment: .leading)
}

@ViewBuilder
func FeedResourceConditionalStack<Content: View>(spacing: CGFloat, direction: FeedGroupDirection, @ViewBuilder content: () -> Content) -> some View {
    if direction == .horizontal {
        VStack(spacing: spacing, content: content)
    } else {
        HStack(spacing: spacing, content: content)
    }
}

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
        dimensions = AppStyle.Feed.Cover.size(
            coverType,
            direction,
            viewType,
            screenSizeMonitor.screenSize.width
        )
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
