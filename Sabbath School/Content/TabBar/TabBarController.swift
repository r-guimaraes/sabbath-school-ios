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
import UIKit

extension UIApplication {
    func getActiveViewController() -> UIViewController? {
        guard let rootController = connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        return findActiveViewController(from: rootController)
    }

    private func findActiveViewController(from viewController: UIViewController) -> UIViewController? {
        if let presentedViewController = viewController.presentedViewController {
            return findActiveViewController(from: presentedViewController)
        }
        if let navigationController = viewController as? UINavigationController {
            return navigationController.visibleViewController
        }
        if let tabBarController = viewController as? UITabBarController {
            return tabBarController.selectedViewController.flatMap { findActiveViewController(from: $0) }
        }
        return viewController
    }
    
    func currentTabBarController() -> UITabBarController? {
        guard let rootController = connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first(where: { $0.isKeyWindow })?.rootViewController else {
                return nil
            }
        return findTabBarController(controller: rootController)
    }
    
    private func findTabBarController(controller: UIViewController) -> UITabBarController? {
        if let tabBarController = controller as? UITabBarController {
            return tabBarController
        }
        for child in controller.children {
            if let tabBarController = findTabBarController(controller: child) {
                return tabBarController
            }
        }
        return nil
    }
}


//extension UIApplication {
//    var rootViewController: UIViewController? {
//        // Find the connected scene with a UIWindowScene
//        guard let windowScene = connectedScenes.first as? UIWindowScene,
//              let window = windowScene.windows.first else {
//            return nil
//        }
//        return window.rootViewController
//    }
//}

class TabBarViewController: ASTabBarController, UITabBarControllerDelegate {
    private var screenSizeMonitor = ScreenSizeMonitor()
    private var themeManager = ThemeManager()
    
    @State private var sspath: [NavigationStep] = []
    
    @State private var aijpath: [NavigationStep] = []
    
    @State private var pmpath: [NavigationStep] = []
    
    @State private var devopath: [NavigationStep] = []
    
    
    var iconMargins: UIEdgeInsets {
        return UIEdgeInsets(top: Helper.isPad ? 0 : 9, left: 0, bottom: Helper.isPad ? 0 : -9, right: 0)
    }
    
    func tabBarControllersFor(aij: Bool = true,
                              pm: Bool = true,
                              devo: Bool = true,
                              ss: Bool = true,
                              quarterlyIndex: String? = nil,
                              lessonIndex: String? = nil,
                              readIndex: Int? = nil,
                              initiateOpen: Bool = false) -> [UIViewController] {
        
        
        
        
        let sabbathSchoolV3 = UIHostingController(rootView: FeedView(resourceType: .ss, path: $sspath)
            .environmentObject(screenSizeMonitor)
            .environmentObject(themeManager)
        )
        
        let aliveInJesus = UIHostingController(rootView: FeedView(resourceType: .aij, path: $aijpath)
            .environmentObject(screenSizeMonitor)
            .environmentObject(themeManager)
        )
        let personalMinistries = UIHostingController(rootView: FeedView(resourceType: .pm, path: $pmpath)
            .environmentObject(screenSizeMonitor)
            .environmentObject(themeManager)
        )
        let devotional = UIHostingController(rootView: FeedView(resourceType: .devo, path: $devopath)
            .environmentObject(screenSizeMonitor)
            .environmentObject(themeManager)
        )
        
        let settings = ASDKNavigationController(rootViewController: SettingsController())
        
        sabbathSchoolV3.tabBarItem.image = R.image.iconNavbarSs()
        sabbathSchoolV3.tabBarItem.title = nil
        aliveInJesus.tabBarItem.image = R.image.iconNavbarAij()
        aliveInJesus.tabBarItem.title = nil
        personalMinistries.tabBarItem.image = R.image.iconNavbarPm()
        personalMinistries.tabBarItem.title = nil
        devotional.tabBarItem.image = R.image.iconNavbarDevo()
        devotional.tabBarItem.title = nil
        settings.tabBarItem.image = R.image.iconNavbarProfile()
        settings.tabBarItem.title = nil
        
//        if let quarterlyIndex = quarterlyIndex {
//            let lessonController = LessonWireFrame.createLessonModule(quarterlyIndex: quarterlyIndex, initiateOpenToday: initiateOpen)
//            sabbathSchool.pushViewController(lessonController, animated: false)
//            
//            if let lessonIndex = lessonIndex {
//                let readController = ReadWireFrame.createReadModule(lessonIndex: lessonIndex, readIndex: readIndex)
//                sabbathSchool.pushViewController(readController, animated: false)
//            }
//        }
        
//        sabbathSchool.tabBarItem.imageInsets = self.iconMargins
        
        sabbathSchoolV3.tabBarItem.imageInsets = self.iconMargins
        aliveInJesus.tabBarItem.imageInsets = self.iconMargins
        personalMinistries.tabBarItem.imageInsets = self.iconMargins
        devotional.tabBarItem.imageInsets = self.iconMargins
        settings.tabBarItem.imageInsets = self.iconMargins
        
        var viewControllers: [UIViewController] = []
        
        if aij {
            viewControllers.append(aliveInJesus)
        }
        
        if pm {
            viewControllers.append(personalMinistries)
        }
        
        if devo {
            viewControllers.append(devotional)
        }
        
        if viewControllers.count == 0 {
            return viewControllers
        }
        
        if ss {
            viewControllers.insert(sabbathSchoolV3, at: 0)
        }
        
        viewControllers.append(settings)
        
        return viewControllers
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navController = viewController as? UINavigationController {
            navController.popToRootViewController(animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}
