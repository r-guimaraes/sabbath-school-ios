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

private enum CoordinateSpaces {
    case scrollView
}

struct SegmentViewBlocks: View {
    var segment: Segment
    var isHiddenSegment: Bool = false
    
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    @EnvironmentObject var audioPlayback: AudioPlayback
    @EnvironmentObject var documentViewOperator: DocumentViewOperator
    
    var body: some View {
        if let blocks = segment.blocks {
            VStack (spacing: AppStyle.Segment.Spacing.betweenBlocks)  {
                ForEach(blocks) { block in
                    BlockWrapperView(block: block)
                        .environment(\.themeManager, themeManager)
                        .environment(\.defaultBlockStyles, defaultStyles)
                        .id(block.id)
                }
            }
            .padding(.bottom, AppStyle.Segment.Spacing.verticalPaddingContent +
                     (audioPlayback.shouldShowMiniPlayer() || documentViewOperator.hiddenSegment != nil ? 80 * 2 : 80)
            )
            .padding(.top, AppStyle.Segment.Spacing.verticalPaddingContent)
            .padding(.horizontal, AppStyle.Segment.Spacing.horizontalPaddingContent(screenSizeMonitor.screenSize.width, isHiddenSegment))
        }
    }
}

struct BottomClipShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(x: rect.minX, y: rect.minY - 1000, width: rect.width, height: rect.height + 1000))
        return path
    }
}

struct SegmentViewCover: View {
    var segment: Segment
    var document: ResourceDocument
    var resource: Resource
    var isHiddenSegment: Bool = false
    
    private var hasCover: Bool {
        return segment.type == .block && (segment.cover != nil || document.cover != nil)
    }
    
    private var titleBelowCover: Bool {
        return (document.titleBelowCover != nil && document.titleBelowCover == true)
        || (segment.titleBelowCover != nil && segment.titleBelowCover == true)
    }
    
    private var style: Style? {
        return segment.style ?? document.style ?? resource.style
    }
    
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    @EnvironmentObject var documentViewOperator: DocumentViewOperator
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    @EnvironmentObject var audioPlayback: AudioPlayback
    
    var body: some View {
        if let cover = segment.cover ?? document.cover, hasCover {
            ZStack (alignment: .bottom) {
                ParallaxHeader(
                    coordinateSpace: CoordinateSpaces.scrollView,
                    defaultHeight: AppStyle.Segment.Cover.height()
                ) {
                    LazyImage(url: cover) { image in
                        image.image?.resizable().scaledToFill()
                    }
                }
                .clipShape(BottomClipShape())
                .id(segment.index)
                
                if !titleBelowCover {
                    SegmentHeader(segment.markdownTitle ?? segment.title,
                                  segment.date,
                                  segment.markdownSubtitle ?? segment.subtitle,
                                  hasCover && !titleBelowCover,
                                  segment.style ?? resource.style,
                                  AppStyle.Segment.Spacing.verticalPaddingHeader(),
                                  isHiddenSegment)
                }
            }
            .frame(height: AppStyle.Segment.Cover.height())   
        }
        
        VStack {
            if !hasCover || titleBelowCover {
                SegmentHeader(segment.markdownTitle ?? segment.title,
                              segment.date,
                              segment.markdownSubtitle ?? segment.subtitle,
                              hasCover && !titleBelowCover,
                              segment.style ?? resource.style,
                              AppStyle.Segment.Spacing.verticalPaddingHeader(),
                              isHiddenSegment)
                .padding(.top, hasCover || (hasCover && titleBelowCover) ? 20 : AppStyle.Segment.Cover.height(false))
            }
        }
    }
    
//    func SegmentHeader(_ title: String, _ date: ServerDate?, _ subtitle: String?, _ hasCover: Bool, _ style: Style?) -> some View {
//        VStack (spacing: AppStyle.Segment.Spacing.betweenTitleDateAndSubtitle) {
//            if let subtitle = subtitle {
//                VStack (spacing: 0) {
//                    Text(AppStyle.Segment.Subtitle.text(subtitle, hasCover, style))
//                        .multilineTextAlignment(Styler.getTextAlignment(style, SegmentSubtitleStyleTemplate()))
//                        .lineLimit(AppStyle.Segment.Subtitle.lineLimit)
//                        .fixedSize(horizontal: false, vertical: true)
//                }.frame(maxWidth: .infinity, alignment: Styler.convertTextAlignment(Styler.getTextAlignment(style, SegmentSubtitleStyleTemplate())))
//            }
//            
//            if let date = date {
//                VStack (spacing: 0) {
//                    Text(AppStyle.Segment.Date.text(
//                        date.date.stringReadDate()
//                            .replacingLastOccurrence(of: Constants.StringsToBeReplaced.saturday,
//                                                     with: Constants.StringsToBeReplaced.sabbath),
//                        hasCover, style)
//                    )
//                    .multilineTextAlignment(Styler.getTextAlignment(style, SegmentDateStyleTemplate()))
//                    .lineLimit(AppStyle.Segment.Date.lineLimit)
//                    .fixedSize(horizontal: false, vertical: true)
//                }.frame(maxWidth: .infinity, alignment: Styler.convertTextAlignment(Styler.getTextAlignment(style, SegmentDateStyleTemplate())))
//            }
//            
//            VStack {
//                Text(AppStyle.Segment.Title.text(title, hasCover, style))
//                    .multilineTextAlignment(Styler.getTextAlignment(style, SegmentTitleStyleTemplate()))
//                    .lineLimit(AppStyle.Segment.Title.lineLimit)
//                    .fixedSize(horizontal: false, vertical: true)
//            }.frame(maxWidth: .infinity, alignment: Styler.convertTextAlignment(Styler.getTextAlignment(style, SegmentTitleStyleTemplate())))
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(.horizontal, AppStyle.Segment.Spacing.horizontalPaddingHeader(screenSizeMonitor.screenSize.width))
//        .padding(.vertical, AppStyle.Segment.Spacing.verticalPaddingHeader())
//    }
}

