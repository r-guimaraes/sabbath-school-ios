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

import Foundation

struct List: BlockProtocol {
    let id: String
    let type: BlockType
    let style: BlockStyle?
    let data: BlockData?
    let depth: Int?
    let ordered: Bool?
    let start: Int?
    let items: [AnyBlock]
    let nested: Bool?
    
    var bullet: String {
        guard let depth = depth else {
            return "•"
        }
        
        let bullets = ["•", "◦", "▪", "▫", "►", "▻"]
        return bullets[(depth - 1) % bullets.count]
    }
}

struct ListItem: BlockProtocol {
    let id: String
    let type: BlockType
    let style: BlockStyle?
    let index: Int?
    let markdown: String
    let data: BlockData?
    let nested: Bool?
}
