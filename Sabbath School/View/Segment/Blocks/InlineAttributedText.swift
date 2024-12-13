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
import SwiftEntryKit
import SafariServices

struct InlineTextViewWrapper: UIViewRepresentable {
    var attributedString: AttributedString
    @Binding var height: CGFloat
    var onLinkClick: ((URL) -> Void)?
    var onHighlight: ((NSRange, HighlightColor) -> Void)?
    var onRemoveHighlight: ((NSRange) -> Void)?
    var alignment: TextAlignment

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        
        textView.dataDetectorTypes = []
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.adjustsFontForContentSizeCategory = true
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.accessibilityElementsHidden = true

        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
        
        return textView
    }
    
   

    func updateUIView(_ textView: UITextView, context: Context) {
        let attributedText = NSMutableAttributedString(attributedString)
        
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.clear]
        
                
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        switch alignment {
        case .leading:
            paragraphStyle.alignment = .left
        case .trailing:
            paragraphStyle.alignment = .right
        case .center:
            paragraphStyle.alignment = .center
        }
        

        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.characters.count))
        attributedText.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.characters.count))
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length), options: []) { attributes, range, stop in
            var newAttributes = attributes
            newAttributes[.foregroundColor] = UIColor.clear
            attributedText.setAttributes(newAttributes, range: range)
        }
        
        textView.attributedText = attributedText
        
        textView.sizeToFit()
        
        DispatchQueue.main.async {
            self.height = textView.contentSize.height
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: InlineTextViewWrapper

        init(_ parent: InlineTextViewWrapper) {
            self.parent = parent
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            parent.onLinkClick?(URL)
            return false
        }
        
        
        func textView(_ textView: UITextView, editMenuForTextIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
            let highlightBlue = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightBlue), renderingMode: .alwaysOriginal)) { action in
                self.parent.onHighlight?(range, .blue)
            }
            
            let highlightGreen = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightGreen), renderingMode: .alwaysOriginal)) { action in
                self.parent.onHighlight?(range, .green)
            }
            
            let highlightOrange = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlighOrange), renderingMode: .alwaysOriginal)) { action in
                self.parent.onHighlight?(range, .orange)
            }

            let highlightYellow = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightYellow), renderingMode: .alwaysOriginal)) { action in
                self.parent.onHighlight?(range, .yellow)
            }
            
            let removeHighlight = UIAction(title: "", image: UIImage(systemName: "x.circle.fill")) { action in
                self.parent.onRemoveHighlight?(range)
            }
            
            let highlightMenu = UIMenu(title: "", image: UIImage(systemName: "highlighter"), children: [highlightBlue, highlightGreen, highlightOrange, highlightYellow, removeHighlight])

            return UIMenu(title: "", children: [highlightMenu] + suggestedActions)
        }
    

        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.height = textView.contentSize.height
            }
        }
        
        func textViewDidLayoutSubviews(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.height = textView.contentSize.height
            }
        }
    }
}

struct InlineAttributedText: StyledBlock, InteractiveBlock, View {
    var block: AnyBlock
    var markdown: String
    var selectable: Bool = false
    var lineLimit: Int? = nil
    var headingDepth: HeadingDepth? = nil
    
