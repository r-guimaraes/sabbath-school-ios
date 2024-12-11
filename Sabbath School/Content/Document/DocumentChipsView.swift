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
    func segmentChipsView() -> some View {
        VStack {
            SegmentChip(segments: viewModel.document?.segments ?? []).environmentObject(documentViewOperator)
        }.background {
            GeometryReader { geometry in
                Color.clear.onAppear {
                    documentViewOperator.chipsBarHeight = geometry.size.height
                    if documentViewOperator.chipsTopPadding == 0 {
                        documentViewOperator.chipsTopPadding = documentViewOperator.topSafeAreaInset + documentViewOperator.navigationBarHeight - geometry.safeAreaInsets.top
                    }
                }
            }
        }
        .padding(.top, documentViewOperator.chipsTopPadding)
        .background(documentViewOperator.shouldShowNavigationBar ? (.white | .black) : .clear)
        .overlay(
            Rectangle()
                .frame(height: documentViewOperator.shouldShowNavigationBar ? 1 : 0)
                .foregroundColor(.gray.opacity(0.4)),
            alignment: .bottom
        )
    }
}
