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

struct InlineAttributedText: StyledBlock, View {
    var block: AnyBlock
    var markdown: String
    @Environment(\.nested) var nested: Bool
    @Environment(\.defaultBlockStyles) var defaultStyles: DefaultBlockStyles
    
    var body: some View {
        let defaultTextSize: CGFloat = sizePoints(size: .base)
        let textSize: CGFloat = getTextSize(block: AnyBlock(block), defaultTextSize: defaultTextSize)
        let defaultTypeface = R.font.latoRegular(size: textSize)!
        
        var attributedString = try! AttributedString(markdown: markdown, including: \.sspmApp)
        attributedString.font = getTypeface(block: block, textSize: textSize, defaultFont: defaultTypeface)
        attributedString.foregroundColor = getBlockTextColor(block: block)
        
        
        
        attributedString = annotateCustomAttributes(from: attributedString, defaultTextSize: textSize)
        
        let alignment = getTextAlignment(block: block)

        return Text(attributedString)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(alignment).environment(\.openURL, OpenURLAction { url in
                
                if let paragraph = block.asType(Paragraph.self),
                   let data = paragraph.data,
                   let bible = data.bible,
                    url.absoluteString.contains("sspmBible") {

                    let hostingController = UIHostingController(rootView: ResourceBibleView(block: bible))
                    hostingController.view.layer.cornerRadius = 6

                    SwiftEntryKit.display(entry: hostingController, using: Animation.modalAnimationAttributes(widthRatio: 0.9, heightRatio: 0.8, backgroundColor: Preferences.currentTheme().backgroundColor))
                }
                return .handled
            })
            
    }
    
    private func annotateCustomAttributes(from source: AttributedString, defaultTextSize: CGFloat) -> AttributedString {
        var attrString = source
        
        for run in attrString.runs {
            if  let style = run.style,
                let text = style.text {
                var inlineTextSize = defaultTextSize
                
                if let offset = text.offset {
                    attrString[run.range].baselineOffset = offset == .sup ? 6 : -6
                    inlineTextSize /= 1.5
                }
                
                if let size = text.size {
                    // Case where the size is set
                    inlineTextSize = sizePoints(size: size)
                }
                
                if let typeface = text.typeface {
                    // Case where typeface is specified
                    attrString[run.range].font = UIFont(name: typeface, size: inlineTextSize)
                } else if inlineTextSize != defaultTextSize {
                    // Case where text size is set but typeface is not specified
                    attrString[run.range].font = attrString[run.range].font?.withSize(inlineTextSize)

                }
                
                if let color = text.color {
                    // Case where color is set in the inline markdown attributes
                    attrString[run.range].foregroundColor = Color(UIColor(hex: color))
                }
            }
            
            // Highlight links
            if run.link != nil {
                if attrString[run.range].font == R.font.latoRegular(size: defaultTextSize)! {
                    attrString[run.range].font = R.font.latoBold(size: defaultTextSize)!
                }
                attrString[run.range].underlineStyle = Text.LineStyle(pattern: .solid, color: .blue)
                
            }
        }
        
        return attrString
    }
}
