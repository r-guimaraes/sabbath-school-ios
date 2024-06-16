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

protocol StyledBlock {
    var nested: Bool { get }
    var defaultStyles: DefaultBlockStyles { get }
}

extension StyledBlock {
    public func alignmentValue(align: BlockStylePositionX) -> TextAlignment {
        let alignmentMatrix: [BlockStylePositionX: TextAlignment] = [
            .start: .leading,
            .end: .trailing,
            .center: .center
        ]
        return alignmentMatrix[align] ?? .leading
    }
    
    public func roundedPoints(rounded: Bool) -> CGFloat {
        return rounded ? 6.0 : 0
    }
    
    // TODO: potentially multiply by scale factor depending on the platform i.e iPad
    public func paddingPoints(size: BlockStyleSize) -> CGFloat {
        switch size {
        case .none:
            return 0
        case .base:
            return 20
        case .xs:
            return 5
        case .sm:
            return 10
        case .lg:
            return 30
        case .xl:
            return 40
        }
    }
    
    // TODO: multiply by users theme size
    public func sizePoints(size: TextStyleSize) -> CGFloat {
        switch size {
        case .base:
            return 20
        case .xs:
            return 14
        case .sm:
            return 16
        case .lg:
            return 24
        case .xl:
            return 26
        }
    }
    
    // Alignment
    public func getTextAlignment(block: AnyBlock?) -> TextAlignment {
        func resolveAlignment(from style: BlockStyle?, defaultAlignment: TextAlignment) -> TextAlignment {
            guard let alignment = style?.text?.align else {
                return defaultAlignment
            }
            return self.alignmentValue(align: alignment)
        }
        
        var alignment = resolveAlignment(from: defaultStyles.inline?.all, defaultAlignment: .leading)
        
        if nested {
            alignment = resolveAlignment(from: defaultStyles.nested?.all, defaultAlignment: alignment)
        }
        
        if let block = block {
            // Global default style for that type of block
            alignment = resolveAlignment(from: defaultStyles.inline?.blocks?.first { $0.type == block.type }?.style, defaultAlignment: alignment)
            
            if nested {
                alignment = resolveAlignment(from: defaultStyles.nested?.blocks?.first { $0.type == block.type }?.style, defaultAlignment: alignment)
            }
            
            // Style for that specific block
            if let style = block.style {
                alignment = resolveAlignment(from: style, defaultAlignment: alignment)
            }
        }
        
        return alignment
    }
    
    // Fonts
    public func getTypeface(block: AnyBlock?, textSize: CGFloat, defaultFont: UIFont) -> UIFont {
        func resolveFont(from style: BlockStyle?, defaultFont: UIFont) -> UIFont {
            guard let typeface = style?.text?.typeface else {
                return defaultFont
            }
            return UIFont(name: typeface, size: textSize) ?? defaultFont
        }
        
        var typeface = resolveFont(from: defaultStyles.inline?.all, defaultFont: defaultFont)
        
        if nested {
            typeface = resolveFont(from: defaultStyles.nested?.all, defaultFont: typeface)
        }
        
        if let block = block {
            // Global default style for that type of block
            typeface = resolveFont(from: defaultStyles.inline?.blocks?.first { $0.type == block.type }?.style, defaultFont: typeface)
            
            if nested {
                typeface = resolveFont(from: defaultStyles.nested?.blocks?.first { $0.type == block.type }?.style, defaultFont: typeface)
            }
            
            // Style for that specific block
            if let style = block.style {
                typeface = resolveFont(from: style, defaultFont: typeface)
            }
        }
        
        return typeface
    }
    
    // Text sizes
    public func getTextSize(block: AnyBlock?, defaultTextSize: CGFloat) -> CGFloat {
        func resolveTextSize(from style: BlockStyle?, defaultTextSize: CGFloat) -> CGFloat {
            guard let textSize = style?.text?.size else {
                return defaultTextSize
            }
            return self.sizePoints(size: textSize)
        }
        
        var textSize = resolveTextSize(from: defaultStyles.inline?.all, defaultTextSize: defaultTextSize)
        
        if nested {
            textSize = resolveTextSize(from: defaultStyles.nested?.all, defaultTextSize: textSize)
        }
        
        if let block = block {
            // Global default style for that type of block
            textSize = resolveTextSize(from: defaultStyles.inline?.blocks?.first { $0.type == block.type }?.style, defaultTextSize: textSize)
            
            if nested {
                textSize = resolveTextSize(from: defaultStyles.nested?.blocks?.first { $0.type == block.type }?.style, defaultTextSize: textSize)
            }
            
            // Style for that specific block
            if let style = block.style {
                textSize = resolveTextSize(from: style, defaultTextSize: textSize)
            }
        }
        
        return textSize
    }
    
