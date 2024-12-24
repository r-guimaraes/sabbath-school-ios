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

enum FeedGroupDirection: String, Codable {
    case vertical
    case horizontal
}

enum FeedGroupScope: String, Codable {
    case resource
//    case document
    case author
    case category
}

enum FeedGroupViewType: String, Codable {
    case folio
    case tile
    case banner
    case square
}

struct FeedGroup: Codable, Identifiable {
    let id: String
    let title: String?
    let seeAll: String?
    
    let view: FeedGroupViewType
    let direction: FeedGroupDirection
    let scope: FeedGroupScope
    
    let resources: [Resource]?
//    let documents: [ResourceDocument]?
    
    let backgroundColor: String?
}

protocol FeedGroupProtocol: Codable {
    var id: String { get }
    var title: String? { get }
    var seeAll: String? { get }
    var view: FeedGroupViewType { get }
    var direction: FeedGroupDirection { get }
    var scope: FeedGroupScope { get }
    var backgroundColor: String? { get }
    var showTitle: Bool? { get }
}

struct FeedGroupResources: FeedGroupProtocol {
    var id: String
    var title: String?
    var seeAll: String?
    var view: FeedGroupViewType
    var direction: FeedGroupDirection
    var scope: FeedGroupScope
    var backgroundColor: String?
    var resources: [Resource]?
    var showTitle: Bool?
}

struct FeedGroupAuthors: FeedGroupProtocol {
    var id: String
    var title: String?
    var seeAll: String?
    var view: FeedGroupViewType
    var direction: FeedGroupDirection
    var scope: FeedGroupScope
    var backgroundColor: String?
    var authors: [Author]?
    var showTitle: Bool?
}

struct FeedGroupCategories: FeedGroupProtocol {
    var id: String
    var title: String?
    var seeAll: String?
    var view: FeedGroupViewType
    var direction: FeedGroupDirection
    var scope: FeedGroupScope
    var backgroundColor: String?
    var categories: [Category]?
    var showTitle: Bool?
}

struct AnyFeedGroup: FeedGroupProtocol {
    private let _base: any FeedGroupProtocol
    
    var id: String {
        return _base.id
    }
    
    var scope: FeedGroupScope {
        return _base.scope
    }
    
    var title: String? {
        return _base.title
    }
    
    var seeAll: String? {
        return _base.seeAll
    }
    
    var view: FeedGroupViewType {
        return _base.view
    }
    
    var direction: FeedGroupDirection {
        return _base.direction
    }
    
    var backgroundColor: String? {
        return _base.backgroundColor
    }
    
    var showTitle: Bool? {
        return _base.showTitle
    }
    
    init(_ base: any FeedGroupProtocol) {
        self._base = base
    }
    
    func encode(to encoder: Encoder) throws {
        try _base.encode(to: encoder)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case scope
    }
    
    func asType<T: FeedGroupProtocol>(_ type: T.Type) -> T? {
        return _base as? T
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let scope = try container.decode(FeedGroupScope.self, forKey: .scope)
        
        switch scope {
        case .resource:
            _base = try FeedGroupResources(from: decoder)
        case .author:
            _base = try FeedGroupAuthors(from: decoder)
        case .category:
            _base = try FeedGroupCategories(from: decoder)
        }
    }
}
