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

struct SegmentChip: View {
    var segments: [Segment]
    @EnvironmentObject var documentViewOperator: DocumentViewOperator
    
    @State private var animatedActiveTab: Int = 0
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(segments.enumerated()), id:\.offset) { index, segment in
                    Button(action: {
                        documentViewOperator.activeTab = index
                    }) {
                        Text(segment.title)
                            .padding([.vertical], 4)
                            .padding([.horizontal], 8)
                            .background(index == documentViewOperator.activeTab ? Color.black : Color.white)
                            .foregroundColor(index == documentViewOperator.activeTab ? .white : .black)
                            .font(.caption)
                            .cornerRadius(3)
                    }
                    
                }
            }.frame(maxWidth: .infinity, alignment: .leading).padding(20)
        }
    }
}
