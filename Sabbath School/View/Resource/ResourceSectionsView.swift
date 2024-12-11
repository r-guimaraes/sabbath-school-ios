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
        self._selectedSection = State(initialValue: selectSectionWithinDates() ?? (resource.sections?.first(where: {
            $0.isRoot == false
        }) ?? nil))
        
    }
    
    private func selectSectionWithinDates() -> ResourceSection? {
        let today = Date()
        
        if let sections = resource.sections {
            for section in sections {
                for document in section.documents {
                    if let startDate = document.startDate,
                       let endDate = document.endDate
                    {
                        let start = Calendar.current.compare(startDate.date, to: today, toGranularity: .day)
                        let end = Calendar.current.compare(endDate.date, to: today, toGranularity: .day)
                        
                        let fallsBetween = ((start == .orderedAscending) || (start == .orderedSame)) &&
                                           ((end == .orderedDescending) || (end == .orderedSame))

                        if fallsBetween {
                            return section
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    var body: some View {
        VStack (spacing: 0) {
            let sectionView = resource.sectionView ?? .normal
            
            if sectionView == .dropdown {
                if let sections = resource.sections, let _ = selectedSection {
                    Menu {
                        ForEach(sections.filter { section in
                            if section.isRoot == true { return false }
                            return true
                        }, id: \.id) { section in
                            Button(action: {
                                selectedSection = section
                            }){
                                HStack {
                                    Text(section.title)
                                    if section.title == selectedSection?.title ?? "" {
                                        Image(systemName: "checkmark")
                                            .tint(AppStyle.Resource.Section.Dropdown.chevronTint)
                                    }
                                }
                            }
                        }
                    }
                    label : {
                        HStack {
                            Text(AppStyle.Resource.Section.Dropdown.text(selectedSection?.title ?? ""))
                                .frame(alignment: .leading)
                                .lineLimit(AppStyle.Resource.Section.Dropdown.lineLimit)
                            
                            Image(systemName: "chevron.down")
                                .tint(AppStyle.Resource.Section.Dropdown.chevronTint)
                                .fontWeight(.bold)
                            
                        }.padding(AppStyle.Resource.Section.Dropdown.padding)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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
