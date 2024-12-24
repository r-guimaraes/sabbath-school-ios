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

@MainActor class AuthorFeedViewModel: ObservableObject {
    @Published var author: AuthorFeed? = nil
    
    private static var authorFeedStorage: Storage<String, AuthorFeed>?
    
    init() {
         self.configure()
    }
    
    func configure() {
        AuthorFeedViewModel.authorFeedStorage = APICache.storage?.transformCodable(ofType: AuthorFeed.self)
    }
    
    func retrieveAuthor(authorId: String, language: String) async {
        let url = "\(Constants.API.URLv3)/\(language)/authors/\(authorId)/index.json"
        
        if (try? AuthorFeedViewModel.authorFeedStorage?.existsObject(forKey: url)) != nil {
            if let author = try? AuthorFeedViewModel.authorFeedStorage?.entry(forKey: url) {
                self.author = author.object
            }
        }
        
        API.session.request(url).responseDecodable(of: AuthorFeed.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let author = response.value else {
                return
            }
            self.author = author
            try? AuthorFeedViewModel.authorFeedStorage?.setObject(author, forKey: url)
        }
    }
}

@MainActor class CategoryFeedViewModel: ObservableObject {
    @Published var category: CategoryFeed? = nil
    
    private static var categoryFeedStorage: Storage<String, CategoryFeed>?
    
    init() {
         self.configure()
    }
    
    func configure() {
        CategoryFeedViewModel.categoryFeedStorage = APICache.storage?.transformCodable(ofType: CategoryFeed.self)
    }
    
    func retrieveCategory(categoryId: String, language: String) async {
        let url = "\(Constants.API.URLv3)/\(language)/categories/\(categoryId)/index.json"
        
        if (try? CategoryFeedViewModel.categoryFeedStorage?.existsObject(forKey: url)) != nil {
            if let category = try? CategoryFeedViewModel.categoryFeedStorage?.entry(forKey: url) {
                self.category = category.object
            }
        }
        
        API.session.request(url).responseDecodable(of: CategoryFeed.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let category = response.value else {
                return
            }
            self.category = category
            try? CategoryFeedViewModel.categoryFeedStorage?.setObject(category, forKey: url)
        }
    }
}
