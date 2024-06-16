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

struct FeedSeeAllView: View {
    @StateObject var viewModel: FeedViewModel = FeedViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

   var btnBack : some View { Button(action: {
       self.presentationMode.wrappedValue.dismiss()
       }) {
           Image(systemName: "arrow.backward")
               .renderingMode(.original)
               .foregroundColor(.black)
               .aspectRatio(contentMode: .fit)
               
       }
   }

    var resourceType: ResourceType
    var feedGroupName: String
    
    var body: some View {
        VStack(spacing: 0) {
            if (self.viewModel.feedGroup != nil) {
                ScrollView {
                    // Adding VStack to prevent unnecessary spacing between elements in the ScrollView
                    VStack (spacing: 0) {
                        FeedGroupView(resourceType: resourceType, feedGroup: self.viewModel.feedGroup!, displayFeedGroupTitle: false, displaySeeAllButton: false)
                    }
                }
                .navigationTitle(self.viewModel.feedGroup!.title)
                
            }
        }.navigationBarBackButtonHidden(true)
         .navigationBarItems(leading: btnBack)
         .navigationBarTitleDisplayMode(.large)
         .task {
             await viewModel.retrieveSeeAllFeed(resourceType: self.resourceType, feedGroupName: self.feedGroupName, language: "en")
        }
    }
}

struct FeedSeeAllView_Previews: PreviewProvider {
    static var previews: some View {
        FeedSeeAllView(resourceType: .devo, feedGroupName: "devotionals")
    }
}
