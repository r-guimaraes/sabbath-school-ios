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
                Text(AppStyle.Resource.Section.Title.text(section.title))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppStyle.Resource.Section.Title.padding)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(AppStyle.Resource.Section.Title.background)
                Divider().opacity(0.5)
            }

            ForEach(section.documents) { document in
                ResourceLink(
                    externalURL: document.externalURL,
                    destination: DocumentView(documentIndex: document.index)
                ) {
                    sectionContentView(document: document)
                }
                
                Divider().opacity(0.5)
            }
        }
    }
    
    @ViewBuilder
    func sectionContentView(document: ResourceDocument) -> some View {
        HStack (spacing: AppStyle.Resource.Document.Spacing.padding) {
            if section.displaySequence {
                Text(AppStyle.Resource.Document.Sequence.text(document.sequence))
                    .multilineTextAlignment(.leading)
                    .lineLimit(AppStyle.Resource.Document.Sequence.lineLimit)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(2)
            }
            
            HStack {
                VStack (spacing: AppStyle.Resource.Document.Spacing.betweenTitleSubtitleAndDate) {
                    if let subtitle = document.subtitle {
                        Text(AppStyle.Resource.Document.Subtitle.text(subtitle))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .lineLimit(AppStyle.Resource.Document.Subtitle.lineLimit)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Text(AppStyle.Resource.Document.Title.text(document.title))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .lineLimit(AppStyle.Resource.Document.Title.lineLimit)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if let startDate = document.startDate,
                       let endDate = document.endDate {
                        let stringDate = "\(startDate.date.stringLessonDate()) - \(endDate.date.stringLessonDate())"
                        Text(AppStyle.Resource.Document.Date.text(stringDate))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .lineLimit(AppStyle.Resource.Document.Date.lineLimit)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, AppStyle.Resource.Document.Spacing.padding)
                .frame(maxWidth: .infinity)
                .layoutPriority(1)
                Spacer()
                if document.externalURL != nil {
                    Image(systemName: "arrow.up.forward.square")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.secondary)
                }
            }
        }.padding(.horizontal, AppStyle.Resource.Document.Spacing.padding)
    }
}
