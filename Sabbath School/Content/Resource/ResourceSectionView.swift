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

struct ResourceSectionView: View {
    var section: ResourceSection
    var displaySectionName: Bool = true
    
    var body: some View {
        VStack (spacing: 0) {
            if !section.isRoot && displaySectionName {
                Text(AppStyle.Resources.Resource.Section.Title.text(section.title))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppStyle.Resources.Resource.Section.Title.padding)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(AppStyle.Resources.Resource.Section.Title.background)
                Divider().opacity(0.5)
            }

            ForEach(section.documents) { document in
                NavigationLink {
                    DocumentView(documentIndex: document.index)
                } label: {
                    HStack (spacing: AppStyle.Resources.Resource.Document.Spacing.padding) {
                        if section.displaySequence {
                            Text(AppStyle.Resources.Resource.Document.Sequence.text(document.sequence))
                                .multilineTextAlignment(.leading)
                                .lineLimit(AppStyle.Resources.Resource.Document.Sequence.lineLimit)
                                .fixedSize(horizontal: false, vertical: true)
                                .layoutPriority(2)
                        }
                        VStack (spacing: AppStyle.Resources.Resource.Document.Spacing.betweenTitleSubtitleAndDate) {
                            if let subtitle = document.subtitle {
                                Text(AppStyle.Resources.Resource.Document.Subtitle.text(subtitle))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(AppStyle.Resources.Resource.Document.Subtitle.lineLimit)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            Text(AppStyle.Resources.Resource.Document.Title.text(document.title))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .lineLimit(AppStyle.Resources.Resource.Document.Title.lineLimit)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            if let startDate = document.startDate,
                               let endDate = document.endDate,
                               let stringDate = "\(startDate.date.stringLessonDate()) - \(endDate.date.stringLessonDate())" {
                                Text(AppStyle.Resources.Resource.Document.Date.text(stringDate))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(AppStyle.Resources.Resource.Document.Date.lineLimit)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.vertical, AppStyle.Resources.Resource.Document.Spacing.padding)
                        .frame(maxWidth: .infinity)
                        .layoutPriority(1)
                    }.padding(.horizontal, AppStyle.Resources.Resource.Document.Spacing.padding)
                    
                }
                
                Divider().opacity(0.5)
            }
        }
    }
}
