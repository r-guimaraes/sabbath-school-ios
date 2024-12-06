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
    @Published var readButtonDocumentIndex: String? = nil
    
    private static var resourceStorage: Storage<String, Resource>?
    
    init() {
         self.configure()
    }
    
    func configure() {
        ResourceViewModel.resourceStorage = APICache.storage?.transformCodable(ofType: Resource.self)
    }
    
    func downloadFont(from url: URL, completion: @escaping (URL?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)

            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    completion(destinationURL)
                    return
                }
                
                guard let location = location, error == nil else {
                    completion(nil)
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
        guard let fontFile = NSData(contentsOf: url) else {
            return
        }

        guard let provider = CGDataProvider(data: fontFile) else {
            return
        }

        let font = CGFont(provider)
        let error: UnsafeMutablePointer<Unmanaged<CFError>?>? = nil

        guard CTFontManagerRegisterGraphicsFont(font!, error) else {
            guard let unError = error?.pointee?.takeUnretainedValue(),
                  let _ = CFErrorCopyDescription(unError) else {
                return
            }
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
        let url = "\(Constants.API.URLv3)/\(resourceIndex)/sections/index.json"
        
        var completed = false
        if (try? ResourceViewModel.resourceStorage?.existsObject(forKey: url)) != nil {
            if let resource = try? ResourceViewModel.resourceStorage?.entry(forKey: url) {
                self.resource = resource.object
                completed = true
                self.setReadDocumentIndex()
                completion?()
            }
        }
        API.session.request(url).responseDecodable(of: Resource.self, decoder: Helper.SSJSONDecoder()) { response in
            guard let resource = response.value else {
                return
            }
            self.resource = resource
            try? ResourceViewModel.resourceStorage?.setObject(resource, forKey: url)
            self.setReadDocumentIndex()
            if !completed { completion?() }
        }
    }
    
    func setReadDocumentIndex () {
        if let sections = self.resource?.sections {
            var today = Date()
            let weekday = Calendar.current.component(.weekday, from: today)
            let hour = Calendar.current.component(.hour, from: today)
            
            if weekday == 7 && hour == 12 {
                today = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
            }
            
            self.readButtonDocumentIndex = sections.first?.documents.first?.index
            
            sections.forEach { section in
                section.documents.forEach { document in
                    if let startDate = document.startDate,
                       let endDate = document.endDate
                    {
                        let start = Calendar.current.compare(startDate.date, to: today, toGranularity: .day)
                        let end = Calendar.current.compare(endDate.date, to: today, toGranularity: .day)
                        
                        let fallsBetween = ((start == .orderedAscending) || (start == .orderedSame)) && ((end == .orderedDescending) || (end == .orderedSame))

                        if fallsBetween {
                            self.readButtonDocumentIndex = document.index
                        }
                    }
                }
            }
        }
    }
}
