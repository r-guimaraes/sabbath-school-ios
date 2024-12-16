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

struct BlockTableView: View {
    var block: TableBlock
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 0)],
                alignment: .leading,
                spacing: 0
            ) {
                
                HStack(alignment: .top, spacing: 0) {
                    tableRow(TableRow(items: block.header), true)
                }
                .padding(0)
                .background(Color(uiColor: .baseGray1) | AppStyle.Block.genericBackgroundColorForInteractiveBlock(theme: themeManager.currentTheme))
                
                Divider()
                
                ForEach(Array(block.rows.enumerated()), id: \.offset) { rowIndex, row in
                    HStack(alignment: .top, spacing: 0) {
                        tableRow(row)
                    }
                    .padding(0)
                    
                    Divider()
                }
            }
            .border(.gray.opacity(0.2))
            .padding(0)
        }
        .padding(0)
    }
    
    func tableRow (_ row: TableRow, _ header: Bool = false) -> some View {
        ForEach(Array(row.items.enumerated()), id: \.offset) { cellIndex, cell in
            VStack (spacing: AppStyle.Segment.Spacing.betweenBlocks)  {
                ForEach(cell.items) { cellBlock in
                    BlockWrapperView(block: cellBlock, parentBlock: AnyBlock(block))
                }
            }
            .frame(minWidth: Helper.isPad ? screenSizeMonitor.screenSize.width / (Helper.isLandscape ? 4 : 3) : screenSizeMonitor.screenSize.width / 1.5, alignment: .leading)
            .frame(maxWidth: Helper.isPad ? screenSizeMonitor.screenSize.width / (Helper.isLandscape ? 4 : 3) : screenSizeMonitor.screenSize.width / 1.5, alignment: .leading)
            .padding(.vertical, AppStyle.Segment.Spacing.verticalPaddingContent)
            
            Divider()
        }
    }
}
