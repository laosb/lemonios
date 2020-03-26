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
    
    func login(token: String) {
        let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
        sharedUd?.set(token, forKey: "token")
        sharedUd?.synchronize()
        print(token)
        self.triggerWebViewFunc?()
        self.dismissFunc?()
        self.tip = ""
        self.triggerNewFuncGuideFunc?()
    }
    func setTip(_ tip: String) {
        self.Login = "登录"
        self.tip = tip
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.tip = ""
        })
        self.isDisabled = false
    }
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
                .padding()
            VStack {
                SignInWithAppleView(
                    onFinish: { success, tokenOrReason in
                        if success {
                            self.login(token: tokenOrReason)
                        } else {
                            self.setTip(tokenOrReason)
                        }
                    },
                    dismissLogin: dismissFunc ?? {}
                )
                    .frame(width: 250, height: 55)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white, lineWidth: 1)
                    )
                Text("或者通过智慧杭电登录")
                    .font(.headline)
                    .padding(.vertical)
                VStack {
                    
                    TextField("学工号", text: $username, onEditingChanged: { target in
                        if target { self.kGuardian.showField = 0 }
                    })
                        .padding(.horizontal)
                        .frame(width: 250, height: 55, alignment: .center)
                        .background(Color.init(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.3)))
                        .cornerRadius(30)
                    SecureField("密码", text: $password, onCommit: {
                        self.kGuardian.showField = 0
                    })
                        .padding(.horizontal)
                        .frame(width: 250, height: 55, alignment: .center)
                        .background(Color.init(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.3)))
                        .cornerRadius(30)
                }
                Button(action: {
                    if self.username == "*#*#19260817#*#*" {
                        let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
                        sharedUd?.set(!(sharedUd?.bool(forKey: "dev") ?? false), forKey: "dev")
                        sharedUd?.synchronize()
                        self.username = "TOGGLED DEV RESTART APP NOW"
                        return
                    }
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
                    AF.request("https://api.hduhelp.com/login/cas?clientID=app",method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { response in
                        switch response.result {
                            case .success:
                                let json = response.result.value
                                let msg = (json as! NSDictionary).object(forKey: "msg") as! String
                                if msg == "success" {
                                    let newRawData = (json as! NSDictionary).object(forKey: "data") as! NSDictionary
                                    let token = newRawData.object(forKey: "access_token") as! String
                                    self.login(token: token)
                                }
                                else {
                                    self.setTip("登录失败，请检查账号或密码")
                                }
//                                print("\(msg) \n")
//                                print(parameters)
                            case .failure:
                                self.setTip("登录失败，请检查网络")
                        }
                    })
                }){
                    VStack {
                        Text("\(Login)")
                            .foregroundColor(Color.white)
                            .frame(width: 250, height: 55, alignment: .center)
                            .font(.headline)
                            //.padding(.leading, 10)
                    }
                }
                    .disabled(isDisabled)
                    .background(Color.init(UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)))
                    .background(GeometryGetter(rect: $kGuardian.rects[0]))
                    .cornerRadius(30)
            }
            Text(tip)
                .font(.footnote)
                .padding(.vertical)
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
