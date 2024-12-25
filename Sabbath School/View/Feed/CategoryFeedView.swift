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
import NukeUI

struct CategoryFeedView: View {
    var categoryId: String
    @State private var showNavigationBar: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @StateObject var viewModel: CategoryFeedViewModel = CategoryFeedViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    var btnBack: some View {Button(action: {
        self.presentationMode.wrappedValue.dismiss()
       }) {
           Image(systemName: showNavigationBar ? "arrow.backward" : "arrow.backward.circle.fill")
               .renderingMode(.original)
               .foregroundColor(showNavigationBar ? (colorScheme == .dark ? .white : .black) : .black)
               .aspectRatio(contentMode: .fit)
               .id(showNavigationBar)
               .transition(.opacity.animation(.easeInOut))
       }
    }
    
    private enum CoordinateSpaces {
        case scrollView
    }
    
    var body: some View {
        VStack {
            if let category = self.viewModel.category {
                ScrollViewReader { scroll in
                    ScrollView(.vertical, showsIndicators: false) {
                        ZStack (alignment: .bottom) {
                            ParallaxHeader(
                                coordinateSpace: CoordinateSpaces.scrollView,
                                defaultHeight: category.covers.splash == nil ? 0 : AppStyle.Category.Splash.height
                            ) {
                                if let splash = category.covers.splash {
                                    LazyImage(url: splash) { state in
                                        if let image = state.image {
                                            image.resizable()
                                                .scaledToFill()
                                        }
                                    }
                                } else {
                                    Color(hex: category.primaryColor).edgesIgnoringSafeArea(.top)
                                }
                            }
                            
                            VStack(spacing: 20) {
                                if let logo = category.logo {
                                    LazyImage(url: logo) { state in
                                        if let image = state.image {
                                            image.resizable()
                                                .scaledToFit()
                                        }
                                    }.frame(maxHeight: 80)
                                } else {
                                    Text(category.title)
                                        .font(.custom("Lato-Black", size: 28))
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                }
                                
                                if let subtitle = category.subtitle {
                                    Text(subtitle)
                                        .font(.custom("Lato-Regular", size: 16))
                                        .foregroundColor(.white.opacity(0.7))
                                        .lineLimit(2)
                                }
                            }
                            .padding(.top, 150)
                            .padding(.bottom, 40)
                        }
                        .edgesIgnoringSafeArea(.top)
                        
                        // Adding VStack to prevent unnecessary spacing between elements in the ScrollView
                        VStack (alignment: .leading, spacing: 0) {
                            ForEach(category.feed.groups, id: \.id) { group in
                                FeedGroupView(resourceType: .authors, feedGroup: group, prefix: category.id)
                            }
                            Spacer()
                        }
                        .background(AppStyle.Base.backgroundColor)
                        .offset(y: -10)
                        .frame(width: screenSizeMonitor.screenSize.width)
                        .frame(maxHeight: .infinity)
                        .background(GeometryReader { geometry -> Color in
                            DispatchQueue.main.async {
                                scrollOffset = geometry.frame(in: .named(CoordinateSpaces.scrollView)).minY
                            }
                            return Color.clear
                        })
                    }
                    .navigationTitle(showNavigationBar ? category.title : "")
                    .onChange(of: scrollOffset) { newValue in
                        showNavigationBar = scrollOffset <= 100
                    }
                    .coordinateSpace(name: CoordinateSpaces.scrollView)
                    .edgesIgnoringSafeArea(.top)
                    .onAppear {
                        UIApplication.shared.currentTabBarController()?.tabBar.isHidden = false
                    }
                }
            } else {
                FeedLoadingView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(false)
        .navigationBarItems(leading: btnBack)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(showNavigationBar ? .visible : .hidden, for: .navigationBar)
        .toolbarColorScheme(colorScheme == .dark ? .dark : (showNavigationBar ? .light : .dark), for: .navigationBar)
        .task {
            await retrieveContent()
            
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func retrieveContent() async {
        await viewModel.retrieveCategory(categoryId: self.categoryId, language: PreferencesShared.currentLanguage().code)
    }
}
