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
import SwiftEntryKit

struct BlockExcerptView: StyledBlock, View {
    var block: Excerpt
    var biblePopup: Bool
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var selectedOption: String? = nil
    
    init(block: Excerpt, biblePopup: Bool = false) {
        self.block = block
        self.biblePopup = biblePopup
        self._selectedOption = State(initialValue: BlockExcerptView.selectFirstOption(for: block))
    }
    
    private static func selectFirstOption(for block: Excerpt) -> String? {
        return block.options.first ?? nil
    }
    
    private func findOption(option: String?) -> ExcerptItem? {
        return block.items.first(where: { $0.option == option }) ?? nil
    }
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                if biblePopup {
                    Button(action: {
                        SwiftEntryKit.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                    Spacer()
                }
                Menu {
                    ForEach(block.options, id: \.self) { option in
                        Button(option) {
                            selectedOption = option
                        }
                    }
                }
                label : {
                    HStack {
                        Text(selectedOption ?? "").font(.headline)
                            .foregroundColor(.black | .white) // Custom color
                            .frame(alignment: .leading)
                            .lineLimit(1)
                        Image(systemName: "chevron.down").tint(.black | .white).fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    
                    
                }
            }.padding(biblePopup ? [.vertical, .horizontal] : .vertical, 20)
            
            .frame(maxWidth: .infinity, alignment: .trailing)
            .transaction { transaction in
                transaction.animation = nil
            }
            
            if let selectedOptionItem = findOption(option: selectedOption) {
                if biblePopup {
                    ScrollView {
                        BlockWrapperView(block: AnyBlock(selectedOptionItem), parentBlock: AnyBlock(block)).padding(20)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                        .frame(maxHeight: .infinity)
                        
                } else {
                    BlockWrapperView(block: AnyBlock(selectedOptionItem), parentBlock: AnyBlock(block))
                }
            }
        }
    }
}

struct BlockExcerptItemView: StyledBlock, View {
    var block: ExcerptItem
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    var body: some View {
        VStack (spacing: 10) {
            ForEach(block.items) { item in
                BlockWrapperView(block: item, parentBlock: AnyBlock(block))
            }
        }
    }
}
