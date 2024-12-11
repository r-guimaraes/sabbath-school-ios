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

class MultipleChoiceViewModel: ObservableObject {
    @Published var answer: Int = -1
    @Published var choice: Int = -1
    @Published var savingMode: Bool = false
    
    public func loadUserInput(userInput: UserInputMultipleChoice) {
        self.choice = userInput.choice
    }
    
    public func receiveChoiceSelection(index: Int) {
        savingMode = true
        self.choice = index
    }
}

struct BlockMultipleChoiceView: StyledBlock, InteractiveBlock, View {
    var block: MultipleChoice
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    @EnvironmentObject var viewModel: DocumentViewModel
    @StateObject var multipleChoiceViewModel: MultipleChoiceViewModel = MultipleChoiceViewModel()
    
    var body: some View {
        VStack (spacing: 5) {
            ForEach(block.items) { item in
                BlockWrapperView(block: item)
                    .environmentObject(multipleChoiceViewModel)
            }
        }
        .onAppear {
            loadInputData()
        }
        .onChange(of: viewModel.documentUserInput) { newValue in
            loadInputData()
        }.onChange(of: multipleChoiceViewModel.choice) { newValue in
            if !multipleChoiceViewModel.savingMode { return }
            
            saveUserInput(AnyUserInput(UserInputMultipleChoice(blockId: block.id, inputType: .multipleChoice, choice: newValue)))
        }.task {
            multipleChoiceViewModel.answer = block.answer
        }
    }
    
    internal func loadInputData() {
        if let userInput = getUserInputForBlock(blockId: block.id, userInput: nil)?.asType(UserInputMultipleChoice.self) {
            multipleChoiceViewModel.loadUserInput(userInput: userInput)
        }
    }
}

struct BlockMultipleChoiceItemView: StyledBlock, View {
    var block: MultipleChoiceItem
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    @EnvironmentObject var viewModel: MultipleChoiceViewModel
    
    @State var selected: Bool = false
    
    var body: some View {
        VStack {
            Button(action: {
                viewModel.receiveChoiceSelection(index: block.index)
            }) {
                HStack {
                    Image(systemName: viewModel.choice == block.index ? "smallcircle.filled.circle.fill" : "circle")
                        .foregroundColor(viewModel.choice == block.index ? (viewModel.answer == block.index ? .green : .red) : .gray)
                    InlineAttributedText(block: AnyBlock(block), markdown: block.markdown).frame(maxWidth: .infinity, alignment: .leading)
                }
            }.padding(10)
            
        }.overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray, lineWidth: 2)
        )
        .cornerRadius(6)
    }
}
