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

struct BlockQuestionView: StyledBlock, InteractiveBlock, View {
    var block: Question
    @Environment(\.nested) var nested: Bool
    @Environment(\.defaultBlockStyles) var defaultStyles: DefaultBlockStyles
    @Environment(\.userInput) var userInput: [AnyUserInput]
    
    @EnvironmentObject var viewModel: DocumentViewModel
    
    @State var answer: String = ""
    @State private var typingTimer: Timer? = nil
    let delay: TimeInterval = 2.0
    
    var body: some View {
        VStack (spacing: 0) {
            VStack (spacing: 0) {
                let alignment = getTextAlignment(block: AnyBlock(block))
                InlineAttributedText(block: AnyBlock(block), markdown: block.markdown).frame(maxWidth: .infinity, alignment: BlockParagraphView.convertTextAlignment(alignment))
                    .padding(20)
                Divider().background(.gray.opacity(0.4))
            }.padding(0)
                .background(Color(UIColor(hex: "#f9f9f9")))
            
            VStack (spacing: 0) {
                TextEditor(text: $answer)
                .onChange(of: answer) { newValue in
                    resetTypingTimer()
                }
                    .frame(maxHeight: 200, alignment: .leading)
                    .font(Font(R.font.latoRegular(size: sizePoints(size: .base))!))
                    .scrollContentBackground(.hidden)
                    .padding(.leading, 50)
                    .padding(.vertical, 0)
                    .overlay {
                        HStack(spacing: 0) {
                            Divider().background(.red)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 40)
                    }.background {
                        VStack {
                            Image("question-line")
                                .resizable(resizingMode: .tile)
                                .colorMultiply(.gray.opacity(0.2))
                        }.padding(0)
                    }
            }.padding(0)
                .background(Color(UIColor(hex: "#faf8fa")))
                .frame(alignment: .leading)
                
        }.frame(maxWidth: .infinity, alignment: .leading)
            .cornerRadius(3)
            .padding(.vertical, 10)
            .onChange(of: userInput) { newValue in
                self.answer = getAnswerBlockValue(userInput: newValue)
            }
    }
    
    func resetTypingTimer() {
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            if answer != getAnswerBlockValue() {
                self.saveUserInput(AnyUserInput(UserInputQuestion(blockId: block.id, inputType: .question, answer: self.answer)))
            }
        }
    }
    
    func getAnswerBlockValue(userInput: [AnyUserInput]? = nil) -> String {
        return getUserInputForBlock(blockId: block.id, userInput: userInput)?.asType(UserInputQuestion.self)?.answer ?? ""
    }
}
