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
import UIKit
import NukeUI

@ViewBuilder
func AdaptiveStack<Content: View>(alignment: Alignment, spacing: CGFloat, isPad: Bool, @ViewBuilder content: () -> Content) -> some View {
    if isPad {
        HStack(spacing: spacing, content: content)
    } else {
        VStack(spacing: spacing, content: content)
    }
}

struct ResourceView: View {
    @StateObject var viewModel: ResourceViewModel = ResourceViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    @State private var uiImage: UIImage?
    
    @State private var scrollOffset: CGFloat = 0
    @State private var showNavigationBar: Bool = false
    @State private var showIntroduction: Bool = false
    
    var resourceIndex: String
    
    private let year = Calendar.current.component(.year, from: Date())

    var btnBack: some View {Button(action: {
        self.presentationMode.wrappedValue.dismiss()
       }) {
           Image(systemName: showNavigationBar ? "arrow.backward" : "arrow.backward.circle.fill")
               .renderingMode(.original)
               .foregroundColor(showNavigationBar ? colorScheme == .dark ? .white : .black : Color(hex: viewModel.resource?.primaryColorDark ?? "#000000"))
               .aspectRatio(contentMode: .fit)
               .id(showNavigationBar)
               .transition(.opacity.animation(.easeInOut))
       }
    }
    
    private enum CoordinateSpaces {
        case scrollView
    }
    
    private var headerFrameWidth: CGFloat {
        AppStyle.Resources.Resource.Header.frameWidth(viewModel.resource?.covers.splash == nil)
    }
    
    private var headerFrameAlignment: Alignment {
        AppStyle.Resources.Resource.Header.frameAlignment(viewModel.resource?.covers.splash == nil)
    }
    
