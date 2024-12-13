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
import PSPDFKit
import PSPDFKitUI
import SwiftAudio

struct DocumentView: View {
    var documentIndex: String
    
    @State var showThemeAux = false
    @State var showVideoAux = false
    @State var showAudioAux = false
    
    @StateObject var resourceViewModel: ResourceViewModel = ResourceViewModel()
    @StateObject var viewModel: DocumentViewModel = DocumentViewModel()
    @StateObject var documentViewOperator: DocumentViewOperator = DocumentViewOperator()

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    @EnvironmentObject var audioPlayback: AudioPlayback
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    enum MenuItemIdentifier: String, Hashable {
        case originalPDF
        case readingOptions
    }
    
    var menuItems: [MenuItemIdentifier] = [.originalPDF, .readingOptions]
    
    var btnBack: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
        Image(systemName: "arrow.backward")
            .renderingMode(.original)
            .foregroundColor(documentViewOperator.shouldShowNavigationBar
                             ? colorScheme == .dark ? .white : .black
                             : colorScheme == .dark ? .white : (documentViewOperator.shouldShowCovers() ? .white : .black))
            .aspectRatio(contentMode: .fit)
            .id(documentViewOperator.shouldShowNavigationBar)
            .transition(.opacity.animation(.easeInOut))
        }
    }

    var isActiveTabPDF: Binding<Bool> {
        Binding<Bool>(
            get: {
                if let segments = viewModel.document?.segments {
                    return segments[documentViewOperator.activeTab].type == .pdf
                }
                return false
            },
            set: { _ in }
        )
    }
    
    var body: some View {
        Group {
            if resourceViewModel.fontsDownloaded {
                if let resource = resourceViewModel.resource,
                   let document = viewModel.document,
                   let segments = viewModel.document?.segments {
                    ZStack(alignment: .bottom) {
                        ScrollView(.init()) {
                            pagerView(resource, document, segments)
                        }
                        if audioPlayback.shouldShowMiniPlayer() {
                            miniPlayerView()
                                .padding(.bottom, documentViewOperator.tabBarHeight + 20)
                        }
                    }
                }
            } else {
                DocumentLoadingView()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .edgesIgnoringSafeArea(.bottom)
        .task {
            if viewModel.document != nil { return }
            
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            await setup()
        }
        .onChange(of: documentViewOperator.activeTab) { newValue in
            documentViewOperator.setShowTabBar(documentViewOperator.shouldShowTabBar(), tab: newValue, force: true)
        }
        .sheet(isPresented: $showAudioAux) {
            AudioAuxiliaryView(
                audio: viewModel.audioAuxiliary ?? [],
                documentIndex: viewModel.document?.id ?? "",
                segmentIndex: viewModel.document?.segments?[documentViewOperator.activeTab].id ?? ""
            )
        }
        .sheet(isPresented: $showVideoAux) {
            VideoAuxiliaryView(
                videos: viewModel.videoAuxiliary ?? [],
                targetIndex: viewModel.document?.id ?? ""
            )
            .presentationDetents([.large])
        }
        .toolbar {
            toolbarView()
        }
        .environmentObject(viewModel)
        .toolbarBackground(documentViewOperator.shouldShowNavigationBar ? .visible : .hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(false)
        .navigationBarItems(leading: btnBack)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(documentViewOperator.navigationBarTitle)
        .safeAreaInset(edge: .top) {
            if documentViewOperator.shouldShowSegmentChips() {
                segmentChipsView()
            }
        }
        .onChange(of: colorScheme) { newColorScheme in
            themeManager.setTheme(to: themeManager.currentTheme)
        }
        .onAppear {
            themeManager.setTheme(to: themeManager.currentTheme)
        }
//        .sheet(isPresented: .constant(true)) {
//            if let resource = resourceViewModel.resource,
//               let document = viewModel.document,
//               let segments = document.segments,
//               let segment = segments[safe: 2] {
//                SegmentViewBase(
//                    resource: resource,
//                    segment: segment,
//                    index: -1,
//                    document: document
//                ) { cover, blocks, _ in
//                    VStack(spacing: 0) {
//                        cover
//                        blocks
//                    }
//                }
//                .environmentObject(viewModel)
//                .environmentObject(documentViewOperator)
//                .environment(\.defaultBlockStyles, document.style ?? Style(resource: nil, segment: nil, blocks: nil))
//            }
//        }
    }

    func setup() async {
        if viewModel.document != nil { return }
        
        await viewModel.retrieveDocument(documentIndex: documentIndex, completion: {
            Task {
                if let document = viewModel.document {
                    documentViewOperator.activeTab = viewModel.selectedSegmentIndex ?? 0
                    if let segments = document.segments {
                        let showChips = segments.count > 1
                        
                        if let showSegmentChips = document.showSegmentChips,
                           showSegmentChips {
                            documentViewOperator.showSegmentChips = showChips
                        } else {
                            documentViewOperator.showSegmentChips = false
                        }
                        
                        for (index, segment) in segments.enumerated() {
                            documentViewOperator.setShowTabBar(segment.type == .block || segment.type == .video || segment.type == .pdf, tab: index)
                            documentViewOperator.navigationBarTitles[index] = segment.title
                            documentViewOperator.setShowSegmentChips(showChips && (segment.type == .block || segment.type == .video), tab: index)
                            documentViewOperator.setShowCovers(segment.type == .block && ((document.cover != nil) || (segment.cover != nil)), tab: index)
                            documentViewOperator.setShowNavigationBar(segment.type == .pdf, tab: index)
                        }
                    }
                    await resourceViewModel.downloadFonts(resourceIndex: document.resourceIndex)
                    Configuration.configureFontblaster()
                    await viewModel.retrieveDocumentUserInput(documentId: document.id)
                    await viewModel.retrievePDFAux(resourceIndex: document.resourceIndex, documentIndex: document.index)
                    await viewModel.retrieveVideoAux(resourceIndex: document.resourceIndex, documentIndex: document.index)
                    await viewModel.retrieveAudioAux(resourceIndex: document.resourceIndex, documentIndex: document.id)
                }
            }
        })
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView(documentIndex: "en/devo/test/blocks").environmentObject(ScreenSizeMonitor())
    }
}
