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

struct FeedGroupView: View {
    var resourceType: ResourceType
    var feedGroup: FeedGroup
    var displayFeedGroupTitle: Bool = true
    var displaySeeAllButton: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            if (displayFeedGroupTitle || displaySeeAllButton) {
                HStack {
                    if displayFeedGroupTitle {
                        Text(AttributedString(AppStyle.Quarterly.Text.groupName(string:feedGroup.title)))
                    }
                    Spacer()
                    if displaySeeAllButton {
                        NavigationLink {
                            FeedSeeAllView(resourceType: resourceType, feedGroupName: feedGroup.name)
                        } label: {
                            Text(AttributedString(AppStyle.Quarterly.Text.seeMore(string: "See All".localized())))
                        }
                    }
                    
                }.padding(20)
            }
            if let resources = feedGroup.resources {
                ScrollView(feedGroup.direction == .horizontal ? .horizontal : .vertical, showsIndicators: false) {
                    if feedGroup.direction == .horizontal {
                        HStack(spacing: 20) {
                            ForEach(resources) { resource in
                                NavigationLink {
                                    ResourceView(resourceIndex: feedGroup.resources!.first!.index)
                                } label: {
                                    FeedResourceView(resource: feedGroup.resources!.first!, feedGroupViewType: feedGroup.view, feedGroupDirection: feedGroup.direction)
                                }
                            }
                        }.padding(20)
                    } else {
                        VStack(spacing: 20) {
                            ForEach(resources) { resource in
                                NavigationLink {
                                    ResourceView(resourceIndex: feedGroup.resources!.first!.index)
                                } label: {
                                    FeedResourceView(resource: feedGroup.resources!.first!, feedGroupViewType: feedGroup.view, feedGroupDirection: feedGroup.direction)
                                }
                            }
                        }
                        .padding(20)
                    }
                }.padding(0)
                    .conditionalBackground(hex: feedGroup.backgroundColor)
                
            }
        }
        .padding(0)
    }
}
