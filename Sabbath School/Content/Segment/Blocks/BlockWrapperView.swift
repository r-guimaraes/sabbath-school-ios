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

import Foundation
import SwiftUI

struct BlockWrapperView: StyledBlock, View {
    var block: AnyBlock
    @Environment(\.nested) var nested: Bool
    @Environment(\.defaultBlockStyles) var defaultStyles: DefaultBlockStyles
    
    @State private var dropShadow = false
    
    var parentBlock: AnyBlock?
    
    var body: some View {
        VStack (spacing: 0) {
            VStack (spacing: 0) {
                switch block.type {
                case .paragraph:
                    if let paragraph = block.asType(Paragraph.self) {
                        BlockParagraphView(block: paragraph)
                    }
                case .excerpt:
                    if let excerpt = block.asType(Excerpt.self) {
                        BlockExcerptView(block: excerpt)
                    }
                case .excerptItem:
                    if let excerptItem = block.asType(ExcerptItem.self) {
                        BlockExcerptItemView(block: excerptItem)
                    }
                case .list:
                    if let list = block.asType(List.self) {
                        BlockListView(block: list)
                    }
                case .listItem:
                    if let listItem = block.asType(ListItem.self) {
                        BlockListItemView(block: listItem, parentBlock: parentBlock)
                    }
                case .checklist:
                    if let checklist = block.asType(Checklist.self) {
                        BlockChecklistView(block: checklist)
                    }
                case .checklistItem:
                    if let checklistItem = block.asType(ChecklistItem.self) {
                        BlockChecklistItemView(block: checklistItem, parentBlock: parentBlock)
                    }
                case .heading:
                    if let heading = block.asType(Heading.self) {
                        BlockHeadingView(block: heading)
                    }
                case .blockquote:
                    if let blockquote = block.asType(Blockquote.self) {
                        BlockBlockquoteView(block: blockquote)
                    }
                case .collapse:
                    if let collapse = block.asType(Collapse.self) {
                        BlockCollapseView(block: collapse)
                    }
                case .appeal:
                    if let appeal = block.asType(Appeal.self) {
                        BlockAppealView(block: appeal)
                    }
                case .question:
                    if let question = block.asType(Question.self) {
                        BlockQuestionView(block: question)
                    }
                case .reference:
                    if let reference = block.asType(Reference.self) {
                        BlockReferenceView(block: reference)
                    }
                case .hr:
                    if let hr = block.asType(Hr.self) {
                        BlockHrView(block: hr)
                    }
                case .image:
                    if let image = block.asType(BlockImage.self) {
                        BlockImageView(block: image)
                    }
                default:
                    Text("Nothing").multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                }
            }.onAppear {
                if let _ = block.asType(Question.self) {
                    dropShadow = true
                }
            }
            .padding(getBlockPadding(block: block))
            .background(getBlockBackgroundColor(block: block))
            .cornerRadius(getBlockRounded(block: block))
            .shadow(color: .gray.opacity(0.5), radius: dropShadow ? 5 : 0)
        }
        .padding(getWrapperPadding(block: block))
        .background(getWrapperBackgroundColor(block: block))
//        .border(.red)
    }
}
