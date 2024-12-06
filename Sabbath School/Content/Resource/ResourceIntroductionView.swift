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
import AsyncDisplayKit
import Down

class ResourceIntroductionController: ASDKViewController<ASDisplayNode> {
    var introduction: String
    var table = ASTableNode()
    let collectionViewLayout = UICollectionViewFlowLayout()
    
    init(introduction: String) {
        self.introduction = introduction
        super.init(node: table)
        table.dataSource = self
        table.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
}

extension ResourceIntroductionController: ASTableDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
}

extension ResourceIntroductionController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let cellNodeBlock: () -> ASCellNode = {
            return ResourceIntroductionViewCompat(introduction: self.introduction)
        }

        return cellNodeBlock
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

class ResourceIntroductionViewCompat: ASCellNode {
    let introduction = ASTextNode()

    init(introduction: String) {
        super.init()
        self.backgroundColor = AppStyle.Base.Color.background
        let down = Down(markdownString: introduction)
        self.introduction.attributedText = try? down.toAttributedString(stylesheet: AppStyle.Quarterly.Style.introductionStylesheet)

        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: introduction)
    }
}

struct ResourceIntroductionView: UIViewControllerRepresentable {
    var introduction: String
    
    func makeUIViewController(context: Context) -> ASDKViewController<ASDisplayNode> {
        return ResourceIntroductionController(introduction: introduction)
    }

    func updateUIViewController(_ uiViewController: ASDKViewController<ASDisplayNode>, context: Context) {}
}
