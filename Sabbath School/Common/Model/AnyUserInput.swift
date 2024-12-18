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

protocol UserInputProtocol: Codable {
    var blockId: String { get }
    var inputType: UserInputType { get }
}

enum UserInputType: String, Codable {
    case annotation,
         appeal,
         checklist,
         comment,
         highlights,
         multipleChoice = "multiple-choice",
         poll,
         question,
         unknown
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        self = UserInputType(rawValue: rawValue) ?? .unknown
    }
}

struct AnyUserInput: UserInputProtocol, Decodable, Hashable {
    private let _base: any UserInputProtocol
    
    var id: String = UUID().uuidString
    
    var blockId: String {
        return _base.blockId
    }
    
    var inputType: UserInputType {
        return _base.inputType
    }
    
    init(_ base: any UserInputProtocol) {
        self._base = base
    }
    
    func encode(to encoder: Encoder) throws {
        try _base.encode(to: encoder)
    }
    
    private enum CodingKeys: String, CodingKey {
        case blockId
        case inputType
    }
    
    func asType<T: UserInputProtocol>(_ type: T.Type) -> T? {
        return _base as? T
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let blockId = try container.decode(String.self, forKey: .blockId)
        let inputType = try container.decode(UserInputType.self, forKey: .inputType)
        
        switch inputType {
        case .appeal:
            _base = try UserInputAppeal(from: decoder)
        case .checklist:
            _base = try UserInputChecklist(from: decoder)
        case .comment:
            _base = try UserInputComment(from: decoder)
        case .highlights:
            _base = try UserInputHighlights(from: decoder)
        case .multipleChoice:
            _base = try UserInputMultipleChoice(from: decoder)
        case .poll:
            _base = try UserInputPoll(from: decoder)
        case .question:
            _base = try UserInputQuestion(from: decoder)
        case .annotation:
            _base = try UserInputAnnotation(from: decoder)
        default:
            _base = try UserInputUnknown(from: decoder)
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
