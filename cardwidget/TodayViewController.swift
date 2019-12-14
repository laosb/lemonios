//
//  TodayViewController.swift
//  sunrunwidget
//
//  Created by Shibo Lyu on 2019/11/8.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftUI
import Alamofire

class TodayViewController: UIViewController, NCWidgetProviding {
    
    func renderData(cardData: LMWidgetCard) {
        let srVc = UIHostingController(rootView: CardWidget(cardData: cardData){ cb in
            self.extensionContext?.open(URL(string: "alipays://platformapi/startapp?saId=10000007&qrcode=https%3A%2F%2Fqr.alipay.com%2Fs7x07977akyiot2uv5pme45%3F_s%3Dweb-other")!) { success in cb(success) }
        })
        srVc.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        srVc.view.frame = self.view.bounds
        self.view.addSubview(srVc.view)
        self.addChild(srVc)
        srVc.didMove(toParent: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
        let token = sharedUd?.string(forKey: "token")
        var cardData = LMWidgetCard()
        if token != nil {
            Alamofire.request("https://api.hduhelp.com/infoStream/v3", headers:["Authorization": "token \(token ?? "")", "User-Agent": "Alamofire Lemon_iOS"]).validate().responseJSON(completionHandler:
                {
                    response in switch response.result
                    {
                        case .success:
//                            print(response.result)
                            let json = response.result.value
                            let newRawData = (json as! NSDictionary).object(forKey: "data") as! NSDictionary
                            let CardData = newRawData.object(forKey: "card") as? NSDictionary
                            
                            cardData.available = CardData?.object(forKey: "available") as? Bool
                            let indexData = CardData?.object(forKey: "data") as? NSDictionary
                            
                            let remaining = indexData?.object(forKey: "remaining") as? Double ?? 0
                            cardData.remaining = String(format:"%.2lf", abs(remaining) < 0.01 ? 0.0 : remaining)
                            let today = (indexData?.object(forKey: "today") as? Double ?? 0) * -1
                            cardData.today = String(format:"%.2lf", abs(today) < 0.01 ? 0.0 : today)
                            
                            if remaining <= 15.0 {
                                cardData.tip = "⚠️ 余额较少，记得充值"
                            }
                            
                            self.renderData(cardData: cardData)
                        case .failure:
//                            print(response)
                            cardData.available = false
                            self.renderData(cardData: cardData)
                    }
                }
            )
        } else {
            cardData.available = false
            self.renderData(cardData: cardData)
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
