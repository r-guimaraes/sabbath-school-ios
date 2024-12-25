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

struct ProgressSaveButton: View {
    var progressTrackingTitle: String
    var progressTrackingSubtitle: String?
    var progressNextSegmentIteratorIndex: Int?
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var documentViewModel: DocumentViewModel
    @EnvironmentObject var documentViewOperator: DocumentViewOperator
    @EnvironmentObject var resourceViewModel: ResourceViewModel
    @Environment(\.dismissAction) private var dismissAction

    var body: some View {
        Button(action: {
            if let documentId = documentViewModel.document?.id, progressNextSegmentIteratorIndex == nil {
                Task {
                    await resourceViewModel.saveProgress(documentId: documentId, force: true)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    dismissAction?()
                }
            } else if let progressNextSegmentIteratorIndex = progressNextSegmentIteratorIndex {
                documentViewOperator.activeTab = progressNextSegmentIteratorIndex
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }) {
           HStack(spacing: 10) {
                VStack {
                    Text(AppStyle.Segment.Progress.saveButtonTitle(progressTrackingTitle))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let progressTrackingSubtitle = progressTrackingSubtitle {
                        Text(AppStyle.Segment.Progress.saveButtonSubtitle(progressTrackingSubtitle))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                if progressNextSegmentIteratorIndex != nil {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.secondary)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.green)
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(AppStyle.Block.Reference.backgroundColor(theme: themeManager.currentTheme))
            .contentShape(Capsule())
            .clipShape(Capsule())
        }
        .frame(maxWidth: 500)
        .padding(.horizontal, 20)
    }
}
