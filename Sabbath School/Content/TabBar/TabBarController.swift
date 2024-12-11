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
    
    func currentNavigationController() -> UINavigationController? {
        guard let rootController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else {
                return nil
            }
        return findNavigationController(controller: rootController)
    }

    private func findNavigationController(controller: UIViewController) -> UINavigationController? {
        // If the controller itself is a UINavigationController
        if let navigationController = controller as? UINavigationController {
            return navigationController
        }
        
        // If the controller is a UITabBarController, check the selected view controller
        if let tabBarController = controller as? UITabBarController,
           let selectedController = tabBarController.selectedViewController {
            return findNavigationController(controller: selectedController)
        }
        
        // If the controller is presenting another controller
        if let presentedController = controller.presentedViewController {
            return findNavigationController(controller: presentedController)
        }
        
        // Recursively search children view controllers
        for child in controller.children {
            if let navigationController = findNavigationController(controller: child) {
                return navigationController
            }
        }
        
        return nil
    }
}
