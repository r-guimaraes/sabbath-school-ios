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

@ViewBuilder
func SegmentHeader(_ title: String, _ date: ServerDate?, _ subtitle: String?, _ hasCover: Bool, _ style: Style?) -> some View {
    VStack (spacing: AppStyle.Resources.Segment.Spacing.betweenTitleDateAndSubtitle) {
        if let subtitle = subtitle {
            VStack (spacing: 0) {
                Text(AppStyle.Resources.Segment.Subtitle.text(subtitle, hasCover, style))
                    .multilineTextAlignment(Styler.getTextAlignment(style, SegmentSubtitleStyleTemplate()))
                    .lineLimit(AppStyle.Resources.Segment.Subtitle.lineLimit)
                    .fixedSize(horizontal: false, vertical: true)
            }.frame(maxWidth: .infinity, alignment: Styler.convertTextAlignment(Styler.getTextAlignment(style, SegmentSubtitleStyleTemplate())))
        }
        
        if let date = date {
            VStack (spacing: 0) {
                Text(AppStyle.Resources.Segment.Date.text(
                    date.date.stringReadDate()
                        .replacingLastOccurrence(of: Constants.StringsToBeReplaced.saturday,
                                                 with: Constants.StringsToBeReplaced.sabbath),
                    hasCover, style)
                )
                .multilineTextAlignment(Styler.getTextAlignment(style, SegmentDateStyleTemplate()))
                .lineLimit(AppStyle.Resources.Segment.Date.lineLimit)
                .fixedSize(horizontal: false, vertical: true)
            }.frame(maxWidth: .infinity, alignment: Styler.convertTextAlignment(Styler.getTextAlignment(style, SegmentDateStyleTemplate())))
        }
        
        VStack {
            Text(AppStyle.Resources.Segment.Title.text(title, hasCover, style))
                .multilineTextAlignment(Styler.getTextAlignment(style, SegmentTitleStyleTemplate()))
                .lineLimit(AppStyle.Resources.Segment.Title.lineLimit)
                .fixedSize(horizontal: false, vertical: true)
        }.frame(maxWidth: .infinity, alignment: Styler.convertTextAlignment(Styler.getTextAlignment(style, SegmentTitleStyleTemplate())))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, AppStyle.Resources.Segment.Spacing.horizontalPaddingHeader)
    .padding(.vertical, AppStyle.Resources.Segment.Spacing.verticalPaddingHeader)
    
}

struct SegmentView: View {
    var resource: Resource
    var segment: Segment
    var index: Int
    var document: ResourceDocument
    
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    @EnvironmentObject var documentViewOperator: DocumentViewOperator
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    private enum CoordinateSpaces {
        case scrollView
    }
    
    private var hasCover: Bool {
        return segment.cover != nil || document.cover != nil
    }
    
    private var titleBelowCover: Bool {
        return (document.titleBelowCover != nil && document.titleBelowCover == true)
        || (segment.titleBelowCover != nil && segment.titleBelowCover == true)
    }
    
    private var style: Style? {
        return segment.style ?? document.style ?? resource.style
    }
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack(spacing: 0) {
                if let cover = segment.cover ?? document.cover, hasCover {
                    ZStack (alignment: .bottom) {
                        ParallaxHeader(
                            coordinateSpace: CoordinateSpaces.scrollView,
                            defaultHeight: AppStyle.Resources.Segment.Cover.height()
                        ) {
                            LazyImage(url: cover) { image in
                                image.image?.resizable().scaledToFill()
                            }
                        }.id(segment.index)
                        
                        if !titleBelowCover {
                            SegmentHeader(segment.markdownTitle ?? segment.title,
                                          segment.date,
                                          segment.markdownSubtitle ?? segment.subtitle,
                                          hasCover && !titleBelowCover,
                                          segment.style ?? resource.style)
                        }
                    }.frame(height: AppStyle.Resources.Segment.Cover.height())
                }
                
                VStack {
                    if !hasCover || titleBelowCover {
                        SegmentHeader(segment.markdownTitle ?? segment.title,
                                      segment.date,
                                      segment.markdownSubtitle ?? segment.subtitle,
                                      hasCover && !titleBelowCover,
                                      segment.style ?? resource.style)
                        .padding(.top, hasCover || (hasCover && titleBelowCover) ? 20 : AppStyle.Resources.Segment.Cover.height(false))
                    }
                }.background(
                    themeManager.backgroundColor
                )
                
                if let blocks = segment.blocks {
                    VStack (spacing: AppStyle.Resources.Segment.Spacing.betweenBlocks)  {
                        ForEach(blocks) { block in
                            BlockWrapperView(block: block)
                                .environment(\.themeManager, themeManager)
                                .environment(\.defaultBlockStyles, defaultStyles)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.bottom, documentViewOperator.tabBarHeight + documentViewOperator.bottomSafeAreaInset + AppStyle.Resources.Segment.Spacing.verticalPaddingContent +
                             (documentViewOperator.showMiniPlayer ? 80 : 0)
                    )
                    .padding(.top, AppStyle.Resources.Segment.Spacing.verticalPaddingContent)
                    .padding(.horizontal, AppStyle.Resources.Segment.Spacing.horizontalPaddingContent(screenSizeMonitor.screenSize.width))
                    .background(themeManager.backgroundColor)
                }
            }
            .onChange(of: sizeCategory) { newValue in }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GeometryReader { geometry in
                Color.clear.onChange(of: geometry.frame(in: .named(CoordinateSpaces.scrollView)).minY) { scrollOffset in
                    if index == documentViewOperator.activeTab {
                        let multiplier = AppStyle.Resources.Segment.Cover.percentageOfScreen(hasCover)
                        
                        let visibility = scrollOffset <= -1 * (UIScreen.main.bounds.height * multiplier - documentViewOperator.topSafeAreaInset - documentViewOperator.navigationBarHeight - documentViewOperator.chipsBarHeight)
                        
                        if visibility != documentViewOperator.shouldShowNavigationBar {
                            documentViewOperator.setShowNavigationBar(visibility)
                        }
                    }
                }
            })
        }
    }
}
