/*
 * Copyright (c) 2022 Adventech <info@adventech.io>
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

import Combine

class ScreenSizeMonitor: ObservableObject {
    @Published var screenSize: CGSize = UIScreen.main.bounds.size
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                self?.updateScreenSize()
            }
            .store(in: &cancellables)
    }
    
    private func updateScreenSize() {
        DispatchQueue.main.async {
            self.screenSize = UIScreen.main.bounds.size
        }
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}


class TabBarViewController: ASTabBarController {
    private var screenSizeMonitor = ScreenSizeMonitor()

    var iconMargins: UIEdgeInsets {
        return UIEdgeInsets(top: Helper.isPad ? 0 : 9, left: 0, bottom: Helper.isPad ? 0 : -9, right: 0)
    }
    
    func tabBarControllersFor(pm: Bool = true,
                              devo: Bool = true,
                              quarterlyIndex: String? = nil,
                              lessonIndex: String? = nil,
                              readIndex: Int? = nil,
                              initiateOpen: Bool = false) -> [UIViewController] {
        
        let sabbathSchool = QuarterlyWireFrame.createQuarterlyModule()
        
        let devotional = UIHostingController(rootView: FeedView(resourceType: .devo).environmentObject(screenSizeMonitor))
        let personalMinistries = UIHostingController(rootView: FeedView(resourceType: .pm).environmentObject(screenSizeMonitor))
        let settings = ASDKNavigationController(rootViewController: SettingsController())
        
        if let quarterlyIndex = quarterlyIndex {
            let lessonController = LessonWireFrame.createLessonModule(quarterlyIndex: quarterlyIndex, initiateOpenToday: initiateOpen)
            sabbathSchool.pushViewController(lessonController, animated: false)
            
            if let lessonIndex = lessonIndex {
                let readController = ReadWireFrame.createReadModule(lessonIndex: lessonIndex, readIndex: readIndex)
                sabbathSchool.pushViewController(readController, animated: false)
            }
        }
        
        sabbathSchool.tabBarItem.image = R.image.iconNavbarSs()
        personalMinistries.tabBarItem.image = R.image.iconNavbarPm()
        devotional.tabBarItem.image = R.image.iconNavbarDevo()
        settings.tabBarItem.image = R.image.iconNavbarProfile()
        
        
        if #available(iOS 13, *) {
            sabbathSchool.tabBarItem.imageInsets = self.iconMargins
            personalMinistries.tabBarItem.imageInsets = self.iconMargins
            devotional.tabBarItem.imageInsets = self.iconMargins
            settings.tabBarItem.imageInsets = self.iconMargins
        }
        
        var viewControllers: [UIViewController] = [sabbathSchool]
        
        if pm {
            viewControllers.append(personalMinistries)
        }
        
        if devo {
            viewControllers.append(devotional)
        }
        
        viewControllers.append(settings)
        
        return viewControllers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
}

private extension TabBarViewController {
    func setupUI() {
        if #available(iOS 13.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
            
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
    }
}
