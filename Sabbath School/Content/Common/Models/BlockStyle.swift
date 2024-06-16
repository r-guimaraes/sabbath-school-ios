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

enum BlockStylePositionX: String, Codable {
    case start
    case end
    case center
}

enum BlockStylePositionY: String, Codable {
    case top
    case bottom
    case center
}

enum BlockStyleSize: String, Codable {
    case none
    case xs
    case sm
    case base
    case lg
    case xl
}

enum TextStyleSize: String, Codable {
    case xs
    case sm
    case base
    case lg
    case xl
}

enum TextStyleOffset: String, Codable {
    case sup
    case sub
}

struct BackgroundPositionStyle: Codable {
    let x: BlockStylePositionX
    let y: BlockStylePositionY
}

struct SpacingStyle: Codable {
    let top: BlockStyleSize?
    let bottom: BlockStyleSize?
    let start: BlockStyleSize?
    let end: BlockStyleSize?
}

struct BlockLevelStyle: Codable {
    let backgroundColor: String?
    let backgroundImage: URL?
    let backgroundPosition: BackgroundPositionStyle?
    let padding: SpacingStyle?
    let margin: SpacingStyle?
    let rounded: Bool?
}

struct BlockWrapperLevelStyle: Codable {
    let rounded: Bool?
    let backgroundColor: String?
    let backgroundImage: URL?
    let backgroundPosition: BackgroundPositionStyle?
    let padding: SpacingStyle?
    let margin: SpacingStyle?
    
}

struct BlockImageStyle: Codable {
    let aspectRatio: CGFloat?
    let rounded: Bool?
    let expandable: Bool?
}

struct BlockTextStyle: Codable {
    let typeface: String?
    let color: String?
    let size: TextStyleSize?
    let align: BlockStylePositionX?
    let offset: TextStyleOffset?
}

struct BlockStyle: Codable {
    let block: BlockLevelStyle?
    let wrapper: BlockWrapperLevelStyle?
    let image: BlockImageStyle?
    let text: BlockTextStyle?
}

struct DefaultBlockStyleOverride: Codable {
    let type: BlockType
    let style: BlockStyle
}

struct DefaultBlockStylesInline: Codable {
    let all: BlockStyle?
    let blocks: [DefaultBlockStyleOverride]?
}

struct DefaultBlockStylesNested: Codable {
    let all: BlockStyle?
    let blocks: [DefaultBlockStyleOverride]?
}

struct DefaultBlockStyles: Codable {
    let inline: DefaultBlockStylesInline?
    let nested: DefaultBlockStylesNested?
}
