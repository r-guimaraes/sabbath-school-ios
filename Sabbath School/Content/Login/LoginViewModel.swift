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

import Alamofire
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import SwiftEntryKit

enum LoginType {
    case google
    case apple
    case anonymous
    
    var param: String {
        switch self {
        case .google: return "google"
        case .apple: return "apple"
        case .anonymous: return "anonymous"
        }
    }
}

class LoginViewModel: NSObject, ObservableObject {
    @Published var loading: Bool = false
    var currentNonce: String?
    
    private var accountManager: AccountManager
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
    }
    
    func getFirstWindow() -> UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        return windowScene.windows.first
    }
    
    func loginActionGoogle() {
        guard let rootViewController = self.getFirstWindow()?.rootViewController else {
            self.onError()
            return
        }
        
        let signInConfig =  GIDConfiguration(clientID: Constants.API.GOOGLE_CLIENT_ID)
        
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: rootViewController) { user, error in
            if let _ = error {
                self.onError()
                return
            }

            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                self.onError()
                return
            }
            
            self.performLogin(credentials: [ "id_token": idToken ], loginType: .google)
        }
    }
    
    func loginActionApple() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        self.currentNonce = randomNonceString()
        request.nonce = sha256(currentNonce!)
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.presentationContextProvider = self
        authController.delegate = self
        authController.performRequests()
    }
    
    func loginActionAnonymous() {
        guard let rootViewController = self.getFirstWindow()?.rootViewController else {
            return
        }
        
        let alertController = UIAlertController(
            title: "Login anonymously?".localized(),
            message: "By logging in anonymously you will not be able to synchronize your data, such as comments and highlights, across devices or after uninstalling application. Are you sure you want to proceed?".localized(),
            preferredStyle: .alert
        )

        let no = UIAlertAction(title: "No".localized(), style: .default, handler: nil)
        no.accessibilityLabel = "loginAnonymousOptionNo"

        let yes = UIAlertAction(title: "Yes".localized(), style: .destructive) { [weak self] (_) in
            self?.performLogin(credentials: ["a": "b"], loginType: .anonymous)
        }
        yes.accessibilityLabel = "loginAnonymousOptionYes"

        alertController.addAction(no)
        alertController.addAction(yes)
        alertController.accessibilityLabel = "loginAnonymous"

        rootViewController.present(alertController, animated: true, completion: nil)
    }
    
    func performLogin(credentials: [String: String], loginType: LoginType) {
        self.loading = true
        AF.request(
            "\(Constants.API.URL)/auth/signin/\(loginType.param)",
            method: .post,
            parameters: credentials,
            encoding: JSONEncoding.default
        ).responseDecodable(of: Account.self, decoder: Helper.SSJSONDecoder()) { response in
            switch response.result {
            case .success(let account):
                self.accountManager.account = account
                self.onSuccess()
            case .failure:
                self.onError()
            }
        }
    }
    
    func onSuccess () {
        self.loading = false
    }
    
    func onError () {
        self.loading = false
        
        var attributes = EKAttributes()
        attributes.position = .top
        attributes.displayDuration = 3.0
        attributes.entryBackground = .color(color: .init(UIColor.systemYellow))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.1, radius: 5))
        attributes.screenBackground = .clear
        attributes.entryInteraction = .dismiss
        attributes.roundCorners = .all(radius: 4)
        
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.9)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.intrinsic
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)

        let title = EKProperty.LabelContent(text: "There was an error during login".localized(), style: .init(font: UIFont(name: "Lato-Black", size: 17)!, color: .white))
        let description = EKProperty.LabelContent(text: "", style: .init(font: .systemFont(ofSize: 17), color: .white))
        let image = EKProperty.ImageContent(image: UIImage(systemName: "exclamationmark.circle.fill")!.fillAlpha(fillColor: .white), size: CGSize(width: 28, height: 28))
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)

        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
}

extension LoginViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    self.onError()
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let _ = error as? ASAuthorizationError else {
            self.onError()
            return
        }
        
        self.onError()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            Preferences.userDefaults.set(appleIDCredential.user, forKey: Constants.DefaultKey.appleAuthorizedUserIdKey)
            
            guard let nonce = currentNonce else {
                self.onError()
                return
            }

            guard let appleIDToken = appleIDCredential.identityToken else {
                self.onError()
                return
            }

            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.onError()
                return
            }

            self.performLogin(credentials: [ "id_token": idTokenString, "nonce": nonce ], loginType: .apple)
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return Configuration.window!
    }
}
