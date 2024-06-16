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

struct FeedView: View {
    @StateObject var viewModel: FeedViewModel = FeedViewModel()

    var resourceType: ResourceType
    let gradient = LinearGradient(colors: [Color.orange,Color.green],
                                      startPoint: .top, endPoint: .bottom)
    var body: some View {
        NavigationStack {
            ZStack {
                if (self.viewModel.feed != nil) {
                    ScrollView {
                        // Adding VStack to prevent unnecessary spacing between elements in the ScrollView
                        VStack (spacing: 0) {
                            ForEach(self.viewModel.feed!.groups) { group in
                                FeedGroupView(resourceType: resourceType, feedGroup: group)
                            }
                        }
                    }.navigationTitle(self.viewModel.feed!.title)
                } else {
                    Text("Loading")
                }
            }.navigationBarTitleDisplayMode(.large)
            
        }.task {
            await viewModel.retrieveFeed(resourceType: self.resourceType, language: "en")
        }.onAppear {
            let appearance = UINavigationBarAppearance()
            let appearanceScroll = UINavigationBarAppearance()

            appearance.shadowColor = .clear
            appearanceScroll.shadowColor = .clear

           
            appearance.backgroundColor = AppStyle.Base.Color.background
            appearance.backgroundEffect = nil
            appearanceScroll.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            
            UINavigationBar.appearance().standardAppearance = appearanceScroll
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(resourceType: .pm).environmentObject(ScreenSizeMonitor())
    }
}
