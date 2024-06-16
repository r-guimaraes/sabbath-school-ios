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

import SwiftUI

struct ResourceSectionsView: View {
    var resource: Resource
    @State private var selectedSection: ResourceSection? = nil
    
    init(resource: Resource) {
        self.resource = resource
        self._selectedSection = State(initialValue: ResourceSectionsView.selectFirstNonRootSection(for: resource))
    }
    
    private static func selectFirstNonRootSection(for resource: Resource) -> ResourceSection? {
        return resource.sections?.first(where: {
            $0.isRoot == nil
        }) ?? nil
    }
    
    
    var body: some View {
        VStack (spacing: 0) {
            let sectionView = resource.sectionView ?? .normal
            
            if sectionView == .dropdown {
                if let sections = resource.sections, let _ = selectedSection {
                    Menu {
                        ForEach(sections.filter { section in
                            if section.isRoot != nil { return false }
                            return true
                        }, id: \.id) { section in
                            Button(section.title) {
                                selectedSection = section
                            }
                        }
                    }
                    label : {
                        HStack {
                            Text(selectedSection?.title ?? "").font(.headline)
                                .foregroundColor(.black) // Custom color
                                .frame(alignment: .leading)
                                .lineLimit(1)
                            
                            Image(systemName: "chevron.down").tint(.black).fontWeight(.bold)
                        }.padding(20)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .border(Color.red)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    
                    ResourceSectionView(section: selectedSection!, displaySectionName: false)
                }
            } else {
                if let sections = resource.sections {
                    ForEach(sections) { section in
                        ResourceSectionView(section: section)
                    }
                }
            }
        }
    }
}
