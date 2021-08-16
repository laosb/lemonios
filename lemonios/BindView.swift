//
//  BindView.swift
//  杭电助手
//
//  Created by ljz on 2020/6/3.
//  Licensed under MIT License (https://laosb.mit-license.org).
//

import SwiftUI
import SafariServices

struct BindView: View {
    // whether or not to show the Safari ViewController
    @State var showSafari = true
    // initial URL string
    var url: URL?
    var dismissFunc: (() -> Void)?

    var body: some View {
//        Button(action: {
//            // update the URL if you'd like to
//            self.urlString = "https://duckduckgo.com"
//            // tell the app that we want to show the Safari VC
//            self.showSafari = true
//        }) {
//            Text("Present Safari")
//        }
//        // summon the Safari sheet
//        .sheet(isPresented: $showSafari) {
//            SafariView(url:URL(string: self.urlString)!)
//        }
        VStack {
            if self.url != nil {
                SafariView(url: self.url!)
            }
        }
        
    }
}

struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }

}
