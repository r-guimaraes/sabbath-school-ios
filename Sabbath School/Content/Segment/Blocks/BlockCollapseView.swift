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

struct BlockCollapseView: StyledBlock, View {
    var block: Collapse
    @Environment(\.nested) var nested: Bool
    @Environment(\.defaultBlockStyles) var defaultStyles: DefaultBlockStyles
    
    @State var expanded: Bool = false
    
    var body: some View {
        VStack (spacing: 0) {
            VStack (spacing: 0) {
                Button {
                    expanded = !expanded
                } label: {
                    HStack {
                        Text(block.caption).frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(getBlockTextColor(block: AnyBlock(block)))
                        Spacer()
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(getBlockTextColor(block: AnyBlock(block)))
                    }.frame(maxWidth: .infinity)
                }.frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
            }.background(.gray)
                .clipShape(
                    RoundedCorner(
                        radius: 6,
                        corners: !expanded ? [.allCorners] : [.topLeft, .topRight]
                    )
                )
            
            
            if expanded {
                VStack (spacing: 0) {
                    VStack (spacing: 10) {
                        ForEach(block.items) { item in
                            BlockWrapperView(block: item, parentBlock: AnyBlock(block))
                                .environment(\.nested, true)
                        }
                    }.padding()
                }.background(.gray.opacity(0.1))
                 .clipShape(RoundedCorner(radius: 6, corners: [.bottomLeft, .bottomRight]))
            }
        }
    }
}
