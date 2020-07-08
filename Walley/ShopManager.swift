//
//  ShopManager.swift
//  Walley
//
//  Created by Bashar Madi on 1/4/18.
//  Copyright © 2018 Bashar Madi. All rights reserved.
//

import Foundation
import UIKit
import SwiftyStoreKit

class ShopManager {
    
    static let sharedInstance = ShopManager()
    private var container = UIView()
    private var loadingView = UIView()
    private var activityIndicator = UIActivityIndicatorView()
    private var subscriptionRestore = false
    
    var weeklylocalizedPrice = ""
    var monthlylocalizedPrice = ""
    var yearlylocalizedPrice = ""
    
    private init() {}
    
    
    private func showActivityIndicator() {
        
        let view = UIApplication.topViewController()!.view!
        
        container.frame = view.bounds
        container.center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        container.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = container.center
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = .whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2,
                                           y: loadingView.frame.size.height / 2)
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        view.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
    
    func showAlert(title: String, message: String, closeParentView: Bool = false) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action) in
            if (closeParentView) { UIApplication.topViewController()!.dismiss(animated: true, completion: nil) }
        }
        alertController.addAction(okAction)
        UIApplication.topViewController()!.present(alertController, animated: true, completion: nil)
    }
    
    func purchaseProduct(productId: String) {
        showActivityIndicator()
        SwiftyStoreKit.purchaseProduct(productId, atomically: true) {
            result in
            
            switch result {
            case .success(let product):
                self.completePurchase(productId: product.productId)
                print("Purchase Success: \(product)")
            case .error(let error):
                switch error.code {
                case.unknown:
                    self.showAlert(title: "Purchase Failed!", message: "Cannot connect to iTunes Store")
                    print("Purchase Failed: \(error)")
                    break
                case.paymentInvalid:
                    self.showAlert(title: "Purchase Failed!", message: "Cannot connect to iTunes Store")
                    print("Purchase Failed: \(error)")
                    break
                case .paymentNotAllowed:
                    self.showAlert(title: "Purchase Failed!", message: "Cannot connect to iTunes Store")
                    print("Purchase Failed: \(error)")
                    break
                case.paymentCancelled:
                    /*if (productId != Constants.removeAdsID) {
                    let popUpVC = DiscountView.create()
                    let controller = UIApplication.topViewController()
                    controller?.addChild(popUpVC)
                    popUpVC.view.frame = (controller?.view.frame)!
                    controller?.view.addSubview(popUpVC.view)
                    popUpVC.didMove(toParent: controller)
                    }*/
                    break
                    
                default:
                    self.showAlert(title: "Purchase Failed!", message: "Cannot connect to iTunes Store")
                    print("Purchase Failed: \(error)")
                    break
                
                }
            }
            self.hideActivityIndicator()
        }
    }
    
    func completePurchase(productId: String) {
        switch productId {
        case Constants.weekSub, Constants.monthSub, Constants.yearSub:
            UserDefaults.standard.set(true, forKey: "proFlag")
            UserDefaults.standard.set(true, forKey: "subIsActive")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "afterPurchaseNotif"), object: nil)
            UIApplication.topViewController()!.dismiss(animated: true, completion: nil)
        case Constants.removeAdsID:
            UserDefaults.standard.set(true, forKey: "proFlag")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "afterPurchaseNotif"), object: nil)
        case Constants.perpiecewallpaper:
                   UserDefaults.standard.synchronize()
                   NotificationCenter.default.post(name: Notification.Name(rawValue: "afterPurchaseWallpaperPackNotif"), object: nil)
        default:
            UserDefaults.standard.set(false, forKey: "proFlag")
            
            UserDefaults.standard.synchronize()
        }
    }
    
    func restore() {
        showActivityIndicator()
        SwiftyStoreKit.restorePurchases(atomically: true) {
            results in
            
            if results.restoreFailedPurchases.count > 0 {
                self.showAlert(title: "Restore Failed!", message: "Cannot connect to iTunes Store")
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                
                if Constants.subscriptionEnabled {
                    self.subscriptionRestore = true
                    self.verifySubscription()
                } else {
                    for product in results.restoredPurchases {
                        if product.productId != Constants.weekSub &&
                        product.productId != Constants.monthSub &&
                        product.productId != Constants.yearSub {
                            self.completePurchase(productId: product.productId)
                        }
                    }
                    self.showAlert(title: "Restore Success!", message: "All purchased products have been restored")
                }
            }
            else {
                self.showAlert(title: "Nothing to Restore", message: "It seems you don't have an active subscription")
                print("Nothing to Restore")
            }
            self.hideActivityIndicator()
        }
    }
    
    func loadSubscriptionPrices(onComplete: (()->Void)?) {
        SwiftyStoreKit.retrieveProductsInfo([Constants.weekSub, Constants.monthSub, Constants.yearSub]) {
            result in
            
            var retrivedPrices = 0
            
            for product in result.retrievedProducts {
                switch product.productIdentifier {
                case Constants.weekSub:
                    self.weeklylocalizedPrice = product.localizedPrice!
                    retrivedPrices += 1
                case Constants.monthSub:
                    self.monthlylocalizedPrice = product.localizedPrice!
                    retrivedPrices += 1
                case Constants.yearSub:
                    self.yearlylocalizedPrice = product.localizedPrice!
                    retrivedPrices += 1
                default:
                    print("Unknown product: \(product.productIdentifier)")
                }
            }
            if retrivedPrices == 3 {
                onComplete?()
            }
        }
    }
    
    func completeTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) {
            products in

            for product in products {
                
                if product.transaction.transactionState == .purchased || product.transaction.transactionState == .restored {
                    
                    if product.needsFinishTransaction {
                        //
                        SwiftyStoreKit.finishTransaction(product.transaction)
                        self.completePurchase(productId: product.productId)
                        print("purchased: \(product)")
                    }
                }
            }
        }
    }
    
    func verifySubscription() {
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Constants.sharedSecret)
        
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh:true, completion: {(result)
            in
        
            switch result {
            case .success(let receipt):
                // Verify the purchase of a Subscription
                
                var subscriptionIsActive = false
                
                let purchaseWeekSubResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: Constants.weekSub, inReceipt: receipt)
                switch purchaseWeekSubResult {
                case .purchased(let expiresDate):
                    print("Product \(Constants.weekSub) is valid until \(expiresDate)")
                    subscriptionIsActive = true
                case .expired(let expiresDate):
                    print("Product \(Constants.weekSub) is expired since \(expiresDate)")
                    if Constants.freeTrialEnabled {
                        UserDefaults.standard.set(true, forKey: "hideTrialButton")
                    }
                case .notPurchased:
                    print("The user has never purchased this product \(Constants.weekSub)")
                }
                
                let purchaseMonthSubResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: Constants.monthSub, inReceipt: receipt)
                switch purchaseMonthSubResult {
                case .purchased(let expiresDate):
                    print("Product \(Constants.monthSub) is valid until \(expiresDate)")
                    subscriptionIsActive = true
                case .expired(let expiresDate):
                    print("Product \(Constants.monthSub) is expired since \(expiresDate)")
                case .notPurchased:
                    print("The user has never purchased this product \(Constants.monthSub)")
                }
                
                
                if subscriptionIsActive {
                    
                    if self.subscriptionRestore {
                        self.subscriptionRestore = false
                        self.showAlert(title: "Restore Success", message: "Subscription has been restored!", closeParentView: true)
                    }
                    
                    UserDefaults.standard.set(true, forKey: "proFlag")
                    UserDefaults.standard.set(true, forKey: "subIsActive")
                    UserDefaults.standard.synchronize()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "afterPurchaseNotif"), object: nil)
                } else {
                    
                    if self.subscriptionRestore {
                        self.subscriptionRestore = false
                        self.showAlert(title: "Subscription Expired", message: "You have no active subscription to restore!")
                    }
                    
                    UserDefaults.standard.set(false, forKey: "proFlag")
                    
                    UserDefaults.standard.synchronize()
                    
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
                
                
            }
        
    })
    
}
}
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