    private var headerTextAlignment: TextAlignment {
        AppStyle.Resources.Resource.Header.textAlignment(viewModel.resource?.covers.splash == nil)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let resource = self.viewModel.resource {
                ScrollViewReader { scroll in
                    ScrollView {
                        ZStack (alignment: .bottom) {
                            ParallaxHeader(
                                coordinateSpace: CoordinateSpaces.scrollView,
                                defaultHeight: Helper.isPad && resource.covers.splash == nil ? 0 : AppStyle.Resources.Resource.Splash.height
                            ) {
                                if let splash = resource.covers.splash {
                                    LazyImage(url: splash) { image in
                                        image
                                            .image?
                                            .resizable()
                                            .scaledToFill()
                                            .onAppear {
                                                Spotlight.indexResource(resource: resource, image: image.image?.snapshot())
                                            }
                                    }
                                } else {
                                    Color(hex: resource.primaryColor).edgesIgnoringSafeArea(.top)
                                }
                            }
                            
                            if resource.covers.splash != nil {
                                GradientBlurEffectView(
                                    style: .light,
                                    width: UIScreen.main.bounds.width,
                                    height: AppStyle.Resources.Resource.Splash.gradientBlurHeight
                                )
                                .frame(
                                    width: UIScreen.main.bounds.width,
                                    height: AppStyle.Resources.Resource.Splash.gradientBlurHeight
                                )
                            }
                            
                            AdaptiveStack(
                                alignment: headerFrameAlignment,
                                spacing: AppStyle.Resources.Resource.Spacing.betweenTitleSubtitleReadButonDescription,
                                isPad: Helper.isPad && resource.covers.splash == nil) {
                                if resource.covers.splash == nil {
                                    AsyncImage(url: resource.covers.portrait) { image in
                                        image.image?.resizable().scaledToFill()
                                    }
                                    .frame(
                                       width: AppStyle.Resources.Resource.Cover.size(.portrait).width,
                                       height: AppStyle.Resources.Resource.Cover.size(.portrait).height
                                    )
                                    .cornerRadius(6)
                                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
                                    .padding(.top, Helper.isPad ? 0 : AppStyle.Resources.Resource.Spacing.topPaddingForNonSplashImage)
                                }
                                
                                VStack(
                                    alignment: headerFrameAlignment.horizontal,
                                    spacing: AppStyle.Resources.Resource.Spacing.betweenTitleSubtitleReadButonDescription
                                ) {
                                    Text(AppStyle.Resources.Resource.Title.text(resource.markdownTitle ?? resource.title, resource.style))
                                        .lineLimit(AppStyle.Resources.Resource.Title.lineLimit)
                                        .multilineTextAlignment(headerTextAlignment)
                                        .frame(width: headerFrameWidth, alignment: headerFrameAlignment)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .baselineOffset(-5)
                                    
                                    
                                    if let subtitle = resource.subtitle {
                                        Text(AppStyle.Resources.Resource.Subtitle.text(resource.markdownSubtitle ?? subtitle, resource.style))
                                            .lineLimit(AppStyle.Resources.Resource.Subtitle.lineLimit)
                                            .multilineTextAlignment(headerTextAlignment)
                                            .frame(width: headerFrameWidth, alignment: headerFrameAlignment)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    NavigationLink {
                                        if let readButtonIndex = self.viewModel.readButtonDocumentIndex {
                                            DocumentView(documentIndex: readButtonIndex)
                                        }
                                    } label: {
                                        Text(AppStyle.Resources.Resource.ReadButton.text("Read".localized().uppercased()))
                                            .lineLimit(AppStyle.Resources.Resource.ReadButton.lineLimit)
                                        .padding([.horizontal], AppStyle.Resources.Resource.ReadButton.horizontalPadding)
                                        .padding([.vertical], AppStyle.Resources.Resource.ReadButton.verticalPadding)
                                        .background(Color(UIColor(hex: resource.primaryColorDark)))
                                        .clipShape(Capsule())
                                        .frame(width: AppStyle.Resources.Resource.ReadButton.width, alignment: headerFrameAlignment)
                                        .shadow(radius: AppStyle.Resources.Resource.ReadButton.shadowRadius)
                                    }

                                    if let description = resource.description {
                                        ZStack(alignment: .bottomTrailing) {
                                            Text(AppStyle.Resources.Resource.Description.text(resource.markdownDescription ?? description, resource.style))
                                                .lineLimit(AppStyle.Resources.Resource.Description.lineLimit)
                                                .multilineTextAlignment(.leading)
                                                .frame(width: headerFrameWidth, alignment: .leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .mask(
                                                        ZStack (alignment: .bottomTrailing) {
                                                            Rectangle().fill(Color.white)
                                                            Text(AppStyle.Resources.Resource.Description.textMoreButton("\("More".localized().lowercased())\("More".localized().lowercased())"))
                                                                .background(.white)
                                                                .mask(
                                                                    LinearGradient(
                                                                        gradient: Gradient(colors: [Color.clear, Color.black, Color.black]),
                                                                        startPoint: .leading,
                                                                        endPoint: .trailing
                                                                    ))
                                                                .blendMode(.destinationOut)
                                                        }
                                                )
                                            
                                            
                                                Button (action: {
                                                    showIntroduction = true
                                                }, label: {
                                                    Text(AppStyle.Resources.Resource.Description.textMoreButton("More".localized().lowercased(), Color(hex: resource.primaryColorDark)))
                                                        .frame(alignment: .trailing)
                                                })
                                            
                                        }.frame(width: headerFrameWidth)
                                    }
                                    
                                    ResourceFeaturesHeaderView(features: resource.features, style: resource.style)
                                        .frame(alignment: .leading)
                                }
                                .frame(alignment: headerFrameAlignment)
                            }
                            .padding([.bottom], AppStyle.Resources.Resource.Spacing.paddingForSplashHeader)
                            .padding([.horizontal], AppStyle.Resources.Resource.Spacing.paddingForSplashHeader)
                            .padding([.top], AppStyle.Resources.Resource.Spacing.paddingForNonSplashHeader)
                            .frame(width: UIScreen.main.bounds.width)
                        }
                        .edgesIgnoringSafeArea(.top)
                        
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
                                
                                Text(AppStyle.Resources.Resource.Copyright.text(String(format: "© %d " + "General Conference of Seventh-day Adventists".localized() + "®", year)))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                            }.padding(AppStyle.Resources.Resource.Spacing.paddingForFooter)
                             .background(AppStyle.Resources.Resource.Footer.color)
                        }
                        .background(AppStyle.Resources.Base.backgroundColor)
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
                        UIApplication.shared.currentTabBarController()?.tabBar.isHidden = false
                    }
                }
            }
            else {
                ResourceLoadingView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(false)
        .navigationBarItems(leading: btnBack)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(showNavigationBar ? .visible : .hidden, for: .navigationBar)
        .toolbarColorScheme(colorScheme == .dark ? .dark : (showNavigationBar ? .light : .dark), for: .navigationBar)
        .background(AppStyle.Resources.Resource.Footer.color)
        .sheet(isPresented: $showIntroduction) {
            if let introduction = viewModel.resource?.introduction {
                ResourceIntroductionView(introduction: introduction)
            }
        }
        .task {
            await viewModel.downloadFonts(resourceIndex: resourceIndex)
            
            // shortcuts
            // TODO: remove to module
            if let resource = viewModel.resource {
                var shortcutItems = UIApplication.shared.shortcutItems ?? []
                
                let existingIndex = shortcutItems.firstIndex(where: { $0.userInfo?["index"] as? String == resource.index })
                
                if existingIndex != nil {
                    shortcutItems.remove(at: existingIndex!)
                }

                let shortcutItem = UIApplicationShortcutItem.init(
                    type: Constants.DefaultKey.shortcutItem,
                    localizedTitle: resource.title,
                    localizedSubtitle: resource.subtitle,
                    icon: .init(systemImageName: "bookmark"),
                    userInfo: ["index": resource.index as NSSecureCoding]
                )
                
                shortcutItems.insert(shortcutItem, at: 0)
                UIApplication.shared.shortcutItems = shortcutItems
            }
        }.onAppear {
            UIApplication.shared.currentTabBarController()?.tabBar.isHidden = false
        }
    }
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct ResourceView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceView(resourceIndex: "en/devo/test").environmentObject(ScreenSizeMonitor())
    }
}