struct SegmentHeader: View {
    var title: String
    var date: ServerDate?
    var subtitle: String?
    var hasCover: Bool
    var style: Style?
    var verticalPadding: CGFloat
    var isHiddenSegment: Bool

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    init (_ title: String, _ date: ServerDate?, _ subtitle: String?, _ hasCover: Bool, _ style: Style?, _ verticalPadding: CGFloat = AppStyle.Segment.Spacing.verticalPaddingHeader(), _ isHiddenSegment: Bool = false) {
        self.title = title
        self.date = date
        self.subtitle = subtitle
        self.hasCover = hasCover
        self.style = style
        self.verticalPadding = verticalPadding
        self.isHiddenSegment = isHiddenSegment
    }
    
    var body: some View {
        VStack (spacing: AppStyle.Segment.Spacing.betweenTitleDateAndSubtitle) {
            if let subtitle = subtitle {
                VStack (spacing: 0) {
                    Text(AppStyle.Segment.Subtitle.text(subtitle, hasCover, style))
                        .multilineTextAlignment(Styler.getTextAlignment(style, SegmentSubtitleStyleTemplate()))
                        .lineLimit(AppStyle.Segment.Subtitle.lineLimit)
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
                }.frame(maxWidth: .infinity, alignment: Styler.convertTextAlignment(Styler.getTextAlignment(style, SegmentSubtitleStyleTemplate())))
            }
            
            if let date = date {
                VStack (spacing: 0) {
                    Text(AppStyle.Segment.Date.text(
                        date.date.stringReadDate()
                            .replacingLastOccurrence(of: Constants.StringsToBeReplaced.saturday,
                                                     with: Constants.StringsToBeReplaced.sabbath),
                        hasCover, style)
                    )
                    .multilineTextAlignment(Styler.getTextAlignment(style, SegmentDateStyleTemplate()))
                    .lineLimit(AppStyle.Segment.Date.lineLimit)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
                }.frame(maxWidth: .infinity, alignment: Styler.convertTextAlignment(Styler.getTextAlignment(style, SegmentDateStyleTemplate())))
            }
            
            VStack {
                Text(AppStyle.Segment.Title.text(title, hasCover, style))
                    .multilineTextAlignment(Styler.getTextAlignment(style, SegmentTitleStyleTemplate()))
                    .lineLimit(AppStyle.Segment.Title.lineLimit)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }.frame(maxWidth: .infinity, alignment: Styler.convertTextAlignment(Styler.getTextAlignment(style, SegmentTitleStyleTemplate())))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppStyle.Segment.Spacing.horizontalPaddingHeader(screenSizeMonitor.screenSize.width, isHiddenSegment))
        .padding(.vertical, verticalPadding)
    }
}

struct SegmentViewBase<Content: View>: View {
    var resource: Resource
    var segment: Segment
    var index: Int
    var document: ResourceDocument
    var isHiddenSegment: Bool = false
    
    let content: (SegmentViewCover, SegmentViewBlocks, SegmentViewVideo, SegmentHeader) -> Content
    
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var documentViewOperator: DocumentViewOperator
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    @EnvironmentObject var audioPlayback: AudioPlayback
    
    @State var scrollOffset: CGFloat = 0
    
    private var hasCover: Bool {
        return segment.type == .block && (segment.cover != nil || document.cover != nil)
    }
    
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                content(
                    SegmentViewCover(segment: segment, document: document, resource: resource),
                    SegmentViewBlocks(segment: segment, isHiddenSegment: isHiddenSegment),
                    SegmentViewVideo(video: segment.video),
                    SegmentHeader(segment.markdownTitle ?? segment.title,
                                  segment.date,
                                  segment.markdownSubtitle ?? segment.subtitle,
                                  false,
                                  segment.style ?? resource.style,
                                  0,
                                  isHiddenSegment)
                )
            }
            .onChange(of: sizeCategory) { newValue in }
            .background(GeometryReader { geometry in
                Color.clear.onChange(of: geometry.frame(in: .named(CoordinateSpaces.scrollView)).minY) { scrollOffset in
                    if index == documentViewOperator.activeTab, segment.type != .video {
                        self.scrollOffset = scrollOffset
                        
                        let multiplier = screenSizeMonitor.screenSize.height * AppStyle.Segment.Cover.percentageOfScreen(hasCover)
                        
                        let visibility = scrollOffset <= -1 * (multiplier - documentViewOperator.topSafeAreaInset - documentViewOperator.navigationBarHeight - documentViewOperator.chipsBarHeight)
                        
                        if visibility != documentViewOperator.shouldShowNavigationBar {
                            documentViewOperator.setShowNavigationBar(visibility)
                        }
                    }
                }
            })
        }
        .background {
            if let background = segment.background ?? document.background,
               themeManager.currentTheme == .light || (
                colorScheme == .light && themeManager.currentTheme == .auto
               )
            {
                AsyncImage(url: background) { image in
                    image.image?
                        .resizable()
                        .scaledToFill()
                }
            }
        }
        .background(themeManager.backgroundColor)
        .clipped()
        .id(segment.id)
    }
}
