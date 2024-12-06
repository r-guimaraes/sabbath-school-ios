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

struct BlockListView: StyledBlock, View {
    var block: List
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    var body: some View {
        VStack (spacing: 10) {
            ForEach(block.items) { item in
                BlockWrapperView(block: item, parentBlock: AnyBlock(block))
            }
        }.frame(maxWidth: .infinity)
    }
}

struct BlockListItemView: StyledBlock, View {
    var block: ListItem
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    var parentBlock: AnyBlock?
    
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            if let listItemBullet = listItemBullet {
                InlineAttributedText(block: AnyBlock(block), markdown: listItemBullet)
                Spacer()
            }
            InlineAttributedText(block: AnyBlock(block), markdown: block.markdown, selectable: true).frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var listItemBullet: String? {
        guard let parent = parentBlock?.asType(List.self),
              let ordered = parent.ordered else {
            return nil
        }
        
        if let start = parent.start,
           let index = block.index,
           ordered {
            return "\(start + index)\\."
        }
        
        if !ordered {
            return "\(parent.bullet)"
        }
        
        return nil
    }
}