    public func getBlockRounded(block: AnyBlock?, defaultRounded: CGFloat = 0.0) -> CGFloat {
        func resolveRounded(from style: BlockStyle?, defaultRounded: CGFloat) -> CGFloat {
            guard let rounded = style?.block?.rounded else {
                return defaultRounded
            }
            return roundedPoints(rounded: rounded)
        }
        
        var rounded = resolveRounded(from: defaultStyles.inline?.all, defaultRounded: defaultRounded)
        
        if nested {
            rounded = resolveRounded(from: defaultStyles.nested?.all, defaultRounded: rounded)
        }
        
        if let block = block {
            // Global default style for that type of block
            
            rounded = resolveRounded(from: defaultStyles.inline?.blocks?.first { $0.type == block.type }?.style, defaultRounded: rounded)
            
            if nested {
                rounded = resolveRounded(from: defaultStyles.nested?.blocks?.first { $0.type == block.type }?.style, defaultRounded: rounded)
            }
            
            // Style for that specific block
            if let style = block.style {
                rounded = resolveRounded(from: style, defaultRounded: rounded)
            }
        }
        
        return rounded
    }
    
    // Colors
    public func getBlockTextColor(block: AnyBlock?) -> Color {
        let defaultColor: Color = .black | .white
        
        func resolveColor(from style: BlockStyle?, defaultColor: Color) -> Color {
            guard let textColor = style?.text?.color else {
                return defaultColor
            }
            return Color(UIColor(hex: textColor))
        }
        
        var textColor = resolveColor(from: defaultStyles.inline?.all, defaultColor: defaultColor)
        
        if nested {
            textColor = resolveColor(from: defaultStyles.nested?.all, defaultColor: textColor)
        }
        
        if let block = block {
            // Global default style for that type of block
            textColor = resolveColor(from: defaultStyles.inline?.blocks?.first { $0.type == block.type }?.style, defaultColor: textColor)
            
            if nested {
                textColor = resolveColor(from: defaultStyles.nested?.blocks?.first { $0.type == block.type }?.style, defaultColor: textColor)
            }
            
            // Style for that specific block
            if let style = block.style {
                textColor = resolveColor(from: style, defaultColor: textColor)
            }
        }
        
        return textColor | .white
    }
    
    public func getBlockBackgroundColor(block: AnyBlock?) -> Color {
        return getBackgroundColor(block: block, colorkeyPath: \.block?.backgroundColor)
    }
    
    public func getWrapperBackgroundColor(block: AnyBlock?) -> Color {
        return getBackgroundColor(block: block, colorkeyPath: \.wrapper?.backgroundColor)
    }
    
    private func getBackgroundColor(block: AnyBlock?, colorkeyPath: KeyPath<BlockStyle, String?>) -> Color {
        let defaultColor = Color.clear
        
        func resolveColor(from style: BlockStyle?, defaultColor: Color) -> Color {
            guard let hexString = style?[keyPath: colorkeyPath], !hexString.isEmpty else {
                return defaultColor
            }
            return Color(UIColor(hex: hexString))
        }
        
        var backgroundColor = resolveColor(from: defaultStyles.inline?.all, defaultColor: defaultColor)
        
        if nested {
            backgroundColor = resolveColor(from: defaultStyles.nested?.all, defaultColor: backgroundColor)
        }
        
        if let block = block {
            // Global default style for that type of block
            backgroundColor = resolveColor(from: defaultStyles.inline?.blocks?.first { $0.type == block.type }?.style, defaultColor: backgroundColor)
            
            if nested {
                backgroundColor = resolveColor(from: defaultStyles.nested?.blocks?.first { $0.type == block.type }?.style, defaultColor: backgroundColor)
            }
            
            // Style for that specific block
            if let style = block.style {
                backgroundColor = resolveColor(from: style, defaultColor: backgroundColor)
            }
        }
        
        return backgroundColor
    }
    
    // Paddings
    public func getWrapperPadding(block: AnyBlock?) -> EdgeInsets {
        return getPadding(block: block, paddingKeyPath: \.wrapper?.padding)
    }
    
    public func getBlockPadding(block: AnyBlock?) -> EdgeInsets {
        return getPadding(block: block, paddingKeyPath: \.block?.padding)
    }
    
    private func getPadding(block: AnyBlock?, paddingKeyPath: KeyPath<BlockStyle, SpacingStyle?>) -> EdgeInsets {
        let defaultPadding = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        func resolvePadding(from style: BlockStyle?, defaultPadding: EdgeInsets) -> EdgeInsets {
            return EdgeInsets(
                top: style?[keyPath: paddingKeyPath]?.top.flatMap { paddingPoints(size: $0) } ?? defaultPadding.top,
                leading: style?[keyPath: paddingKeyPath]?.start.flatMap { paddingPoints(size: $0) } ?? defaultPadding.leading,
                bottom: style?[keyPath: paddingKeyPath]?.bottom.flatMap { paddingPoints(size: $0) } ?? defaultPadding.bottom,
                trailing: style?[keyPath: paddingKeyPath]?.end.flatMap { paddingPoints(size: $0) } ?? defaultPadding.trailing
            )
        }
        
        // Global default style
        let baseStyle = nested ? defaultStyles.nested?.all : defaultStyles.inline?.all
        var padding = resolvePadding(from: baseStyle, defaultPadding: defaultPadding)

        if let block = block {
            // Global default style for that type of block
            let blockStyle = nested
                ? defaultStyles.nested?.blocks?.first { $0.type == block.type }?.style
                : defaultStyles.inline?.blocks?.first { $0.type == block.type }?.style
            padding = resolvePadding(from: blockStyle, defaultPadding: padding)
            
            // Style for that specific block
            if let style = block.style {
                padding = resolvePadding(from: style, defaultPadding: padding)
            }
        }

        return padding
    }
}
