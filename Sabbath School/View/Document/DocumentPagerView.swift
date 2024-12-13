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

extension DocumentView {
    func pagerView(_ resource: Resource, _ document: ResourceDocument, _ segments: [Segment]) -> some View {
        TabView (selection: $documentViewOperator.activeTab) {
            ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                switch segment.type {
                case .story:
                    SegmentViewStory(
                        segment: segment
                    )
                    .tag(index)

                case .pdf:
                    SegmentViewPDF(
                        segment: segment,
                        allowHorizontalSwipe: false,
                        showNavigationBarButtons: isActiveTabPDF
                    )
                    .tag(index)
                    .environmentObject(viewModel)
                    
                case .video:
                    SegmentViewBase(
                        resource: resource,
                        segment: segment,
                        index: index,
                        document: document
                    ) { cover, blocks, video in
                        VStack(spacing: 0) {
                            cover
                            video
                            blocks
                        }
                    }

                case .block:
                    SegmentViewBase(
                        resource: resource,
                        segment: segment,
                        index: index,
                        document: document
                    ) { cover, blocks, _ in
                        VStack(spacing: 0) {
                            cover
                            blocks
                        }
                    }
                    .tag(index)
                }
            }
        }.onAppear {
            documentViewOperator.setShowTabBar(documentViewOperator.shouldShowTabBar(), tab: documentViewOperator.activeTab, force: true)
        }
        .environmentObject(documentViewOperator)
        .environment(\.defaultBlockStyles, document.style ?? Style(resource: nil, segment: nil, blocks: nil))
        .background(themeManager.backgroundColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .id(document.id)
    }
}
