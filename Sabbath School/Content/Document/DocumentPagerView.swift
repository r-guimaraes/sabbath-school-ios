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
import SwiftUIPager

extension DocumentView {
    func pagerView(_ resource: Resource, _ document: ResourceDocument, _ segments: [Segment]) -> some View {
        Pager(page: page, data: Array(0..<segments.count), id: \.self, content: { index in
            if let segment = segments[index] {
                switch segment.type {
                case .story:
                    SegmentViewStory(
                        segment: segment,
                        parentOffset: self.$pageOffset,
                        parentPage: self.$page
                    )
                    .environmentObject(documentViewOperator).tag(index)
                    .environment(\.defaultBlockStyles, document.style ?? Style(resource: nil, segment: nil, blocks: nil))
                case .pdf:
                    SegmentViewPDF(
                        segment: segment,
                        allowHorizontalSwipe: segments.count == 1,
                        showNavigationBarButtons: isActiveTabPDF
                    )
                    .environmentObject(documentViewOperator).tag(index)
                    .environment(\.defaultBlockStyles, document.style ?? Style(resource: nil, segment: nil, blocks: nil))
                    .environmentObject(viewModel)
                case .block:
                    SegmentView(
                        resource: resource,
                        segment: segment,
                        index: index,
                        document: document
                    )
                    .environmentObject(documentViewOperator).tag(index)
                    .environment(\.defaultBlockStyles, document.style ?? Style(resource: nil, segment: nil, blocks: nil))
                    .environmentObject(themeManager)
                default:
                    Text("")
                }
            }
        })
        .pageOffset(pageOffset)
        .preferredItemSize(CGSize(width: screenSizeMonitor.screenSize.width, height: screenSizeMonitor.screenSize.height))
        .onPageWillChange({ pageIndex in
            documentViewOperator.activeTab = pageIndex
        })
        .onAppear {
            documentViewOperator.setShowTabBar(documentViewOperator.shouldShowTabBar(), tab: documentViewOperator.activeTab, force: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: screenSizeMonitor.screenSize.width)
        .background(themeManager.backgroundColor)
        
        //                   TabView (selection: $documentViewOperator.activeTab) {
        //                        ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
        //                            switch segment.type {
        //                            case .story:
        //                                SegmentViewStory(segment: segment, index: index)
        //                                    .environmentObject(documentViewOperator).tag(index)
        //                                    .environment(\.defaultBlockStyles, document.style!)
        //                            case .pdf:
        //                                NavigationStack {
        //                                    SegmentViewPDF(segment: segment, index: index, pdfTabbedViewController: $pdfTabbedViewController)
        //                                        .environmentObject(documentViewOperator).tag(index)
        //                                        .environment(\.defaultBlockStyles, document.style!)
        //                                        .environmentObject(viewModel)
        //                                        .frame(maxWidth: .infinity, alignment: .leading)
        //                                        .frame(width: screenSizeMonitor.screenSize.width, height: screenSizeMonitor.screenSize.height)
        //                                }
        //                            case .block:
        //                                SegmentView(resource: resource, segment: segment, index: index, document: document)
        //                                    .environmentObject(documentViewOperator).tag(index)
        //                                    .environment(\.defaultBlockStyles, document.style ?? Style(resource: nil, segment: nil, blocks: nil))
        //                                    .environmentObject(themeManager)
        //
        //                            default:
        //                                EmptyView()
        //                            }
        //                        }
        //                    }
        //                    .onAppear {
        //                        documentViewOperator.setShowTabBar(documentViewOperator.shouldShowTabBar(), tab: documentViewOperator.activeTab, force: true)
        //                    }
        //                    .tabViewStyle(.page(indexDisplayMode: .automatic))
        //                    .frame(maxWidth: .infinity, alignment: .leading)
        //                    .frame(width: screenSizeMonitor.screenSize.width, height: screenSizeMonitor.screenSize.height)
    }
}
