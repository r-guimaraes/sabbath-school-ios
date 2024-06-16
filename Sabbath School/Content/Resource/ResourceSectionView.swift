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
            if (section.isRoot == nil && displaySectionName) {
                Text(section.title).frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .background(.gray.opacity(0.1))
            }

            ForEach(section.documents) { document in
                NavigationLink {
                    DocumentView(documentIndex: document.index)
                } label: {
                    VStack (spacing: 5) {
                        if let subtitle = document.subtitle {
                            Text(subtitle).frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.gray)
                        }
                        Text(document.title).frame(maxWidth: .infinity, alignment: .leading)
                        if let startDate = document.startDate,
                           let endDate = document.endDate {
                            Text("\(startDate.stringLessonDate()) - \(endDate.stringLessonDate())").frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }.padding(20)
                }
            }
        }
    }
}
