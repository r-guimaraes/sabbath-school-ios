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

protocol BlockProtocol: Codable, Identifiable, Hashable {
    var id: String { get }
    var type: BlockType { get }
    var style: BlockStyle? { get }
    var data: BlockData? { get }
    var nested: Bool? { get }
}

extension BlockProtocol {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

enum BlockType: String, Codable {
    case appeal,
         audio,
         blockquote,
         checklist,
         checklistItem = "list-item-checklist",
         collapse,
         excerpt, excerptItem = "excerpt-item",
         heading,
         hr,
         image,
         list, listItem = "list-item",
         multipleChoice = "multiple-choice", multipleChoiceItem = "list-item-choice",
         paragraph,
         poll,
         pollItem = "poll-item",
         reference,
         story,
         storySlide,
         table,
         question,
         video,
         unknown
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        self = BlockType(rawValue: rawValue) ?? .unknown
    }
}

struct AnyBlock: BlockProtocol, Decodable {
    private let _base: any BlockProtocol
    
    var id: String {
        return _base.id
    }
    
    var type: BlockType {
        return _base.type
    }
    
    var style: BlockStyle? {
        return _base.style
    }
    
    var data: BlockData? {
        return _base.data
    }
    
    var nested: Bool? {
        return _base.nested
    }
    
    init(_ base: any BlockProtocol) {
        self._base = base
    }
    
    func encode(to encoder: Encoder) throws {
        try _base.encode(to: encoder)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(BlockType.self, forKey: .type)
        let nested = try container.decodeIfPresent(Bool.self, forKey: .nested)
//        let style = try container.decodeIfPresent(BlockStyle.self, forKey: .style)
        
        switch type {
        case .appeal:
            _base = try Appeal(from: decoder)
        case .audio:
            _base = try AudioBlock(from: decoder)
        case .blockquote:
            _base = try Blockquote(from: decoder)
        case .checklist:
            _base = try Checklist(from: decoder)
        case .checklistItem:
            _base = try ChecklistItem(from: decoder)
        case .collapse:
            _base = try Collapse(from: decoder)
        case .excerpt:
            _base = try Excerpt(from: decoder)
        case .excerptItem:
            _base = try ExcerptItem(from: decoder)
        case .heading:
            _base = try Heading(from: decoder)
        case .hr:
            _base = try Hr(from: decoder)
        case .image:
            _base = try BlockImage(from: decoder)
        case .list:
            _base = try List(from: decoder)
        case .listItem:
            _base = try ListItem(from: decoder)
        case .multipleChoice:
            _base = try MultipleChoice(from: decoder)
        case .multipleChoiceItem:
            _base = try MultipleChoiceItem(from: decoder)
        case .paragraph:
            _base = try Paragraph(from: decoder)
        case .poll:
            _base = try Poll(from: decoder)
        case .pollItem:
            _base = try PollItem(from: decoder)
        case .reference:
            _base = try Reference(from: decoder)
        case .story:
            _base = try Story(from: decoder)
        case .storySlide:
            _base = try StorySlide(from: decoder)
        case .table:
            _base = try TableBlock(from: decoder)
        case .question:
            _base = try Question(from: decoder)
        case .video:
            _base = try VideoBlock(from: decoder)
        default:
            _base = try Unknown(from: decoder)
        }
    }
    
    func asType<T: BlockProtocol>(_ type: T.Type) -> T? {
        return _base as? T
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case style
        case data
        case nested
    }
}
