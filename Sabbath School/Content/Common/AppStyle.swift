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

infix operator |: AdditionPrecedence

public extension Color {
    static func | (lightMode: Color, darkMode: Color) -> Color {
        return Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .light ? UIColor(lightMode) : UIColor(darkMode)
        })
    }
}

extension AppStyle {
    struct Resources {
        struct Size {
            // Main function to provide sizes for cover images
            static func coverSize(coverType: ResourceCoverType, direction: FeedGroupDirection, viewType: FeedGroupViewType, initialWidth: CGFloat = UIScreen.main.bounds.width) -> CGSize {
                let COVER_MAX_WIDTH = 210.0
                var width: CGFloat = initialWidth - 40 // TODO: spacing * 2
                var height = 200.0
                
                if direction == .vertical {
                    switch coverType {
                    case .landscape:
                        if (viewType == .tile) {
                            width = width * 0.35
                        }
                        height = width / coverType.aspectRatio
                    case .portrait:
                        width = width * 0.30
                    case .square:
                        width = width * 0.30
                    case .splash:
                        height = width / coverType.aspectRatio
                    }
                }
                
                if direction == .horizontal {
                    switch coverType {
                    case .landscape:
                        if (Helper.isPad) {
                            width = width * 0.4
                        } else {
                            width = viewType == .banner ? width * 0.9 : width * 0.70
                        }
                        
                    case .portrait:
                        width = width * 0.40
                    case .square:
                        width = width * 0.40
                    case .splash:
                        height = width / coverType.aspectRatio
                    }
                }
                
                if (Helper.isPad
                    && ((direction == .horizontal && (viewType == .square || viewType == .folio))
                    || (direction == .vertical && (viewType == .square || viewType == .folio)))) {
                    width = min(width, COVER_MAX_WIDTH)
                }
                
                height = width / coverType.aspectRatio
                
                return CGSize(width: width, height: height)
            }
        }
        
        struct Text {
            static func resourceTitle(string: String, viewType: FeedGroupViewType = .folio) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = AppStyle.Base.Color.navigationTitle
                if (viewType == .banner) {
                    result.foregroundColor = .white
                }
                result.font = R.font.latoBold(size: 15)!
                return result
            }
            
            static func resourceSubTitle(string: String, viewType: FeedGroupViewType = .folio) -> AttributedString {
                var result = AttributedString(string)
                result.foregroundColor = UIColor.baseGray2
                if (viewType == .banner) {
                    result.foregroundColor = .white.opacity(0.8)
                }
                result.font = R.font.latoRegular(size: 13)!
                return result
            }
        }
    }
}
