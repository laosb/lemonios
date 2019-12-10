//
//  LoginView.swift
//  杭电助手
//
//  Created by ljz on 2019/11/25.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI
import Alamofire
import UIKit

struct LoginView: View {
    @ObservedObject private var kGuardian = KeyboardGuardian(textFieldCount: 1)

    @State var username: String = ""
    @State var password: String = ""
    @State var Login: String = "登录"
    @State var tip: String = ""
    @State var isDisabled: Bool = false
    var triggerWebViewFunc: (() -> Void)?
    var triggerNewFuncGuideFunc: (() -> Void)?
    var dismissFunc: (() -> Void)?
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //限制只能输入数字，不能输入特殊字符
        let length = string.lengthOfBytes(using: String.Encoding.utf8)
        for loopIndex in 0..<length {
            let char = (string as NSString).character(at: loopIndex)
            if char < 48 { return false }
            if char > 57 { return false }
        }
        //限制长度
        let proposeLength = (textField.text?.lengthOfBytes(using: String.Encoding.utf8))! - range.length + string.lengthOfBytes(using: String.Encoding.utf8)
        if proposeLength > 11 { return false }
        return true
    }
    var body: some View {
        VStack{
            
            Image("Icon")
                .resizable()
                .frame(width: 200, height: 200, alignment: .center)
                .clipShape(Circle())
                .offset(y: -100)
            VStack {
                Text("智慧杭电登录")
                    .font(.headline)
                    .padding(.bottom)
                VStack {
                    
                    TextField("学工号", text: $username, onEditingChanged: { target in
                        if target { self.kGuardian.showField = 0 }
                    })
                        .cornerRadius(3)
                        .lineSpacing(15)
                        .padding()
                        .frame(width: 250, alignment: .center)
                        .background(Color.init(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.3)))
                        .cornerRadius(30)
                    SecureField("密码", text: $password, onCommit: {
                        self.kGuardian.showField = 0
                    })
                        .cornerRadius(3)
                        .lineSpacing(15)
                        .padding()
                        .frame(width: 250, alignment: .center)
                        .background(Color.init(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.3)))
                        .cornerRadius(30)
                }
                Text(tip)
                    .font(.footnote)
               //     .padding(.top, 5)
                    .padding(.bottom, 2.5)
                Button(action: {
                    self.isDisabled = true
                    self.Login = "登录中..."
                    self.password = self.password.trimmingCharacters(in: [" ","\t"])
                    let data = self.password.data(using: String.Encoding.utf8)
                    let base64Pass = data!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
                    let parameters: Parameters = ["user": self.username, "pass": base64Pass, "appName": "app", ]
                    //let temp: String = base64Pass as! String
                    //print(temp)
                    //print("!!!!!!!!!!!")
                    //https://api.hduhelp.com/login/cas?clientID=app
                    Alamofire.request("https://api.hduhelp.com/login/cas?clientID=app",method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { response in
                        switch response.result {
                            case .success:
                                let json = response.result.value
                                let msg = (json as! NSDictionary).object(forKey: "msg") as! String
                                if msg == "success" {
                                    let newRawData = (json as! NSDictionary).object(forKey: "data") as! NSDictionary
                                    //let isValid = newRawData.object(forKey: "isValid") as! Bool
                                    let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
                                    let token = newRawData.object(forKey: "access_token") as! String
                                    sharedUd?.set(token, forKey: "token")
                                    sharedUd?.synchronize()
                                    print(token)
                                    self.triggerWebViewFunc?()
                                    self.dismissFunc?()
                                    self.tip = ""
                                    self.triggerNewFuncGuideFunc?()
                                }
                                else {
                                    self.Login = "登录"
                                    self.tip = "登录失败，请检查账号或密码"
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                                    //                // Put your code which should be executed with a delay here
                                            self.tip = ""
                                        })
                                    self.isDisabled = false
                                }
//                                print("\(msg) \n")
//                                print(parameters)
                            case .failure:
                                self.tip = "登录失败，请检查网络"
                                self.isDisabled = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                                //                // Put your code which should be executed with a delay here
                                        self.tip = ""
                                    })
                        }
                    })
                }){
                    VStack {
                        Text("\(Login)")
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 105)
                            .padding(.top, 15)
                            .padding(.bottom, 15)
                            .font(.headline)
                            //.padding(.leading, 10)
                    }
                    }.disabled(isDisabled)
                    .background(Color.init(UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)))
                    .background(GeometryGetter(rect: $kGuardian.rects[0]))
                    .cornerRadius(30)
            }
            
        }
            .padding(.horizontal, 40)
            .offset(y: kGuardian.slide)
            .animation(.easeInOut)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
