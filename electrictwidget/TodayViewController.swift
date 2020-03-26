//
//  TodayViewController.swift
//  electrictwidget
//
//  Created by ljz on 2019/12/3.
//  Copyright © 2019 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import NotificationCenter
import SwiftUI

class TodayViewController: UIViewController, NCWidgetProviding {
    
    func renderData(elecData: LMWidgetElec) {
        let srVc = UIHostingController(rootView: ElectricWidget(elecData: elecData){ cb in
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
            
//            print("!!!!!!!!!!")
            
            let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
            let token = sharedUd?.string(forKey: "token")
            var elecData = LMWidgetElec()
            if token != nil {
                AF.request("https://api.hduhelp.com/electric/fee", headers:["Authorization": "token \(token ?? "")", "User-Agent": "Alamofire Lemon_iOS"]).validate().responseJSON(completionHandler:
                    {
                        response in switch response.result
                        {
                            case .success:
    //                            print(response.result)
                                let json = response.value
                                let newRawData = (json as! NSDictionary).object(forKey: "data") as! NSDictionary
                                let fee = newRawData.object(forKey: "fee") as? String
                                let pos = newRawData.object(forKey: "roomName") as? String
                                let msg = (json as! NSDictionary).object(forKey: "msg") as! String
                                let per = String(pos!.prefix(5))
                                let suf = String(pos!.suffix(3))
                                elecData.perfix = per
                                elecData.suffix = suf
   //                             print(pos)
                                
                                elecData.available = false
                                if msg == "success" {
                                    elecData.available = true
                                }
                                elecData.remaining = String(fee!.prefix(5))
                                elecData.room = pos
                                elecData.room!.remove(at: (elecData.room?.index(before: elecData.room!.endIndex))!)
                                //elecData.remaining!.remove(at: (elecData.remaining?.index(before: elecData.remaining!.endIndex))!)
    //                            cardData.available = CardData?.object(forKey: "available") as? Bool
    //                            let indexData = CardData?.object(forKey: "data") as? NSDictionary
                                let feeDouble = (elecData.remaining! as NSString).doubleValue
    //                            cardData.remaining = String(format:"%.2lf", abs(remaining) < 0.01 ? 0.0 : remaining)
    //                            let today = (indexData?.object(forKey: "today") as? Double ?? 0) * -1
    //                            cardData.today = String(format:"%.2lf", abs(today) < 0.01 ? 0.0 : today)
    //
                                if feeDouble <= 15.0 {
                                    elecData.tip = "⚠️ 余额较少，记得充值"
                                }
    //
                                self.renderData(elecData: elecData)
                            case .failure:
    //                            print(response)
                                elecData.available = false
                                self.renderData(elecData: elecData)
                        }
                    }
                )
            } else {
                elecData.available = false
                self.renderData(elecData: elecData)
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
