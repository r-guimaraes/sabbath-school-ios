/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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

import Armchair
import Alamofire
import AsyncDisplayKit
import AuthenticationServices
import FontBlaster
import GoogleSignIn
import UIKit
import StoreKit
import WidgetKit
import PSPDFKit
import SwiftUI
import Nuke

class Configuration: NSObject {
    static var window: UIWindow?
    private static var screenSizeMonitor = ScreenSizeMonitor()
    private static var themeManager = ThemeManager()
    
    static func configureUI() {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = AppStyle.Base.Color.background
        appearance.backgroundEffect = nil
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFontMetrics.default.scaledFont(for: R.font.latoBlack(size: 36)!)
        ]
        
        appearance.largeTitleTextAttributes = attrs
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    static func configurePDF() {
        SDK.setLicenseKey("cJGk5VhG4CHpFwBMb0qi8Y93Ac2y4XnKQlN166tNY6-N3pQQGrBTxVzbGwG3afxZ4dIEXSyZgJRs6kgai-Uq_N6oYsuxEchhj5ANVamABFWDRTVfEqNNl1Tx9rpp-Xnno8Q2dbYpMlAiAcnLYfjIfX9iWe8DSp-G9f7XapAE4f9Hf5freAttn5dThUxB-tQLgxK4kpH0HE_WxWjQB4wqW6XIv7Nh8PYXdJ8rYagOBLuw8ze2gyhzkxIkUNtNEHw6XpwS30RQjC-OJZsmle5DQklmWDtVXdA5cI60B3_WyK5zIQP39FAgntA7_DSv57AJRypjHHW2URyZTqH3b-7lCYsZgHbZzT75Y9G5k_XUTitiQH5xCg5tgdVylj_1jLc8Vt-ryjKzC95fDwzEJgCU2p12dR-JVNMAOq6iAYGDWQFJeGJkuZztPa38QqfM3eXxxLgZ8Fookb6mbF2IArWggnouAQombQnvSvVrNcD-28NS6cDms4KkRs2PrJCx9wDilgC70iGbhbdD3oFonjkClLL51KvbA8KMbKsJAVzE415gbTJ8L0U2QC6q2FbZ8XauTCczx5RRAg-34OoGigRf8HyM-QWNTU_IqAZv1LMqCxk=",
                          options: [.fileCoordinationEnabled: false])
        
        SDK.shared.imageLoadingHandler = { imageName in
            if imageName == "edit_annotations" {
                return R.image.iconPdfAnnotations()
            }
            
            if imageName == "outline" {
                return R.image.iconPdfBookmarks()
            }
            
            if imageName == "settings" {
                return R.image.iconNavbarSettings()
            }
            
            return nil
        }
    }
    
