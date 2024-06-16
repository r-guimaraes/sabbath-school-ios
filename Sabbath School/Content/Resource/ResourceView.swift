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

struct ResourceView: View {
    @StateObject var viewModel: ResourceViewModel = ResourceViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    @State private var scrollOffset: CGFloat = 0
    @State private var showNavigationBar: Bool = false
    
    var resourceIndex: String

    var btnBack: some View {Button(action: {
        self.presentationMode.wrappedValue.dismiss()
       }) {
           Image(systemName: "arrow.backward")
               .renderingMode(.original)
               .foregroundColor(showNavigationBar ? colorScheme == .dark ? .white : .black : .white)
               .aspectRatio(contentMode: .fit)
       }
    }

    @State var imageHeight: CGFloat = UIScreen.main.bounds.height * 0.6
    @State var imageOffset: CGFloat = 0
    @State var headerHeight: CGFloat = UIScreen.main.bounds.height * 0.6
    
    @State private var chosenColorScheme: ColorScheme = .dark
    
    private enum CoordinateSpaces {
        case scrollView
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let resource = self.viewModel.resource {
                ScrollViewReader { scroll in
                    ScrollView {
                        ZStack (alignment: .bottom) {
                            ParallaxHeader(
                                coordinateSpace: CoordinateSpaces.scrollView,
                                defaultHeight: UIScreen.main.bounds.height*0.6
                            ) {
                                AsyncImage(url: self.viewModel.resource?.covers.splash) { image in
                                    image.image?.resizable().scaledToFill()
                                }
                            }
                            
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.4*0.6)
                                .mask {
                                    VStack(spacing: 0){
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0),
                                                Color.white.opacity(0.303),
                                                Color.white.opacity(0.707),
                                                Color.white.opacity(0.924),
                                                Color.white
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        Rectangle()
                                            .frame(height: UIScreen.main.bounds.height*0.6*0.1)
                                    }
                                }
                            
                            VStack (spacing: 20) {
                                Text(self.viewModel.resource!.title).font(.title).fontWeight(.bold).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(2)
                                
                                Text(resource.subtitle).foregroundColor(.white).lineLimit(1).font(.subheadline)
                                
                                Button (action: {
                                    
                                }){
                                    Text("Read")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white).textCase(.uppercase)
                                }.padding([.horizontal], 35)
                                    .padding([.vertical], 8)
                                    .background(Color(UIColor(hex: resource.primaryColorDark)))
                                    .clipShape(Capsule())
                                    .frame(width: 200)
                                    .shadow(radius: 20)
                                
                                Text(resource.description).foregroundColor(.white).lineLimit(3).font(.subheadline)
                                
                                ResourceFeaturesHeaderView(features: resource.features)
                            }
                            .padding([.bottom], 20)
                            .padding([.horizontal], 20)
                        }
                        
                        VStack (alignment: .leading, spacing: 0) {
                            ResourceSectionsView(resource: resource)
                            
                            if let feeds = resource.feeds {
                                ForEach(feeds) { feed in
                                    FeedGroupView(resourceType: .pm, feedGroup: feed, displaySeeAllButton: false)
                                }
                            }
                            
                            VStack (spacing: 20) {
                                if resource.features.count > 0 {
                                    ResourceFeaturesView(features: resource.features)
                                }
                                
                                if resource.credits.count > 0 {
                                    ResourceCreditsView(credits: resource.credits)
                                }
                                
                                Text("Copyright 2020").frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.gray)
                            }.padding(20)
                                .background(Color.gray.opacity(0.15))
                            
                            
                        }.background(Color(uiColor: AppStyle.Base.Color.background))
                            .offset(y: -10)
                            .frame(width: UIScreen.main.bounds.width)
                        
                            .background(GeometryReader { geometry -> Color in
                                DispatchQueue.main.async {
                                    scrollOffset = geometry.frame(in: .named(CoordinateSpaces.scrollView)).minY
                                }
                                return Color.clear
                            })
                    }
                    .navigationTitle(showNavigationBar ? resource.title : "")
                    .onChange(of: scrollOffset) { newValue in
                        showNavigationBar = scrollOffset <= 100
                    }
                    .coordinateSpace(name: CoordinateSpaces.scrollView)
                    .edgesIgnoringSafeArea(.top)
                    .onAppear {
                        scroll.scrollTo(10, anchor: .top)
                    }
                }
            }
        }
        .toolbarColorScheme(showNavigationBar ? colorScheme == .dark ? .dark : .light : .dark, for: .navigationBar)
         .toolbarBackground(showNavigationBar ? .visible : .hidden, for: .navigationBar)
         .navigationBarBackButtonHidden(true)
         .navigationBarHidden(false)
         .navigationBarItems(leading: btnBack)
         .navigationBarTitleDisplayMode(.inline)
         .background(Color.gray.opacity(0.15))
         
         .task {
             await viewModel.retrieveResource(resourceIndex: resourceIndex)
         }
    }
}

struct ResourceView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceView(resourceIndex: "en/devo/test").environmentObject(ScreenSizeMonitor())
    }
}

