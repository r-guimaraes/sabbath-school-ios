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
import Combine
import NukeUI

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    
    private static let imageCache = NSCache<NSURL, UIImage>()
    
    func loadImage(from url: URL) {
        if let cachedImage = Self.imageCache.object(forKey: url as NSURL) {
            self.image = cachedImage
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ in
                let image = UIImage(data: data)
                if let image = image {
                    // Cache the image
                    Self.imageCache.setObject(image, forKey: url as NSURL)
                }
                return image
            }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
    
    deinit {
        cancellable?.cancel()
    }
}

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct OffsetProxy: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: OffsetKey.self, value: proxy.frame(in: .global).minX)
        }
    }
}

struct AttributeWithRange {
    let attribute: [NSAttributedString.Key: Any]
    let range: NSRange
}

extension AttributedString {
    public static func splitAttributedString(_ attributedString: NSAttributedString, width: CGFloat) -> [NSAttributedString] {
        var chunks: [NSAttributedString] = []
        var currentChunk = NSMutableAttributedString()
        
        let words = attributedString.string.split(omittingEmptySubsequences: false) { character in
            character == " "
        }.flatMap { word -> [Substring] in
            if let newlineIndex = word.firstIndex(of: "\n") {
                let firstPart = word[..<newlineIndex]
                let secondPart = word[newlineIndex...]
                return [firstPart, secondPart]
            } else {
                return [word]
            }
        }
        
        let maxHeight: CGFloat
        var allAttributes: [AttributeWithRange] = []
        
        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length), options: []) { attributes, range, _ in
            allAttributes.append(AttributeWithRange(attribute: attributes, range: range))
        }
        
        if let font = attributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
            maxHeight = 3 * font.lineHeight
        } else {
            maxHeight = 3 * UIFont(name: "Lato-Regular", size: 28)!.lineHeight
        }
        
        var rangeStart: Int = 0
        var rangeStartInChunk: Int = 0
        
        for word in words {
            var wordString: NSAttributedString
            
            wordString = NSAttributedString(string: String(word) + " ", attributes: attributedString.attributes(at: rangeStart, effectiveRange: nil))
            
            currentChunk.append(wordString)
            
            let size = AttributedString.measureText(currentChunk, width: width)
            
            if size.height > maxHeight {
                currentChunk.deleteCharacters(in: NSRange(location: rangeStartInChunk-1, length: word.count + 1))
                rangeStartInChunk = 0
                
                chunks.append(currentChunk)
                currentChunk = NSMutableAttributedString(string: String(word + " "), attributes: attributedString.attributes(at: rangeStart, effectiveRange: nil))
            }
            
            let attributesForWord = allAttributes.filter( { $0.range.contains(rangeStart) } )
            
            for attribute in attributesForWord {
                currentChunk.addAttributes(attribute.attribute, range: NSRange(location: rangeStartInChunk, length: word.count))
            }
            
            rangeStart += word.count + 1
            rangeStartInChunk += word.count + 1
        }
        
        if currentChunk.length > 0 {
            chunks.append(currentChunk)
        }
        
        return chunks
    }
    
    public static func measureText(_ text: NSAttributedString, width: CGFloat) -> CGSize {
        let textStorage = NSTextStorage(attributedString: text)
        let textContainer = NSTextContainer(size: CGSize(width: width, height: .greatestFiniteMagnitude))
        let layoutManager = NSLayoutManager()
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0.0
        layoutManager.glyphRange(for: textContainer)
        
        return layoutManager.usedRect(for: textContainer).size
    }
}

struct SegmentViewImageStory: StyledBlock, View {
    var block: StorySlide
    var defaultStyles: Style
    
    @State var attrStringInitialied: Bool = false
    
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    var attributedString: AttributedString {
        return Styler.getStyledText(block.markdown, defaultStyles, StoryStyleTemplate(), AnyBlock(block))
    }
    
    @State private var chunks: [NSAttributedString]
    
    @State private var offset: CGFloat = 0
    @State private var totalOffset: CGFloat = 0
    @State private var imageOffset: CGFloat = 0
    @State private var totalOffsets: [Int: CGFloat] = [:]
    @State private var imageSizeWidth: CGFloat = 0
    
    @State private var selection: Int = 0
    @State private var alignment: TextAlignment = .leading
    
    @StateObject private var imageLoader = ImageLoader()
    
