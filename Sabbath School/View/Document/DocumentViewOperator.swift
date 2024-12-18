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
import SwiftAudio
import AVKit

extension UIScreen {
    static var topSafeArea: CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        return (keyWindow?.safeAreaInsets.top) ?? 0
    }
    
    static var bottomSafeArea: CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        return (keyWindow?.safeAreaInsets.bottom) ?? 0
    }
}

class DocumentViewOperator: ObservableObject {
    @Published var chipsTopPadding: CGFloat = 0.0
    @Published var chipsBarHeight: CGFloat = 0.0
    @Published var scrollOffset: CGFloat = 0.0
    @Published var activeTab: Int = 0
    @Published var showNavigationBarVals: [Int: Bool] = [:]
    @Published var navigationBarTitles: [Int: String] = [:]
    @Published var showTabBarVals: [Int: Bool] = [:]

    @Published var showSegmentChips: Bool = false
    @Published var segmentChipsEnabled: Bool = false
    @Published var segmentChipsStyle: SegmentChipsStyle = .menu
    
    @Published var showCovers: [Int: Bool] = [:]
    
    @Published var hiddenSegmentIterator: Int = 0
    @Published var hiddenSegmentID: String? = nil
    @Published var hiddenSegment: Segment? = nil
    @Published var shouldShowHiddenSegment: Bool = false
    
    public func setShowCovers(_ value: Bool, tab: Int? = nil) {
        showCovers[tab ?? activeTab] = value
    }
    
    public func shouldShowCovers() -> Bool {
        return showCovers[activeTab] ?? false
    }
    
    public func setShowNavigationBar(_ value: Bool, tab: Int? = nil) {
        showNavigationBarVals[tab ?? activeTab] = value
    }
    
    public var shouldShowNavigationBar: Bool {
        return showNavigationBarVals[activeTab] ?? false
    }
    
    public func setShowTabBar(_ value: Bool, tab: Int? = nil, force: Bool = false) {
        showTabBarVals[tab ?? activeTab] = value
        if force {
            self.toggleTabBar(!value)
        }
    }
    
    public func shouldShowTabBar() -> Bool {
        return showTabBarVals[activeTab] ?? true
    }
    
    public var navigationBarTitle: String {
        return shouldShowNavigationBar ? navigationBarTitles[activeTab] ?? "" : ""
    }
    
    var navigationBarHeight: CGFloat {
        let navController = UINavigationController()
        return navController.navigationBar.frame.height
    }
    
    public var topSafeAreaInset: CGFloat {
        return UIScreen.topSafeArea
    }
    
    public var bottomSafeAreaInset: CGFloat {
        return UIScreen.bottomSafeArea
    }
    
    public func toggleTabBar(_ hidden: Bool) {
        UIApplication.shared.currentTabBarController()?.tabBar.isHidden = hidden
    }
    
    var tabBarHeight: CGFloat {
        return UIApplication.shared.currentTabBarController()?.tabBar.frame.height ?? 0
    }
}
