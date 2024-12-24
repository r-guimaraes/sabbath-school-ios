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

extension String {
    func splitByNewLine() -> [String] {
        return self.split(separator: "\n\n").map { String($0) }
    }
}

extension AttributedString {
    init(styledMarkdown markdownString: String) throws {
        var output = try AttributedString(
            markdown: markdownString,
            options: .init(
                allowsExtendedAttributes: true,
                interpretedSyntax: .full,
                failurePolicy: .returnPartiallyParsedIfPossible
            ),
            baseURL: nil
        )

        for (intentBlock, intentRange) in output.runs[AttributeScopes.FoundationAttributes.PresentationIntentAttribute.self].reversed() {
            guard let intentBlock = intentBlock else { continue }
            for intent in intentBlock.components {
                switch intent.kind {
                case .header(level: let level):
                    switch level {
                    case 1:
                        output[intentRange].font = .custom("Lato-Bold", size: 28)
                    case 2:
                        output[intentRange].font = .custom("Lato-Bold", size: 25)
                    case 3:
                        output[intentRange].font = .custom("Lato-Bold", size: 23)
                    case 4:
                        output[intentRange].font = .custom("Lato-Bold", size: 21)
                    case 5:
                        output[intentRange].font = .custom("Lato-Bold", size: 19)
                    case 6:
                        output[intentRange].font = .custom("Lato-Bold", size: 17)
                    default:
                        break
                    }
                default:
                    break
                }
            }
            
            if intentRange.lowerBound != output.startIndex {
                output.characters.insert(contentsOf: "\n", at: intentRange.lowerBound)
            }
        }
        
        self = output
    }
}

struct ResourceIntroductionView: View {
    var introduction: String
    @State private var strings: [String]
    
    init (introduction: String) {
        self.introduction = introduction
        self._strings = State(initialValue: introduction.splitByNewLine())
        //State(initialValue: introduction.split(separator: "\n\n").map { String($0) })
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                ForEach(strings, id: \.self) { string in
                    Text(try! AttributedString(styledMarkdown: string))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("Lato-Regular", size: 20))
                        .textSelection(.enabled)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
        }.padding(.horizontal)
    }
}

struct ResourceIntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceIntroductionView(introduction: "# Hello world\n\n## Hello world\n\n### Hello World\n\nThis is the day")
    }
}


