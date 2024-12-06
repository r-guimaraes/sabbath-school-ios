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

struct BlockReferenceView: StyledBlock, View {
    var block: Reference
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    var body: some View {
        NavigationLink {
            if let resource = block.resource,
               block.scope == .resource {
                ResourceView(resourceIndex: resource.index)
            }
            
            if let document = block.document,
               block.scope == .document {
                DocumentView(documentIndex: document.index)
            }
        } label: {
            HStack {
                if let resource = block.resource {
                    AsyncImage(url: resource.covers.square) { image in
                        image.image?.resizable()
                    }
                    .frame(width: 40, height: 40)
                    .cornerRadius(6)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
                }
                
                VStack (alignment: .leading, spacing: 5) {
                    InlineAttributedText(block: AnyBlock(self.block), markdown: block.title, selectable: false, lineLimit: 1)
                    
                    if let subtitle = block.subtitle {
                        InlineAttributedText(block: AnyBlock(self.block), markdown: subtitle, selectable: false, lineLimit: 2)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.black | .white)
            }.frame(maxWidth: .infinity)
        }.frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(.gray.opacity(0.6))
    }
}
