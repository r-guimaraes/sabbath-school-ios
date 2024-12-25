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
import SwiftUI

struct LanguageItemView: View {
    var resourceInfo: ResourceInfo
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        VStack {
            Button(action: {
                DispatchQueue.main.async {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    languageManager.language = QuarterlyLanguage(code: resourceInfo.code, name: resourceInfo.name)
                }
            }) {
                HStack {
                    VStack {
                        Text(AppStyle.Language.name(resourceInfo.name))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(AppStyle.Language.translated(resourceInfo.translatedName ?? resourceInfo.name))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Spacer()
                    if languageManager.language?.code == resourceInfo.code {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct LanguageView: View {
    @State private var searchText = ""
    @StateObject private var resourceInfoViewModel = ResourceInfoViewModel()

    var body: some View {
        NavigationStack {
            if let resourceInfo = resourceInfoViewModel.resourceInfo {
                SwiftUI.List {
                    ForEach(resourceInfo.filter
                            {
                                $0.name.localizedCaseInsensitiveContains(searchText)
                                || ($0.translatedName ?? $0.name).localizedCaseInsensitiveContains(searchText)
                                || searchText.isEmpty
                            }, id: \.self) { resourceInfo in
                        LanguageItemView(resourceInfo: resourceInfo)
                    }
                }
                .navigationTitle("Languages".localized())
                .navigationBarTitleDisplayMode(.inline)
                .frame(maxWidth: .infinity)
                .listStyle(PlainListStyle())
            } else {
                ProgressView()
            }
        }
        .task {
            await resourceInfoViewModel.retrieveResourceInfo()
        }
        .searchable(text: $searchText)
    }
}

struct LanguageView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageView().environmentObject(LanguageManager())
    }
}
