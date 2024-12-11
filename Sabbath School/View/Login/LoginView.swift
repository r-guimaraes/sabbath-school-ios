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
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var accountManager: AccountManager
    @StateObject private var loginViewModel: LoginViewModel

    init(accountManager: AccountManager) {
        _loginViewModel = StateObject(wrappedValue: LoginViewModel(accountManager: accountManager))
    }
    
    let signInButtonSize = AppStyle.Login.buttonSize
    
    var body: some View {
        VStack(alignment: .center, spacing: AppStyle.Login.verticalSpacing) {
            Image("login-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: AppStyle.Login.appLogoHeight)
                .padding(.top, AppStyle.Login.appLogoSpacing)
            
            Text(AppStyle.Login.appName("Sabbath School".localized()))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            if !loginViewModel.loading {
                SignInWithAppleButton (.signIn) { request in
                    loginViewModel.loginActionApple()
                } onCompletion: { result in }
                .signInWithAppleButtonStyle(Helper.isDarkMode() ? .white : .black)
                .frame(width: signInButtonSize.width, height: signInButtonSize.height)
                    
                
                Button(action: {
                    loginViewModel.loginActionGoogle()
                }) {
                    HStack {
                        Image("login-icon-google")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                        Text(AppStyle.Login.signInButton("Sign in with Google".localized()))
                    }
                    .frame(width: signInButtonSize.width, height: signInButtonSize.height)
                    .background(.white)
                    .cornerRadius(6)
                }

                Button(action: {
                    loginViewModel.loginActionAnonymous()
                }) {
                    Text(AppStyle.Login.signInButtonAnonymous("Continue without login".localized()))
                        .frame(width: signInButtonSize.width, height: signInButtonSize.height)
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding(.bottom, 80)
            }
            
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        .background(AppStyle.Login.backgroundColor)
    }
}
