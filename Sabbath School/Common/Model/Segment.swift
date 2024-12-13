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

enum SegmentType: String, Codable {
    case block
    case story
    case pdf
    case video
}


struct ServerDate: Codable {
    let date: Date
    
    init(date: Date) {
        self.date = date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        guard let date = Date.serverDateFormatter().date(from: dateString) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date string does not match format 'dd/MM/yyyy'")
        }
        self.date = date
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let dateString = Date.serverDateFormatter().string(from: date)
        try container.encode(dateString)
    }
}

struct Segment: Codable, Identifiable, Equatable, Hashable {
    static func == (lhs: Segment, rhs: Segment) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String
    let name: String
    let index: String
    let type: SegmentType
    let resourceId: String
    let title: String
    let markdownTitle: String?
    let subtitle: String?
    let markdownSubtitle: String?
    let titleBelowCover: Bool?
    let cover: URL?
    let blocks: [AnyBlock]?
    let style: Style?
    let date: ServerDate?
    let pdf: [PDFAux]?
    let video: [VideoClipSegment]?
    let background: URL?
    
    public var hasCover: Bool {
        return cover != nil
    }
}
