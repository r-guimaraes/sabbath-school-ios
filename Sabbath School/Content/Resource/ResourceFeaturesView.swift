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

struct ResourceFeaturesView: View {
    var features: [ResourceFeature]
    let featureSize: CGSize = AppStyle.Resources.Resource.Features.size
    
    var body: some View {
        VStack (spacing: AppStyle.Resources.Resource.Features.spacingBetweenFeatures) {
            ForEach (features, id: \.title) { feature in
                VStack (alignment: .leading) {
                    HStack {
                        AsyncImage(url: feature.image) { image in
                            image.image?.resizable()
                                .renderingMode(.template)
                                .colorMultiply(AppStyle.Resources.Resource.Features.color)
                        }.frame(width: featureSize.width, height: featureSize.height)

                        Text(AppStyle.Resources.Resource.Features.featureName(feature.title))
                            .frame(alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Text(AppStyle.Resources.Resource.Features.featureDescription(feature.description))
                        .frame(alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
