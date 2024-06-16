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

struct BlockBlockquoteView: StyledBlock, View {
    var block: Blockquote
    @Environment(\.nested) var nested: Bool
    @Environment(\.defaultBlockStyles) var defaultStyles: DefaultBlockStyles
    
    var body: some View {
        HStack (spacing: 0) {
            VStack (spacing: 10) {
                ForEach(block.items) { item in
                    BlockWrapperView(block: item, parentBlock: AnyBlock(block))
                        .environment(\.nested, true)
                }
            }.padding(10)
                .overlay {
                    VStack (spacing: 0) {
                        if !(block.callout ?? false) {
                            Rectangle().cornerRadius(2).frame(maxWidth: 3, maxHeight: .infinity).frame(minHeight: 0).background(.black)
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
        }.frame(maxWidth: .infinity)
    }
}
