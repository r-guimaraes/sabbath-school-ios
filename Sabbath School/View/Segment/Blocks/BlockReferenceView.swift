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
import NukeUI

struct BlockReferenceView: StyledBlock, View {
    var block: Reference
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @EnvironmentObject var themeManager: ThemeManager
    
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
                    LazyImage(url: resource.covers.square) { image in
                        image.image?.resizable()
                    }
                    .frame(width: AppStyle.Block.Reference.thumbnailSize.width, height: AppStyle.Block.Reference.thumbnailSize.height)
                    .cornerRadius(6)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
                }
                
                VStack (alignment: .leading, spacing: 5) {
                    Text(block.title)
                        .lineLimit(1)
                        .font(.custom("Lato-Regular", size: 16))
                        .foregroundColor(themeManager.getTextColor())
                    
                    if let subtitle = block.subtitle {
                        Text(subtitle)
                            .lineLimit(1)
                            .font(.custom("Lato-Medium", size: 14))
                            .foregroundColor(themeManager.getTextColor().opacity(0.7))
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.black | .white)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(AppStyle.Block.Reference.backgroundColor(theme: themeManager.currentTheme))
        .buttonStyle(.plain)
        .cornerRadius(6)
    }
}
