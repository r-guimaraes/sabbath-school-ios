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

enum ResourceType: String, Codable {
    case pm
    case devo
    case aij
}

enum ResourceCoverType {
    case landscape
    case portrait
    case splash
    case square
    
    var aspectRatio: CGFloat {
        switch self {
        case .landscape: return 1280/720
        case .square: return 1
        case .portrait: return 854/1280
        case .splash: return 1
        }
    }
}

enum ResourceKind: String, Codable {
    case book
    case devotional
    case plan
    case external
    case blog
    case magazine
}

struct ResourceFont: Codable {
    let name: String
    let weight: Int
    let src: URL
}

struct ResourceCredit: Codable {
    let name: String
    let value: String
}

struct ResourceFeature: Codable {
    let name: String
    let title: String
    let description: String
    let image: URL
}

struct ResourceCovers: Codable {
    let square: URL
    let splash: URL
    let landscape: URL
    let portrait: URL
}

struct Resource: Codable, Identifiable {
    let id: String
    let index: String
    let title: String
    let subtitle: String
    let description: String
    let primaryColor: String
    let primaryColorDark: String
    let sections: [ResourceSection]?
    let sectionView: ResourceSectionViewType?
    let feeds: [FeedGroup]?
    let kind: ResourceKind
    let covers: ResourceCovers
    let features: [ResourceFeature]
    let credits: [ResourceCredit]
    let fonts: [ResourceFont]?
}
