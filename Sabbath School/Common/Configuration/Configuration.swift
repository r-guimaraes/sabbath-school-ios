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
import AsyncDisplayKit
import AuthenticationServices
import FBSDKCoreKit
import Firebase
import FirebaseDatabase
import UserNotifications
import FontBlaster
import GoogleSignIn
import UIKit
import StoreKit

class Configuration: NSObject {
    static var window: UIWindow?
    static let notification = Notifications()
    
    static func configureAuthentication() {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        window?.layer.cornerRadius = 6
        window?.clipsToBounds = true
        
        if #available(iOS 13, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(self.appleIDStateDidRevoked(_:)), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
        }
        
        // Check if Sign-in With Apple is still valid
        if #available(iOS 13, *) {
            if let userID = UserDefaults.standard.string(forKey: Constants.DefaultKey.appleAuthorizedUserIdKey) {
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

        if (Auth.auth().currentUser) != nil {
            window?.rootViewController = QuarterlyWireFrame.createQuarterlyModule(initiateOpen: true)
        } else {
            window?.rootViewController = LoginWireFrame.createLoginModule()
        }

        window?.makeKeyAndVisible()
    }
    
    static func configureArmchair() {
        Armchair.appID("895272167")
        Armchair.shouldPromptClosure { info -> Bool in
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                return false
            } else {
                return true
            }
        }
    }
    
    static func configureFirebase() {
        #if DEBUG
            let filePath = Bundle.main.path(forResource: "GoogleService-Info-Stage", ofType: "plist")
        #else
            let filePath = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")
        #endif

        let fileopts = FirebaseOptions.init(contentsOfFile: filePath!)

        FirebaseApp.configure(options: fileopts!)
        Database.database().isPersistenceEnabled = true
        Messaging.messaging().delegate = Configuration.notification
    }
    
    static func configureFontblaster() {
        FontBlaster.blast()
    }
    
    static func configurePreferences() {
        UserDefaults.standard.register(defaults: [
            Constants.DefaultKey.tintColor: UIColor.baseBlue.hex(),
            Constants.DefaultKey.settingsReminderStatus: true,
            Constants.DefaultKey.settingsDefaultReminderTime: Constants.DefaultKey.settingsReminderTime
        ])

        if Helper.firstRun() {
            UserDefaults.standard.set(false, forKey: Constants.DefaultKey.firstRun)
            SettingsController.setUpLocalNotification()
        }
    }
    
    static func configureNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = Configuration.notification
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    @objc func appleIDStateDidRevoked(_ notification: Notification) {
        if let providerId = Auth.auth().currentUser?.providerData.first?.providerID, providerId == "apple.com" {
            SettingsController.logOut()
        }
    }
}
