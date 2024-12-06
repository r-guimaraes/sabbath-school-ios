//
//  StatusBarController.swift
//  Insert this into your project.
//  Created by Xavier Donnellon
//

import Foundation
import SwiftUI

enum Interposed {
    case pending
    case successful
    case failed
}

struct InterposedKey: EnvironmentKey {
    static let defaultValue: Interposed = .pending
}

extension EnvironmentValues {
    fileprivate(set) var interposed: Interposed {
        get { self[InterposedKey.self] }
        set { self[InterposedKey.self] = newValue }
    }
}

/// `UIApplication.keyWindow` is deprecated
extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first {
                $0.isKeyWindow
            }
    }
}

extension UIViewController {
    fileprivate enum Holder {
        static var statusBarStyleStack: [UIStatusBarStyle] = .init()
    }

    fileprivate func interpose() -> Bool {
        let sel1: Selector = #selector(
            getter: preferredStatusBarStyle
        )
        let sel2: Selector = #selector(
            getter: preferredStatusBarStyleModified
        )

        let original = class_getInstanceMethod(Self.self, sel1)
        let new = class_getInstanceMethod(Self.self, sel2)

        if let original = original, let new = new {
            method_exchangeImplementations(original, new)

            return true
        }

        return false
    }

    @objc dynamic var preferredStatusBarStyleModified: UIStatusBarStyle {
        Holder.statusBarStyleStack.last ?? .default
    }
}

struct StatusBarStyle: ViewModifier {
    @Environment(\.interposed) private var interposed

    let statusBarStyle: UIStatusBarStyle
    let animationDuration: TimeInterval

    private func setStatusBarStyle(_ statusBarStyle: UIStatusBarStyle) {
        UIViewController.Holder.statusBarStyleStack.append(statusBarStyle)

        UIView.animate(withDuration: animationDuration) {
            UIApplication.shared.keyWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                setStatusBarStyle(statusBarStyle)
            }
            .onChange(of: statusBarStyle) {
                setStatusBarStyle($0)
                UIViewController.Holder.statusBarStyleStack.removeFirst(1)
            }
            .onDisappear {
                UIViewController.Holder.statusBarStyleStack.removeFirst(1)

                UIView.animate(withDuration: animationDuration) {
                    UIApplication.shared.keyWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                }
            }
            // Interposing might still be pending on initial render
            .onChange(of: interposed) { _ in
                UIView.animate(withDuration: animationDuration) {
                    UIApplication.shared.keyWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                }
            }
    }
}

extension View {
    func statusBarStyle(
        _ statusBarStyle: UIStatusBarStyle,
        animationDuration: TimeInterval = 0.3
    ) -> some View {
        modifier(StatusBarStyle(statusBarStyle: statusBarStyle, animationDuration: animationDuration))
    }
}
