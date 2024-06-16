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

struct ResourceInfo: Codable {
    let name: String
    let code: String
    let pm: Bool
    let devo: Bool
}

class FeedViewModel: ObservableObject {
    @Published var feed: Feed? = nil
    @Published var feedGroup: FeedGroup? = nil
    
    private static var resourceInfoStorage: Storage<String, [ResourceInfo]>?
    private static var resourceFeedStorage: Storage<String, Feed>?
    private static var resourceSeeAllFeedStorage: Storage<String, FeedGroup>?
    
    init() {
         self.configure()
    }
    
    func configure() {
        FeedViewModel.resourceInfoStorage = APICache.storage?.transformCodable(ofType: [ResourceInfo].self)
        FeedViewModel.resourceFeedStorage = APICache.storage?.transformCodable(ofType: Feed.self)
        FeedViewModel.resourceSeeAllFeedStorage = APICache.storage?.transformCodable(ofType: FeedGroup.self)
    }
    
    public var resourceInfoEndpoint: String {
//        return "\(Constants.API.URL)/resources/index.json"
        return "http://localhost:3002/api/v2/resources/index.json"
    }
    
    public func getDevotionalResourceInfo(key: String) -> [ResourceInfo]? {
        if let resources = try? FeedViewModel.resourceInfoStorage?.entry(forKey: key) {
            return resources.object
        }
        return nil
    }
    
    func retrieveResourceInfo() {
        let url = self.resourceInfoEndpoint
                
        API.session.request(url).responseDecodable(of: [ResourceInfo].self, decoder: Helper.SSJSONDecoder()) { response in
            
            guard let resourceInfo = response.value else {
                return
            }
            try? FeedViewModel.resourceInfoStorage?.setObject(resourceInfo, forKey: url)
        }
    }
    
    func retrieveFeed(resourceType: ResourceType, language: String) async {
        let url = "http://localhost:3002/api/v2/\(language)/\(resourceType)/index.json"
        
        if (try? FeedViewModel.resourceFeedStorage?.existsObject(forKey: url)) != nil {
            if let feed = try? FeedViewModel.resourceFeedStorage?.entry(forKey: url) {
                self.feed = feed.object
            }
        }
        API.session.request(url).responseDecodable(of: Feed.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let feed = response.value else {
                return
            }
            self.feed = feed
            try? FeedViewModel.resourceFeedStorage?.setObject(feed, forKey: url)
        }
    }
    
    func retrieveSeeAllFeed(resourceType: ResourceType, feedGroupName: String, language: String) async {
        let url = "http://localhost:3002/api/v2/\(language)/\(resourceType)/feeds/\(feedGroupName)/index.json"
        
        if (try? FeedViewModel.resourceSeeAllFeedStorage?.existsObject(forKey: url)) != nil {
            if let feedGroup = try? FeedViewModel.resourceSeeAllFeedStorage?.entry(forKey: url) {
                self.feedGroup = feedGroup.object
            }
        }
        API.session.request(url).responseDecodable(of: FeedGroup.self, decoder: Helper.SSJSONDecoder()) { response in
        
            guard let feedGroup = response.value else {
                return
            }
            self.feedGroup = feedGroup
            try? FeedViewModel.resourceSeeAllFeedStorage?.setObject(feedGroup, forKey: url)
        }
    }
}
