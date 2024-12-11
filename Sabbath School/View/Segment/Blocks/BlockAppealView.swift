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

struct BlockAppealView: StyledBlock, InteractiveBlock, View {
    var block: Appeal
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @EnvironmentObject var themeManager: ThemeManager
    
    @EnvironmentObject var viewModel: DocumentViewModel
    
    @State var checked = false
    
    var body: some View {
        Button(action: {
            checked = !checked
            self.saveUserInput(AnyUserInput(UserInputAppeal(blockId: block.id, inputType: .appeal, appeal: checked)))
        }) {
            HStack(spacing: 10) {
                Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
                    .foregroundColor(AppStyle.Block.Checklist.foregroundColor(theme: themeManager.currentTheme))
                    .animation(.easeInOut(duration: 0.3), value: checked)

                InlineAttributedText(block: AnyBlock(block), markdown: block.markdown).frame(maxWidth: .infinity, alignment: .leading)
            }
        }.onAppear {
            loadInputData()
        }.onChange(of: viewModel.documentUserInput) { newValue in
            loadInputData()
        }
    }
    
    internal func loadInputData() {
        self.checked = getUserInputForBlock(blockId: block.id, userInput: nil)?.asType(UserInputAppeal.self)?.appeal ?? false
    }
}
