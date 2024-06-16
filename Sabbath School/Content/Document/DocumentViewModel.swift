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

import Alamofire
import Foundation
import Cache

@MainActor class DocumentViewModel: ObservableObject {
    @Published var document: ResourceDocument? = nil
    @Published var documentUserInput: [AnyUserInput] = []
    
    private static var documentStorage: Storage<String, ResourceDocument>?
    
    init() {
         self.configure()
    }
    
    func configure() {
        DocumentViewModel.documentStorage = APICache.storage?.transformCodable(ofType: ResourceDocument.self)
    }
    
    
    func retrieveDocument(documentIndex: String, completion: (() -> Void)? = nil) async {
        let url = "http://localhost:3002/api/v2/\(documentIndex)/index.json"
        var completed = false
        
        if (try? DocumentViewModel.documentStorage?.existsObject(forKey: url)) != nil {
            if let document = try? DocumentViewModel.documentStorage?.entry(forKey: url) {
                self.document = document.object
                completed = true
                completion?()
            }
        }
        API.session.request(url).responseDecodable(of: ResourceDocument.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let document = response.value else {
                return
            }
            self.document = document
            try? DocumentViewModel.documentStorage?.setObject(document, forKey: url)
            if !completed { completion?() }
        }
    }
    
    func retrieveDocumentUserInput(documentId: String) async {
        API.auth.request("http://localhost:3001/api/v2/resources/user/input/document/\(documentId)")
            .customValidate()
            .responseDecodable(of: [AnyUserInput].self, decoder: Helper.SSJSONDecoder()) { response in
                print("SSDEBUG", response)
            guard let userInput = response.value else {
                return
            }
            self.documentUserInput = userInput
        }
    }
    
    func saveBlockUserInput(documentId: String?, blockId: String, userInputType: UserInputType, userInput: AnyUserInput) {
        guard let documentId = documentId else {
            return
        }
        
        do {
            let userInput = try JSONSerialization.jsonObject(with: JSONEncoder().encode(userInput), options: .allowFragments) as! [String: Any]
            
            print("SSDEBUG saving", "http://localhost:3001/api/v2/resources/user/input/\(userInputType.rawValue)/\(documentId)/\(blockId)")
            
            API.auth.request(
                "http://localhost:3001/api/v2/resources/user/input/\(userInputType.rawValue)/\(documentId)/\(blockId)",
                method: .post,
                parameters: userInput,
                encoding: JSONEncoding.default
            ).responseJSON { response in }
        } catch let error {
            print("SSDEBUG", error)
        }
    }
}
