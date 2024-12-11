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
import Down

struct ResourceIntroductionTextView: UIViewRepresentable {
    let attributedString: NSAttributedString
    @Binding var height: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedString
        uiView.invalidateIntrinsicContentSize()
        
        let size = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        if height != size.height {
            DispatchQueue.main.async {
                self.height = size.height
            }
        }
    }
}

struct ResourceIntroductionView: View {
    var introduction: String
    var attributedString: NSAttributedString

    @State private var textViewHeight: CGFloat = 0
    
    init (introduction: String) {
        self.introduction = introduction
        let down = Down(markdownString: introduction)
        self.attributedString = try! down.toAttributedString(stylesheet: AppStyle.Resources.Resource.Introduction.stylesheet)
    }

    var body: some View {
//        ScrollView {
//            
//        }
//        .frame(maxWidth: .infinity)
//        .frame(maxHeight: .infinity)
        VStack {
            ResourceIntroductionTextView(
                attributedString: attributedString,
                height: $textViewHeight
            )
            .frame(height: textViewHeight)
            .frame(maxHeight: .infinity)
        }
        .frame(height: textViewHeight)
        .frame(maxHeight: .infinity)
        .padding()
    }
}

struct ResourceIntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceIntroductionView(introduction: "### Hello world")
    }
}


