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
import SwiftUI

@MainActor class ResourceViewModel: ObservableObject {
    @Published var resource: Resource? = nil
    @Published var fontsDownloaded: Bool = false
    
    private static var resourceStorage: Storage<String, Resource>?
    
    init() {
         self.configure()
    }
    
    func configure() {
        ResourceViewModel.resourceStorage = APICache.storage?.transformCodable(ofType: Resource.self)
    }
    
    func downloadFont(from url: URL, completion: @escaping (URL?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location = location, error == nil else {
                completion(nil)
                return
            }

            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)

            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    print("SSDEBUG, completing since it exists")
                    completion(destinationURL)
                    return
                }
                try fileManager.moveItem(at: location, to: destinationURL)
                completion(destinationURL)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func registerFont(with url: URL) {
        guard let fontDataProvider = CGDataProvider(url: url as CFURL),
              let font = CGFont(fontDataProvider) else { return }

        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            print("SSDEBUG Error registering font: \(String(describing: error)), \(url)")
        }
    }

    func downloadAndRegisterFonts(fontURLs: [URL], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()

        for fontURL in fontURLs {
            dispatchGroup.enter()
            downloadFont(from: fontURL) { localURL in
                guard let localURL = localURL else {
                    dispatchGroup.leave()
                    return
                }
                self.registerFont(with: localURL)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    func retrieveResource(resourceIndex: String, completion: (() -> Void)? = nil) async {
        let url = "http://localhost:3002/api/v2/\(resourceIndex)/sections/index.json"
        var completed = false
        if (try? ResourceViewModel.resourceStorage?.existsObject(forKey: url)) != nil {
            if let resource = try? ResourceViewModel.resourceStorage?.entry(forKey: url) {
                self.resource = resource.object
                completed = true
                completion?()
            }
        }
        API.session.request(url).responseDecodable(of: Resource.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let resource = response.value else {
                return
            }
            self.resource = resource
            try? ResourceViewModel.resourceStorage?.setObject(resource, forKey: url)
            if !completed { completion?() }
        }
    }
    
    func downloadFonts(resourceIndex: String) async {
        await self.retrieveResource(resourceIndex: resourceIndex, completion: {
            if let resource = self.resource {
                guard let fonts = resource.fonts else {
                    self.fontsDownloaded = true
                    return
                }
                
                self.downloadAndRegisterFonts(fontURLs: fonts.map({ $0.src }), completion: {
                    self.fontsDownloaded = true
                })
            }
        })
    }
}
