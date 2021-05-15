/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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

import AsyncDisplayKit
import UIKit

class GCPopupController: ASDKViewController<ASDisplayNode> {
    var collectionNode: ASCollectionNode { return node as! ASCollectionNode }
    let collectionViewLayout = UICollectionViewFlowLayout()

    override init() {
        super.init(node: ASCollectionNode(collectionViewLayout: collectionViewLayout))
        collectionNode.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.view.backgroundColor = .baseBackground
        self.collectionNode.reloadData()
    }
}

extension GCPopupController: GCPopupViewDelegate {
    func didTapClose() {
        self.dismiss()
    }
}

extension GCPopupController: ASCollectionDataSource {
    func collectionView(_ collectionView: ASCollectionView, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let cellNodeBlock: () -> ASCellNode = {
            let view = GCPopupView()
            view.delegate = self
            return view
        }
        return cellNodeBlock
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
}