    @State var visible: Bool = false
    
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.openURL) private var openURL
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject private var paragraphViewModel: ParagraphViewModel = ParagraphViewModel()
    
    @EnvironmentObject var viewModel: DocumentViewModel
    
    @State private var height: CGFloat = .zero
    @State private var width: CGFloat = .zero
    @State private var attributedString: AttributedString = AttributedString("")
    @State private var attributedStringWithoutHighlights: AttributedString = AttributedString("")
    
    @State private var initialized = false
    
    init (block: AnyBlock, markdown: String, selectable: Bool = false, lineLimit: Int? = nil, headingDepth: HeadingDepth? = nil) {
        self.block = block
        self.markdown = markdown
        self.selectable = selectable
        self.lineLimit = lineLimit
        self.headingDepth = headingDepth
    }
    
    var body: some View {
        let alignment = Styler.getTextAlignment(defaultStyles, BlockStyleTemplate(), block)
        
        return Text(attributedString)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(5)
                .overlay(selectable ? overlaySelectableText(attributedString: attributedStringWithoutHighlights, alignment: alignment) : nil, alignment: .top)
                .multilineTextAlignment(alignment)
                .lineLimit(lineLimit)
                .foregroundColor(.white)
                .environment(\.openURL, OpenURLAction { url in
                    handleURL(url: url)
                    return .handled
                }).task {
                    if !initialized {
                        initializeText()
                    }
                    
                    loadInputData()
                }
                .onChange(of: themeManager.currentTheme) { newValue in
                    initializeText()
                }
                .onChange(of: themeManager.currentSize) { newValue in
                    initializeText()
                }
                .onChange(of: themeManager.currentTypeface) { newValue in
                    initializeText()
                }
                .onChange(of: colorScheme) { newValue in
                    initializeText()
                }
                .onChange(of: sizeCategory) { newValue in
                    initializeText()
                }
                .onChange(of: viewModel.documentUserInput) { newValue in
                    loadInputData()
                }
                .onChange(of: paragraphViewModel.highlights) { newValue in
                    setHighlights(highlights: newValue)
                    
                    if !paragraphViewModel.savingMode { return }
                    
                    saveUserInput(AnyUserInput(UserInputHighlights(blockId: block.id, inputType: .highlights, highlights: newValue)))
                }
    }
    
    internal func initializeText () {
        var template = BlockStyleTemplate()
        
        if let headingDepth = headingDepth {
            template = HeadingStyleTemplate(depth: headingDepth)
        }
        
        attributedString = AppStyle.Block.text(markdown, defaultStyles, block, template)
        attributedStringWithoutHighlights = attributedString
        initialized = true
        setHighlights(highlights: paragraphViewModel.highlights)
    }
    
    internal func loadInputData() {
        if let userInput = getUserInputForBlock(blockId: block.id, userInput: viewModel.documentUserInput)?.asType(UserInputHighlights.self) {
            paragraphViewModel.loadUserInput(userInput: userInput)
        }
    }
    
    private func setHighlights(highlights: [UserInputHighlight]) {
        attributedString = attributedStringWithoutHighlights
        
        for highlight in highlights {
            let range = NSRange(location: highlight.startIndex, length: highlight.length)
            var backgroundColor: Color
            if let range = Range(range, in: attributedString) {
                switch highlight.color {
                case .yellow:
                    backgroundColor = AppStyle.Block.highlightYellow
                case .blue:
                    backgroundColor = AppStyle.Block.highlightBlue
                case .orange:
                    backgroundColor = AppStyle.Block.highlighOrange
                case .green:
                    backgroundColor = AppStyle.Block.highlightGreen
                }
                
                attributedString[range].backgroundColor = backgroundColor
            }
        }
    }
    
    @ViewBuilder
    func overlaySelectableText(attributedString: AttributedString, alignment: TextAlignment) -> some View {
        InlineTextViewWrapper(
            attributedString: attributedStringWithoutHighlights,
            height: $height,
            onLinkClick: handleURL,
            onHighlight: onHighlight,
            onRemoveHighlight: onRemoveHighlight,
            alignment: alignment
        )
          .frame(height: height, alignment: .leading)
          .padding(0)
    }
    
    private func handleURL(url: URL) {
        if let data = block.data,
           let host = url.host,
           let bible = data.bible?[host],
           url.absoluteString.contains("sspmBible") {
            
            let hostingController = UIHostingController(
                rootView: ResourceBibleView(block: bible)
                    .environmentObject(viewModel)
                    .environmentObject(themeManager)
            )
            hostingController.view.layer.cornerRadius = 6
            
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            SwiftEntryKit.display(entry: hostingController, using: Animation.modalAnimationAttributes(widthRatio: 0.9, heightRatio: 0.8, backgroundColor: UIColor(themeManager.getBackgroundColor())))
        } else if let data = block.data,
                  let host = url.host,
                  let paragraphs = data.egw?[host],
                  url.absoluteString.contains("sspmEGW") {
            
            let hostingController = UIHostingController(rootView:ResourceEGWView(paragraphs: paragraphs).environmentObject(viewModel).environmentObject(themeManager)
            )
            hostingController.view.layer.cornerRadius = 6
            
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            
            SwiftEntryKit.display(entry: hostingController, using: Animation.modalAnimationAttributes(widthRatio: 0.9, heightRatio: 0.8, backgroundColor: UIColor(themeManager.backgroundColor)))
        } else {
            openURL(url)
            
        }
    }
    
    private func onHighlight(range: NSRange, color: HighlightColor) {
        paragraphViewModel.setHighlight(startIndex: range.location, endIndex: range.location + range.length, length: range.length, color: color)
    }
    
    private func onRemoveHighlight(range: NSRange) {
        paragraphViewModel.removeHighlight(startIndex: range.location, endIndex: range.location + range.length, length: range.length)
    }
}
