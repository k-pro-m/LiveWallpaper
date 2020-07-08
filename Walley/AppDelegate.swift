//
//  AppDelegate.swift
//  Walley
//
//  Created by Bashar Madi on 8/21/17.
//  Copyright © 2017 Bashar Madi. All rights reserved.
//

import UIKit
import Firebase
import OneSignal
import FacebookCore
import CoreData
import IQKeyboardManagerSwift




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSPermissionObserver  {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        IQKeyboardManager.shared.enable = true

        loadcolor()
        getColorOfAPP()
        getcategoryList()
        FirebaseApp.configure()
        
//        GADMobileAds.configure(withApplicationID: "ca-app-pub-2030552349686241~3771606701")
        GADMobileAds.sharedInstance().start(completionHandler: nil)

       let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "dc39a373-ebfc-4521-931c-bcd1a78d20bb",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
            
        })
      print(OneSignal.app_id())
        let api = Api()
        let proFlag = api.checkProFlag()
        let subIsActive:Bool?
        if  let sub = UserDefaults.standard.value(forKey: "subIsActive") {
            subIsActive = sub as? Bool
        }
        else {
            UserDefaults.standard.set(false, forKey: "subIsActive")
            subIsActive = false
        }
     
        let manager = ShopManager.sharedInstance
        manager.completeTransactions()
        if (proFlag && subIsActive!) {
        manager.verifySubscription()
        }
        
        // Add your AppDelegate as an obsserver
        OneSignal.add(self as! OSPermissionObserver)
    
    
        
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
//
//        let hasPrompted = status.permissionStatus.hasPrompted
//        print("hasPrompted = \(hasPrompted)")
//        let userStatus = status.permissionStatus.status
//        print("userStatus = \(userStatus)")
//
//        let isSubscribed = status.subscriptionStatus.subscribed
//        print("isSubscribed = \(isSubscribed)")
//        let userSubscriptionSetting = status.subscriptionStatus.userSubscriptionSetting
//        print("userSubscriptionSetting = \(userSubscriptionSetting)")
//        let userID = status.subscriptionStatus.userId
//        print("userID = \(String(describing: userID))")
        
//        let pushToken = status.subscriptionStatus.pushToken
//        print("pushToken = \(String(describing: pushToken))")
        
        

        
        return true
    }


// Add this new method
func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
    // Example of detecting answering the permission prompt
    if stateChanges.from.status == OSNotificationPermission.notDetermined {
        if stateChanges.to.status == OSNotificationPermission.authorized {
            print("Thanks for accepting notifications!")
        } else if stateChanges.to.status == OSNotificationPermission.denied {
            print("Notifications not accepted. You can turn them on later under your iOS settings.")
        }
    }
    // prints out all properties
    print("PermissionStateChanges: \n\(stateChanges)")
    
}


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
      
       AppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        CoredataClass.sharedInstance.saveContext()
    }
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        if ApplicationDelegate.shared.application(app, open: url, options: options) {
            return true
        }
        return false
    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        let handled = SDKApplicationDelegate.shared.application(app, open: url, options: options)
//        return handled
//    }


func getcategoryList() {
            var parameters: APIDict = [:]
            parameters["user_id"] = "1"
    LambdaManager.shared.CallApi(configs.GetcategoryList, parameters) { (data, header, statusCode, error) in
            guard let json = data else { return }
            if json.safeBool("success") {
                let dataDict:Array<Any> = json["data_category"] as! Array<Any>
                UserDefaults.standard.set(dataDict, forKey: DefaultKeys.categoriesKey)
            }
                
        }
}
    func loadcolor() {
        let firstRun = UserDefaults.standard.bool(forKey: "firstRun") as Bool
        if !firstRun {
            //run your function
        UserDefaults.standard.set(true, forKey: "firstRun")
         
            do {
                let backcolorToSetAsDefault = UIColor(red: 20.0/255.0, green: 12.0/255.0, blue: 30.0/255.0, alpha: 1.0)
                let backdata = try NSKeyedArchiver.archivedData(withRootObject: backcolorToSetAsDefault, requiringSecureCoding: false)
                 UserDefaults.standard.set(backdata, forKey: DefaultKeys.backcolorKey)
               
                
                let titlecolorToSetAsDefault = UIColor(red: 136.0/255.0, green: 124.0/255.0, blue: 123.0/255.0, alpha: 1.0)
                let titledata = try NSKeyedArchiver.archivedData(withRootObject: titlecolorToSetAsDefault, requiringSecureCoding: false)
                UserDefaults.standard.set(titledata, forKey: DefaultKeys.titlecolorKey)
            } catch { print(error) }
        
        UserDefaults.standard.set(["0"], forKey: DefaultKeys.unlockedArraylistKey)
        UserDefaults.standard.synchronize()
        
        }
        
        
    }
    func getColorOfAPP() {
        var parameters: APIDict = [:]
        parameters["user_id"] = "1"
        LambdaManager.shared.CallApi(configs.get_colors, parameters) { (data, header, statusCode, error) in
                guard let json = data else { return }
                if json.safeBool("success") {
                   
                    let br = "\(json["color_background_r"] ?? 20.0)".CGFloatValue()
                    let bg = "\(json["color_background_g"] ?? 12.0)".CGFloatValue()
                    let bb = "\(json["color_background_b"] ?? 30.0)".CGFloatValue()
                    let ba = "\(json["color_background_a"] ?? 1.0)".CGFloatValue()
                    
                
                    let tr = "\(json["color_text_r"] ?? 136.0)".CGFloatValue()
                    let tg =  "\(json["color_text_g"] ?? 124.0)".CGFloatValue()
                    let tb =  "\(json["color_text_b"] ?? 123.0)".CGFloatValue()
                    let ta =  "\(json["color_text_a"] ?? 1.0)".CGFloatValue()
                    
                    
                    
                    do {
                        let backcolorToSetAsDefault = UIColor(red: (br ?? 20.0)/255.0, green: (bg ?? 12.0)/255.0, blue: (bb ?? 30.0)/255.0, alpha: (ba ?? 1.0))
                        let backdata = try NSKeyedArchiver.archivedData(withRootObject: backcolorToSetAsDefault, requiringSecureCoding: false)
                        UserDefaults.standard.set(backdata, forKey: DefaultKeys.backcolorKey)
                        
                            
                        let titlecolorToSetAsDefault = UIColor(red: (tr ?? 136.0)/255.0, green: (tg ?? 124.0)/255.0, blue: (tb ?? 123.0)/255.0, alpha: (ta ?? 1.0))
                        let titledata = try NSKeyedArchiver.archivedData(withRootObject: titlecolorToSetAsDefault, requiringSecureCoding: false)
                        UserDefaults.standard.set(titledata, forKey: DefaultKeys.titlecolorKey)
                        
                        UserDefaults.standard.synchronize()
                        
                    } catch { print(error) }
                    
                    
                    
                }
                    
            }
    }



}


