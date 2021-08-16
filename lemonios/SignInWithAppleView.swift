//
//  SignInWithAppleView.swift
//  杭电助手
//
//  Created by Shibo Lyu on 2020/3/11.
//  Licensed under MIT License (https://laosb.mit-license.org).
//

import AuthenticationServices
import SwiftUI
import Alamofire

struct SignInWithAppleView: UIViewRepresentable {

  // Success: true, token
  // Failure: false, reason
  var onFinish: (Bool, String) -> Void
  var dismissLogin: () -> Void
  var alertToBind: (Bool, URL) -> Void

  class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    let parent: SignInWithAppleView?

    init(_ parent: SignInWithAppleView) {
      self.parent = parent
      super.init()

    }

    @objc func didTapButton() {
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.presentationContextProvider = self
      authorizationController.delegate = self
      authorizationController.performRequests()
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
      let vc = UIApplication.shared.windows.last?.rootViewController
      return (vc?.view.window!)!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
        print("credentials not found....")
        return
      }

      AF.request(
        "https://api.hduhelp.com/login/callback/apple",
        method: .post,
        parameters: [
          "clientID": "app",
          "school": "hdu",
          "bind": true,
          "redirect": "lemonios",
          "code": String(
            data: credentials.authorizationCode!,
            encoding: .ascii
          )!,
          "appleClientID": Bundle.main.bundleIdentifier!
        ],
        encoding: URLEncoding.queryString,
        headers: [ "User-Agent": "Lemon_iOS" ]
      ).validate().responseData{ res in
        if case .success(let content) = res.result {
          print("data:", content.base64EncodedString())
        }
      }.responseJSON { res in
        switch res.result {
        case .success(let val):
          let value = val as! NSDictionary
          let data = value.object(forKey: "data") as! NSDictionary
          let isAuthed = data.object(forKey: "authorize") as? Bool ?? false
          if isAuthed {
            let token = data.object(forKey: "accessToken") as! String
            self.parent?.onFinish(true, token)
          } else {
            let needBind = data.object(forKey: "needBind") as? Bool ?? false
            if needBind {


              let urlStr = data.object(forKey: "bindURL") as! String
              let url = URL(string: urlStr)
              guard url != nil else { return }
              //                            UIApplication.shared.open(url!)
              self.parent?.alertToBind(true, url!)
              //                            self.parent?.dismissLogin()
            } else {
              self.parent?.onFinish(false, "Apple 登录失败，请重试")
            }
          }
        case .failure:
          print("result:", res.result)
          self.parent?.onFinish(false, "Apple 登录失败。请重试。")
        }
      }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }

  func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
    let button = ASAuthorizationAppleIDButton(
      authorizationButtonType: .signIn,
      authorizationButtonStyle: .black
    )
    button.frame = .zero
    button.cornerRadius = 30
    button.addTarget(
      context.coordinator,
      action: #selector(Coordinator.didTapButton),
      for: .touchUpInside
    )

    return button
  }

  func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
  }
}

//struct SignInWithAppleView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignInWithAppleView(onFinish: {_,_ in }, dismissLogin: {})
//    }
//}