    static func configureMisc() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        AudioPlayback.configure()
    }
    
    static func migrateUserAccountFromFirebase() {
        if (PreferencesShared.loggedIn() || Preferences.firebaseUserMigrated()) { return }
        
        let query: [String: AnyObject] = [
            kSecAttrService as String: Constants.API.LEGACY_API_KEY as AnyObject,
            kSecAttrAccessGroup as String: Constants.DefaultKey.appGroupName as AnyObject,
            kSecAttrAccount as String: "firebase_auth_firebase_user" as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
        ]

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)

        guard status != errSecItemNotFound else { return }
        guard status == errSecSuccess else { return }
        guard let firebaseUserObject = itemCopy as? Data else { return }
        
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: firebaseUserObject)
            
            unarchiver.decodingFailurePolicy = .setErrorAndReturn
            unarchiver.setClass(FIRUser.self, forClassName: "FIRUser")
            unarchiver.setClass(FIRUserTokenService.self, forClassName: "FIRSecureTokenService")
            
            if let user: FIRUser = try? unarchiver.decodeTopLevelObject(of: FIRUser.self, forKey: "firebase_auth_stored_user_coder_key") {
                if !user.apiKey.isEmpty,
                   !user.uid.isEmpty,
                   let accessToken = user.tokenService?.accessToken,
                   let refreshToken = user.tokenService?.refreshToken
                {
                    let accountToken: AccountToken = AccountToken(apiKey: user.apiKey, refreshToken: refreshToken, accessToken: accessToken, expirationTime: 0)
                    let account: Account = Account(uid: user.uid, displayName: user.displayName, email: user.email, stsTokenManager: accountToken, isAnonymous: false)
                    let dictionary = try! JSONEncoder().encode(account)
                    
                    Preferences.userDefaults.set(dictionary, forKey: Constants.DefaultKey.accountObject)
                    Preferences.userDefaults.set(true, forKey: Constants.DefaultKey.accountFirebaseMigrated)
                }
            }
        } catch {}
    }
    
    // TODO: Deprecate
    static func configureAuthentication() {
        self.migrateUserAccountFromFirebase()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        window?.layer.cornerRadius = 6
        window?.clipsToBounds = true
        window?.tintColor = AppStyle.Base.Color.navigationTint
        
        if #available(iOS 13, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(self.appleIDStateDidRevoked(_:)), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
        }
        
        // Check if Sign-in With Apple is still valid
        if #available(iOS 13, *) {
            if let userID = Preferences.userDefaults.string(forKey: Constants.DefaultKey.appleAuthorizedUserIdKey) {
                ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID, completion: { []
                    credentialState, error in
                    
                    switch(credentialState) {
                    case .authorized:
                        break
                    case .notFound,
                         .transferred,
                         .revoked:
                        SettingsController.logOut(presentLoginScreen: false)
                        break
                    @unknown default:
                        break
                    }
                })
            }
        }
        
        self.makeKeyAndVisible()
    }
    
    static func makeKeyAndVisible(_ animated: Bool = false) {
        
        var rootViewController: UIViewController
        
        if (PreferencesShared.loggedIn()) {
            rootViewController = getRootViewController()
        } else {
//            window?.rootViewController = LoginWireFrame.createLoginModule()
            rootViewController = getRootViewController() //UIHostingController(rootView: LoginViewV2())
        }
        
        if animated {
            UIView.transition(with: window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                window?.rootViewController = rootViewController
                window?.makeKeyAndVisible()
            }, completion: nil)
        } else {
            window?.rootViewController = rootViewController
            window?.makeKeyAndVisible()
        }
    }
    
    
    
    
    public static func getRootViewController(quarterlyIndex: String? = nil,
                                              lessonIndex: String? = nil,
                                              readIndex: Int? = nil,
                                              initiateOpen: Bool = false) -> UIViewController {
        self.configureCache()
        
        @State var sspath: [NavigationStep] = []
        
        var ret: UIViewController = UIHostingController(rootView: FeedView(resourceType: .ss, path: $sspath)
            .environmentObject(screenSizeMonitor)
            .environmentObject(themeManager)
        )
        
        let currentLanguage = PreferencesShared.currentLanguage()
//        let resourceInfoViewModel = ResourceInfoViewModel()

//        if let resourceInfo = resourceInfoViewModel.getResourceInfo() {
//            let resourceInfoForLanguage = resourceInfo.filter { $0.code == currentLanguage.code }
//            if !resourceInfoForLanguage.isEmpty {
//                let tabBarController = TabBarViewController()
//                let viewControllers = tabBarController.tabBarControllersFor(
//                    aij: resourceInfoForLanguage.first?.aij ?? false,
//                    pm: resourceInfoForLanguage.first?.pm ?? false,
//                    devo: resourceInfoForLanguage.first?.devo ?? false,
//                    ss: resourceInfoForLanguage.first?.ss ?? false,
//                    quarterlyIndex: quarterlyIndex,
//                    lessonIndex: lessonIndex,
//                    readIndex: readIndex,
//                    initiateOpen: initiateOpen)
//                tabBarController.viewControllers = viewControllers
//
//                if viewControllers.count > 0 {
//                    ret = tabBarController
//                }
//            }
//        }
//
//        resourceInfoViewModel.retrieveResourceInfo()
        
        return ret
    }
    
    static func configureArmchair() {
        Armchair.appID("895272167")
        Armchair.shouldPromptClosure { info -> Bool in
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                DispatchQueue.main.async {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
            return false
        }
    }
    
    static func configureCache() {
        ConfigurationShared.configureCache()
        
        let dataCache = try! DataCache(name: Constants.DefaultKey.appGroupName)
        dataCache.sizeLimit = 200 * 1024 * 1024
        
        ImagePipeline.shared = ImagePipeline {
            $0.dataLoader = DataLoader()
            $0.dataCache = dataCache
            $0.imageCache = ImageCache.shared
        }
    }
    
    static func configureFontblaster() {
        FontBlaster.blast()
    }
    
    static func configurePreferences() {
        Preferences.migrateUserDefaultsToAppGroups()
        
        Preferences.userDefaults.register(defaults: [
            Constants.DefaultKey.tintColor: UIColor.baseBlue.hex(),
            Constants.DefaultKey.settingsReminderStatus: true,
            Constants.DefaultKey.settingsDefaultReminderTime: Constants.DefaultKey.settingsReminderTime
        ])

        if Helper.firstRun() {
            Preferences.userDefaults.set(true, forKey: Constants.DefaultKey.firstRun)
            Preferences.userDefaults.set(true, forKey: Constants.DefaultKey.migrationToAppGroups)
            NotificationsManager.setupLocalNotifications()
        }
    }
    
    static func configureNotifications() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
    }
    
    static func reloadAllWidgets() {
        if #available(iOS 14.0, *) {
            #if arch(arm64) || arch(i386) || arch(x86_64)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }
    }
    
    @objc func appleIDStateDidRevoked(_ notification: Notification) {
        if PreferencesShared.loggedIn() {
            SettingsController.logOut()
        }
    }
}
