//
//  AppDelegate.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/7.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import UserNotifications
import FirebaseMessaging
import SwiftMessages

var deviceTokenString = ""
var myUDID = ""

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Firebase configuration
        FirebaseApp.configure()
        
        //IQKeyboardManager enable
        IQKeyboardManager.shared.enable = true
        //splash page delay for 3 seconds
        Thread.sleep(forTimeInterval: 3.0)
        //Push Notification setting
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert,UIUserNotificationType.badge, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        registerForPushNotifications()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //MARK: -   set push notifations
    func registerForPushNotifications() {

        if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]//[.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {(granted, error) in
            if granted {
                print("Permission granted: \(granted)")
                    DispatchQueue.main.async() {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            })

            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    
    func getRegisteredPushNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
        switch settings.authorizationStatus {
            case .authorized, .provisional:
                print("The user agrees to receive notifications.")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            case .denied:
                print("Permission denied.")
                // The user has not given permission. Maybe you can display a message remembering why permission is required.
            case .notDetermined:
                print("The permission has not been determined, you can ask the user.")
                self.getRegisteredPushNotifications()
            default:
                return
            }
        })
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != [] {
            application.registerForRemoteNotifications()
        }
    }
   
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        print("Successfully registered for notifications!")
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""

        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        print(":::::::::didRegisterForRemoteNotificationsWithDeviceToken::::::::: APNs_tokenString: \(tokenString)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
}
//MARK: - Delegate for notification
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        let aps             = userInfo["aps"] as? [AnyHashable : Any]
        let notiType        = userInfo["noti_type"] as? String ?? ""
        let badgeCount      = aps!["badge"] as? Int ?? 0
        let alertMessage    = aps!["alert"] as? [AnyHashable : Any]
        let bodyMessage     = alertMessage!["body"] as! String
        let titleMessage    = alertMessage!["title"] as! String
        
        if badgeCount > 0 {
            UIApplication.shared.applicationIconBadgeNumber = badgeCount
        } else {
            UIApplication.shared.applicationIconBadgeNumber += 1
        }
                
        let dataDict:[String: Any] = ["noti_type": notiType]
        
        if notiType == NotificationType.new_order.rawValue {
            
            NotificationCenter.default.post(name: .newOrder, object: nil, userInfo: dataDict)
            
        } else if notiType == NotificationType.new_product.rawValue {
            
            NotificationCenter.default.post(name: .newProduct, object: nil, userInfo: dataDict)
            
        }

        let view: MessageView
        view = try! SwiftMessages.viewFromNib()
        let icon = UIImage(named: "app_logo")!.resize(to: CGSize(width: 35, height: 35))!.withRoundedCorners(radius: 5)
        
        view.configureContent(title: titleMessage, body: bodyMessage, iconImage: icon, iconText: nil, buttonImage: nil, buttonTitle: "OK", buttonTapHandler: { _ in
            SwiftMessages.hide()
            if UIApplication.shared.applicationIconBadgeNumber > 0 {
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }            
            
        })
        
        /////////////////////    theme 1
//        view.configureTheme(.info, iconStyle: .light)
//        view.accessibilityPrefix = "info"
        
        /////////////////////    theme 2
        view.configureTheme(backgroundColor: UIColor(named: "BgColor")!, foregroundColor: UIColor.white, iconImage: icon, iconText: nil)
//        view.button?.setImage(Icon.errorSubtle.image, for: .normal)
        view.button?.setTitle("OK", for: .normal)
        view.button?.backgroundColor = UIColor.white ///UIColor.clear
        view.button?.tintColor = UIColor(named: "BgColor")
        
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .top
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .forever //.seconds(seconds: 5)
        config.dimMode = .blur(style: .dark, alpha: 0.5, interactive: true)
        config.shouldAutorotate = true
        config.interactiveHide = true
        config.preferredStatusBarStyle = .lightContent
        
        SwiftMessages.show(config: config, view: view)
        
        sleep(1)
        completionHandler([])
    }
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        Messaging.messaging().subscribe(toTopic: "/topics/all")
        if let token = fcmToken {
            
            deviceTokenString = token
            print("fcmToken: ", token)
        } else {
            print("fcmToken: empty")
        }
    }
}

