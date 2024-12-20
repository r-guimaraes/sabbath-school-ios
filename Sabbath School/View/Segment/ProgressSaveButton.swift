//
//  ProgressSaveButton.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2024-12-19.
//  Copyright © 2024 Adventech. All rights reserved.
//

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
//        .buttonStyle(.plain)
    }
}
