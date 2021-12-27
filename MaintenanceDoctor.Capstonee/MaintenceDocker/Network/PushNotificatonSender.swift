//
//  PushNotificatonSender.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/15.
//

import Foundation
import UIKit

class PushNotificationSender {
    
    // send PushNotification to single device
    func sendSinglePushNotification(to token: String, _ title: String, _ body: String, _ notiType: String, _ badgeCount: Int = 0) {
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        
        var notificationContent = [
            "title"     : title,
            "body"      : body,
            "priority"  : "high",
            "sound"     : "default",
            "content_available" : true
        ] as [String : Any]
        if badgeCount > 0 {
            notificationContent["badge"] = badgeCount
        }
        
        let data = [
            "title" : title,
            "body"  : body,
            "sound" : "default",
            "badge" : badgeCount,
            "noti_type"  : notiType
        ] as [String : Any]
        
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : notificationContent,
                                           "data" : data,
                                        ]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=" + Constant.FCM_KEY, forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                        print("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    // send PushNotification to Multi device
    func sendAllPushNotification(to tokens: [String], title: String, body: String, notiType: String, id: String, image_url: String, orderIds: [String]) {
        //v1/projects/maintenancedoctor-bee2a/message:
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        
        let notificationContent: [String : Any] = [
            "title"     : title,
            "body"      : body,
            "priority"  : "high",
            "sound"     : "default",
            "content_available" : true,
        ]
        
        let data = [
            "title"     : title,
            "body"      : body,
            "sound"     : "default",
            "badge"     : 0,
            "noti_type" : notiType
        ] as [String : Any]
        
        let paramString = ["registration_ids" : tokens,
                           "notification" : notificationContent,
                           "data" : data
                        ] as [String : Any]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + Constant.FCM_KEY, forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        if notiType == NotificationType.new_product.rawValue {
                            FirebaseAPI.productPostNotificaiton(body, id, image_url) { (isSuccess) in
                                if isSuccess {
                                    print("success")
                                } else {
                                    print("failed")
                                }
                            }
                        } else {
                            FirebaseAPI.orderPostNotificaiton(body, id, image_url, orderIds) { (isSuccess) in
                                if isSuccess {
                                    print("success")
                                } else {
                                    print("failed")
                                }
                            }
                        }
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                } else {
                    print("noti_no_json")
                }
            } catch let err as NSError {
                print("noti_error", err.debugDescription)
            }
        }
        
        task.resume()
    }
}

