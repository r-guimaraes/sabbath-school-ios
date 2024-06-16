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

struct ResourceDocument: Codable, Identifiable {
    let id: String
    let resourceId: String
    let resourceIndex: String
    let index: String
    let name: String
    let title: String
    let subtitle: String?
    let startDate: Date?
    let endDate: Date?
    let segments: [Segment]?

    enum CodingKeys: String, CodingKey {
        case id
        case resourceId
        case resourceIndex
        case index
        case name
        case title
        case subtitle
        case startDate
        case endDate
        case segments
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        resourceId = try container.decode(String.self, forKey: .resourceId)
        resourceIndex = try container.decode(String.self, forKey: .resourceIndex)
        index = try container.decode(String.self, forKey: .index)
        name = try container.decode(String.self, forKey: .name)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        
        if let startDateString = try container.decodeIfPresent(String.self, forKey: .startDate) {
            startDate = Date.serverDateFormatter().date(from: startDateString)
        } else {
            startDate = nil
        }
        
        if let endDateString = try container.decodeIfPresent(String.self, forKey: .endDate) {
            endDate = Date.serverDateFormatter().date(from: endDateString)
        } else {
            endDate = nil
        }
        
        segments = try container.decodeIfPresent([Segment].self, forKey: .segments)
    }
}
