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

class AccountManager: ObservableObject {
    @Published var account: Account? {
        didSet {
            Preferences.userDefaults.account = account
        }
    }

    init() {
        self.account = Preferences.userDefaults.account
    }
    
    func logOut() {
        UIApplication.shared.shortcutItems = []
        Spotlight.clearSpotlight()
        
        Preferences.userDefaults.removeObject(forKey: Constants.DefaultKey.accountObject)
        Preferences.userDefaults.set(nil, forKey: Constants.DefaultKey.appleAuthorizedUserIdKey)
        
        DispatchQueue.main.async {
            self.account = nil
        }
    }
    
    func removeAccount () {
        API.auth.request("\(Constants.API.URL)/auth/delete", method: .post)
            .customValidate().response { [weak self] response in
            if let _ = response.error {
                return
            }
            
            self?.logOut()
        }
    }
}
