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

struct AboutViewV2: View {
    var body: some View {
        ScrollView {
            VStack (spacing: 80) {
                VStack(spacing: 20) {
                    Image("sspm-logo")
                        .resizable()
                        .frame(width: 200, height: 44)
                    Text(
                        AppStyle.Resources.About.text("The mission of the General Conference SSPM Department is to make disciples, who in turn make other disciples. We aim to do this by helping local Seventh-day Adventist churches and their members to discover the purpose and power of Sabbath School and by inspiring and enlisting every member to become actively involved in personal soul-winning service.\n\nThe SSPM Department produces resources to help Seventh-day Adventist church members in their walk with Christ and their witness to the world. The aim of the Sabbath School and Personal Ministries app is to combine many of these resources into one convenient location. As more resources continue to be added, church members and their families will soon be equipped with a wealth of resources to aid them in studying and sharing God’s Word.\n\nTo facilitate the maintenance and development of the app, the SSPM Department is glad to partner with the dedicated and talented team at Adventech.".localized())
                    ).frame(maxWidth: .infinity, alignment: .leading)
                }
                
                VStack(spacing: 20) {
                    Image("logo-adventech")
                    
                    Text(
                        AppStyle.Resources.About.text("God's Ministry through Technology".localized())
                    ).frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack (spacing: 20) {
                        Link(destination: URL(string: "https://instagram.com/adventech")!) {
                            Image("icon-instagram")
                        }
                        
                        Link(destination: URL(string: "https://www.facebook.com/shabbatschool")!) {
                            Image("icon-facebook")
                        }
                        
                        Link(destination: URL(string: "https://github.com/Adventech")!) {
                            Image("icon-github")
                        }
                    }
                    
                    Link(destination: URL(string: "https://adventech.io")!) {
                        Text(AppStyle.Resources.About.url("adventech.io"))
                    }
                    
                    Text(AppStyle.Resources.About.text("Adventech is a non-profit organization in Canada that is dedicated to the use of technology for ministry. As dedicated Seventh-day Adventists, the mission of Adventech is first and foremost to give glory to God. We also aim through our ministry to bring unity to the worldwide Seventh-day Adventist Church. Our primary goal is to proclaim the everlasting gospel by means of technology and advancements in communications, and to do our part in preparing the world for the second coming of Jesus.".localized())
                    ).frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(AppStyle.Resources.About.signature("Your friends at Adventech".localized()))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }.padding(20)
        }
    }
}

struct AboutViewV2_Previews: PreviewProvider {
    static var previews: some View {
        AboutViewV2()
    }
}

