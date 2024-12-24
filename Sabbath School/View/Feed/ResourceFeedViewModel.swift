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
import Cache

@MainActor class ResourceFeedViewModel: ObservableObject {
    @Published var feed: ResourceFeed? = nil
    @Published var feedGroup: AnyFeedGroup? = nil
    
    private static var resourceFeedStorage: Storage<String, ResourceFeed>?
    private static var resourceSeeAllFeedStorage: Storage<String, AnyFeedGroup>?
    
    init() {
         self.configure()
    }
    
    func configure() {
        ResourceFeedViewModel.resourceFeedStorage = APICache.storage?.transformCodable(ofType: ResourceFeed.self)
        ResourceFeedViewModel.resourceSeeAllFeedStorage = APICache.storage?.transformCodable(ofType: AnyFeedGroup.self)
    }
    
    func retrieveFeed(resourceType: ResourceType, language: String) async {
        let url = "\(Constants.API.URLv3)/\(language)/\(resourceType)/index.json"
        
        if (try? ResourceFeedViewModel.resourceFeedStorage?.existsObject(forKey: url)) != nil {
            if let feed = try? ResourceFeedViewModel.resourceFeedStorage?.entry(forKey: url) {
                self.feed = feed.object
            }
        }
        
        API.session.request(url).responseDecodable(of: ResourceFeed.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let feed = response.value else {
                return
            }
            self.feed = feed
            try? ResourceFeedViewModel.resourceFeedStorage?.setObject(feed, forKey: url)
        }
    }
    
    func retrieveSeeAllFeed(resourceType: ResourceType, feedGroupId: String, language: String, prefix: String = "") async {
        let url = "\(Constants.API.URLv3)/\(language)/\(resourceType)/\(prefix.isEmpty ? "" : prefix + "/")feeds/\(feedGroupId)/index.json"
        
        if (try? ResourceFeedViewModel.resourceSeeAllFeedStorage?.existsObject(forKey: url)) != nil {
            if let feedGroup = try? ResourceFeedViewModel.resourceSeeAllFeedStorage?.entry(forKey: url) {
                self.feedGroup = feedGroup.object
            }
        }
        API.session.request(url).responseDecodable(of: AnyFeedGroup.self, decoder: Helper.SSJSONDecoder()) { response in
        
            guard let feedGroup = response.value else {
                return
            }
            self.feedGroup = feedGroup
            try? ResourceFeedViewModel.resourceSeeAllFeedStorage?.setObject(feedGroup, forKey: url)
        }
    }
}