    init (block: StorySlide, defaultStyles: Style) {
        self.block = block
        self.defaultStyles = defaultStyles
        
        _chunks = State(initialValue: AttributedString.splitAttributedString(NSAttributedString(Styler.getStyledText(block.markdown, defaultStyles, StoryStyleTemplate(), AnyBlock(block))), width: getAppVisibleSize().width - 40))
        
        _alignment = State(initialValue: Styler.getTextAlignment(defaultStyles, BlockStyleTemplate(), AnyBlock(block)))
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(0..<chunks.count, id: \.self) { index in
                VStack {
                    if block.alignment == .bottom {
                        Spacer()
                    }

                    Text(AttributedString(chunks[index]))
                        .frame(width: screenSizeMonitor.screenSize.width - 40, alignment: Styler.convertTextAlignment(alignment))
                        .padding(.horizontal, 20)
                        .if(block.alignment == .top) { view in
                            view.padding(.top, 90)
                        }
                        .if(block.alignment == .bottom) { view in
                            view.padding(.bottom, 80)
                        }
                        .multilineTextAlignment(alignment)

                    if block.alignment == .top {
                        Spacer()
                    }
                }
                .tag(index)
                .overlay(OffsetProxy())
                .onPreferenceChange(OffsetKey.self) { offset in
                    let offsetToSave = offset < -screenSizeMonitor.screenSize.width ? -screenSizeMonitor.screenSize.width : offset
                    totalOffsets[index] = offsetToSave
    
                    let offsetVal: CGFloat = totalOffsets.values.filter { $0 < 0 }.reduce(0, +)
                    totalOffset = offsetVal < (-1 * (CGFloat(chunks.count - 1)) * screenSizeMonitor.screenSize.width) ? totalOffset : offsetVal
    
                    imageOffset = totalOffset / (CGFloat(chunks.count-1)*screenSizeMonitor.screenSize.width / (imageSizeWidth-screenSizeMonitor.screenSize.width))
                }
                .frame(alignment: block.alignment == .top ? .top : .bottom)
                .frame(width: screenSizeMonitor.screenSize.width)
            }
        }
        .background {
            ZStack (alignment: block.alignment == .top ? .top : .bottom) {
                VStack {
                    if let image = imageLoader.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: screenSizeMonitor.screenSize.width, height: screenSizeMonitor.screenSize.height, alignment: .leading)
                            .offset(x: imageOffset <= 0 ? imageOffset : 0, y: 0)
                            .edgesIgnoringSafeArea(.top)
                            .onAppear {
                                imageSizeWidth = (image.size.width / image.size.height) * screenSizeMonitor.screenSize.height
                            }
                    } else {
                        ProgressView()
                            .onAppear {
                                imageLoader.loadImage(from: block.image)
                            }
                    }
//                    LazyImage(url: block.image) { state in
//                        if let image = state.image {
//                            image
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: screenSizeMonitor.screenSize.width, height: screenSizeMonitor.screenSize.height, alignment: .leading)
//                                .offset(x: imageOffset <= 0 ? imageOffset : 0, y: 0)
//                        } else {
//                            ProgressView()
//                        }
//                    }
//                    .frame(width: screenSizeMonitor.screenSize.width, height: screenSizeMonitor.screenSize.height, alignment: .leading)
//                    .edgesIgnoringSafeArea(.top)
//                    .id(block.id)
                }
                .frame(width: screenSizeMonitor.screenSize.width, height: screenSizeMonitor.screenSize.height)
                .ignoresSafeArea(.all)
                .clipped()
                
                Rectangle()
                    .fill(Styler.getBlockBackgroundColor(defaultStyles, AnyBlock(block)))
                    .frame(width: screenSizeMonitor.screenSize.width, height: UIFont(name: "Lato-Regular", size: 28)!.lineHeight * 3 + 120)
            }
            .edgesIgnoringSafeArea(.all)
            .frame(width: screenSizeMonitor.screenSize.width, height: screenSizeMonitor.screenSize.height)
        }
        .onChange(of: screenSizeMonitor.screenSize.width) { newValue in
            chunks = AttributedString.splitAttributedString(NSAttributedString(attributedString), width: newValue - 40)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(width: screenSizeMonitor.screenSize.width)
    }
}

struct SegmentViewStory: View {
    var segment: Segment

    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @EnvironmentObject var documentViewOperator: DocumentViewOperator
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    @State var selection: Int = 0

    var body: some View {
        TabView(selection: $selection) {
            if let story = segment.blocks?.first?.asType(Story.self) {
                ForEach(Array(story.items.enumerated()), id: \.offset) { index, storySlide in
                    SegmentViewImageStory(block: storySlide, defaultStyles: defaultStyles).tag(index)
                        .environmentObject(screenSizeMonitor)
                }
            }
        }
        .onTapGesture {
            documentViewOperator.setShowTabBar(!documentViewOperator.shouldShowTabBar(), force: true)
            documentViewOperator.setShowNavigationBar(!documentViewOperator.shouldShowNavigationBar)
            documentViewOperator.setShowSegmentChips(!documentViewOperator.shouldShowSegmentChips())
        }
        .edgesIgnoringSafeArea(.bottom)
        .edgesIgnoringSafeArea(.top)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(width: screenSizeMonitor.screenSize.width, height: screenSizeMonitor.screenSize.height)
    }
}
