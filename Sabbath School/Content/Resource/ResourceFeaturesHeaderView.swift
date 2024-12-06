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

struct ResourceFeaturesHeaderView: View {
    let featureSize: CGSize = AppStyle.Resources.Resource.Features.size
    var features: [ResourceFeature]
    var style: Style?
    var body: some View {
        if features.count > 0 {
            HStack(spacing: AppStyle.Resources.Resource.Features.spacingBetweenSplashFeatures) {
                ForEach(features, id: \.title) { feature in
                    AsyncImage(url: feature.image) { image in
                        image.image?.resizable()
                            .renderingMode(.template)
                            .foregroundColor(
                                Styler.getTextColor(style, ResourceDescriptionStyleTemplate()).opacity(0.7)
                            )
                    }.frame(width: featureSize.width, height: featureSize.height)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        } else {
            EmptyView()
        }
    }
}
