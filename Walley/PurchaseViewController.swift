//
//  PurchaseViewController.swift
//  Walley
//
//  Created by Bashar Madi on 1/4/18.
//  Copyright © 2018 Bashar Madi. All rights reserved.
//

import UIKit
import StoreKit
import Firebase
import SwiftyStoreKit
class PurchaseViewController: UIViewController,SKProductsRequestDelegate, SKPaymentTransactionObserver {
//    let PRODUCT_LIVE_ID = "com.phantomapps.walley.live"
    var productList = [SKProduct]()
    var proFlag:Bool?
    let storage = UserDefaults.standard
//    var payment:SKPayment?
    let api = Api()
    let remoteConfig = RemoteConfig.remoteConfig()
    let container = UIView()
    let loadingView = UIView()
    let activityIndicator = UIActivityIndicatorView()

    var slider : SBSliderView!
    @IBOutlet var sliderdisplayUIVIEW: UIView!
    
    @IBOutlet var buybtnweekly: UIButton!
    @IBOutlet var buybtnmonthly: UIButton!
    @IBOutlet var buybtnyearly: UIButton!
    
    @IBOutlet weak var disclaimer: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var purchaseStatusLabel: UILabel!
    @IBOutlet weak var restorePurchaseBtn: UIButton!
    @IBOutlet weak var privacyBtn: UIButton!
    @IBOutlet weak var termsBtn: UIButton!
//    var selectedSub = Constants.weekSub
    var productRequest:SKProductsRequest?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let delay = DispatchTime.now() + .seconds(2)
        
       DispatchQueue.main.asyncAfter(deadline: delay, execute: {
        self.closeBtn.isHidden = false
       })
        
        self.proFlag = api.checkProFlag()
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().add(self)
            
            let productIds:NSSet = NSSet(objects: Constants.monthSub,Constants.yearSub,Constants.weekSub)
            productRequest = SKProductsRequest(productIdentifiers: productIds as! Set<String>)
            productRequest?.delegate = self
            productRequest?.start()
        }
        else {
             let alertController = UIAlertController.init(title: "In-App Purchase Disabled", message: "In-App payments are disabled on your device, enable it unlock this feature", preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action)
                in
                
            })
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        setslider()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        UIApplication.shared.isStatusBarHidden = true
        self.setupRemoteConfig()
    }
    
    override var prefersStatusBarHidden: Bool
       {
           return true
       }
    
//    func makeThePurchase() {
//
//        SKPaymentQueue.default().add(payment!)
//
//    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
//        payment = SKPayment(product: self.productList[0])
        DispatchQueue.main.async {
            let products = response.products
            print("Products count:\(products.count)")
            for product in products {
                self.productList.append(product)
                print(product.productIdentifier)
                print("product added")
                
                if product.productIdentifier == Constants.weekSub {
                   
                    
                    self.buybtnweekly?.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;

                    self.buybtnweekly.isEnabled = true
                    self.buybtnweekly.backgroundColor = UIColor.init(red: 22.0/255.0, green: 188.0/255.0, blue: 38.0/255.0, alpha: 1.0)
                    self.buybtnweekly.layer.cornerRadius = self.buybtnweekly.frame.size.width/15.0
//                    self.buybtnweekly.layer.borderWidth = 1.0
//                    self.buybtnweekly.layer.borderColor = UIColor.white.cgColor
                    self.buybtnweekly.clipsToBounds = true
                    self.buybtnweekly.setAttributedTitle(self.converttextpurchasebtn(firststing: "\(product.localizedPrice ?? "\(product.price)") / Week", secondstring: "After 3-day free trial ends"), for: UIControl.State.normal)

                }
                else if product.productIdentifier == Constants.monthSub {
//                    self.buybtnmonthly.isEnabled = true
//                    self.buybtnmonthly.setTitle(self.remoteConfig["buyBtnTitle"].stringValue, for: UIControl.State.normal)
                    
                    self.buybtnmonthly?.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    self.buybtnmonthly.isEnabled = true
                    self.buybtnmonthly.backgroundColor = .clear
                    self.buybtnmonthly.layer.cornerRadius = self.buybtnmonthly.frame.size.width/15.0
                    self.buybtnmonthly.layer.borderWidth = 1.0
                    self.buybtnmonthly.layer.borderColor = UIColor.white.cgColor
                    self.buybtnmonthly.clipsToBounds = true
                    self.buybtnmonthly.setAttributedTitle(self.converttextpurchasebtn(firststing: "\(product.localizedPrice ?? "\(product.price)") / Month", secondstring: "Save 37% off weekly cost"), for: UIControl.State.normal)
                    
                    
                }
                else if product.productIdentifier == Constants.yearSub {
//                    self.buybtnyearly.isEnabled = true
//                    self.buybtnyearly.setTitle(self.remoteConfig["buyBtnTitle"].stringValue, for: UIControl.State.normal)
                    
                    self.buybtnyearly?.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    self.buybtnyearly.isEnabled = true
                    self.buybtnyearly.backgroundColor = .clear
                    self.buybtnyearly.layer.cornerRadius = self.buybtnyearly.frame.size.width/15.0
                    self.buybtnyearly.layer.borderWidth = 1.0
                    self.buybtnyearly.layer.borderColor = UIColor.white.cgColor
                    self.buybtnyearly.clipsToBounds = true
                    self.buybtnyearly.setAttributedTitle(self.converttextpurchasebtn(firststing: "\(product.localizedPrice ?? "\(product.price)") / Year", secondstring: "Save 88% off weekly cost"), for: UIControl.State.normal)
                }
                
                
            }
            
            
            self.restorePurchaseBtn.isEnabled = true
            
//            self.remoteConfig.activateFetched()
            
            self.disclaimer.text = self.disclaimer.text?.replacingOccurrences(of: "Weekly for $0.99", with: self.remoteConfig["price"].stringValue!)
        }
       
        
        
    }
    func converttextpurchasebtn(firststing:String,secondstring:String) -> NSMutableAttributedString {
        
        let buttonText: NSString = "\(firststing)\n\(secondstring)" as NSString

        //getting the range to separate the button title strings
        let newlineRange: NSRange = buttonText.range(of: "\n")

        //getting both substrings
        var substring1: NSString = ""
        var substring2: NSString = ""

        if(newlineRange.location != NSNotFound) {
            substring1 = buttonText.substring(to: newlineRange.location) as NSString
            substring2 = buttonText.substring(from: newlineRange.location) as NSString
        }

        //assigning diffrent fonts to both substrings
        let formattedString = NSMutableAttributedString()
        formattedString.bold(substring1 as String, size: 16, color: .white).normal(substring2 as String, size: 14, color: .white)
        
      let paragraph = NSMutableParagraphStyle()
      paragraph.alignment = .center
        formattedString.addAttributes([.paragraphStyle: paragraph], range: NSMakeRange(0, formattedString.length))
//        = NSAttributedString(string: formattedString,
//                                                           attributes: [.paragraphStyle: paragraph])
        return formattedString
        //assigning the resultant attributed strings to the button
    }
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
      /*  for trans in transactions {
            print (trans.transactionState.rawValue)
            switch trans.transactionState {
            case .purchased, .restored:
                api.setProFlag(state: true)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "afterPurchaseNotif"), object: nil)
                self.dismiss(animated: true, completion: nil)
                queue.finishTransaction(trans)
                break
                
            case .failed:
                let alertController = UIAlertController(title: "Purchase Failed", message: "Something went wrong, we couldn't complete your purchase. Please try again later", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
                queue.finishTransaction(trans)
                break
                
            default:
                print("Please enter your credentials to complete the purchase")
            }
        }*/
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.hideActivityIndicator()
        for transaction:SKPaymentTransaction in queue.transactions {
            let productId = transaction.payment.productIdentifier
            if productId == Constants.removeAdsID {
                api.setProFlag(state: true)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "afterPurchaseNotif"), object: nil)
                let alertController = UIAlertController(title: "Success", message: "Your purchase has been successfully restored. Thank you.", preferredStyle: UIAlertController.Style.alert)
                let action = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: {(action)
                    in
                    self.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
      
    }
    
    
    func rotateIcon(view:UIView, op:String) {
        if op == "start" {
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.duration = 10
            animation.repeatCount = Float.infinity
            animation.fromValue = 0.0
            animation.toValue = Float(.pi * 2.0)
            view.layer.add(animation, forKey: "rotation")
        }
        else {
            if view.layer.animation(forKey: "rotation") != nil {
                view.layer.removeAnimation(forKey: "rotation")
            }
        }
    }
    
    func setupRemoteConfig(){
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled:false)
        self.remoteConfig.configSettings = remoteConfigSettings
        self.remoteConfig.setDefaults(fromPlist: "config")
        self.remoteConfig.fetch(completionHandler: {(status,error)
            in
            if status == .success {
                //self.buybtnweekly.isEnabled = true
                self.remoteConfig.activateFetched()
               // self.buybtnweekly.setTitle(self.remoteConfig["buyBtnTitle"].stringValue, for: UIControl.State.normal)
                self.disclaimer.text = self.disclaimer.text?.replacingOccurrences(of: "Weekly for $0.99", with: self.remoteConfig["price"].stringValue!)
                if self.remoteConfig["selectedSub"].stringValue! == "monthly" {
//                    self.selectedSub = Constants.monthSub
                }
                
            }
        })
    }
    
    private func showActivityIndicator() {
        
        let view = self.view!
        
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
    
    @IBAction func buyBtnyearlyAction(_ sender: Any) {
        let manager = ShopManager.sharedInstance
        manager.purchaseProduct(productId: Constants.yearSub)
        
    }
    @IBAction func buyBtnmonthlyAction(_ sender: Any) {
        let manager = ShopManager.sharedInstance
        manager.purchaseProduct(productId: Constants.monthSub)
    }
    @IBAction func buyBtnweeklyAction(_ sender: Any) {
        let manager = ShopManager.sharedInstance
        manager.purchaseProduct(productId: Constants.weekSub)
    }
    
    @IBAction func closeBtnAction(_ sender: Any) {
        SKPaymentQueue.default().remove(self)
        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: {() in
            
//        })
    }
    
    @IBAction func privacyBtnAction(_ sender: Any) {
        guard let url = URL(string: "https://livewallpapershd.com/privacy_policy.html") else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func termsBtnAction(_ sender: Any) {
        guard let url = URL(string: "https://livewallpapershd.com/terms.html") else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func restorePurchaseBtnAction(_ sender: Any) {
        
        let alertControl = UIAlertController(title: "Restore Purchases", message: "If you'd like to restore your subscription, please click on Restore Subscription. If you have purchased with one-time payment click on Restore One-Time Payment", preferredStyle: .alert)
        let purAction = UIAlertAction(title: "Restore Subscription", style: .default, handler: {(action) in
            let manager = ShopManager.sharedInstance
            manager.restore()
        })
        
        let subAction = UIAlertAction(title: "Restore One-Time Payment", style: .default, handler: {(action)
            in
            self.showActivityIndicator()
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action)
                   in
                  
                   
               })
        alertControl.addAction(purAction)
        alertControl.addAction(subAction)
        alertControl.addAction(cancelAction)

        
        self.present(alertControl, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

extension PurchaseViewController:SBSliderDelegate
{
    func setslider() {
        slider = Bundle.main.loadNibNamed("SBSliderView", owner: self, options: nil)?.first as? SBSliderView
        self.slider!.frame = CGRect(x: 0, y: 0, width: self.sliderdisplayUIVIEW.frame.size.width, height: self.sliderdisplayUIVIEW.frame.size.height)
//        self.slider?.is_checklaberorimage = true
        self.slider?.tag = 500
//        self.slider!.tintcolorimage = #imageLiteral(resourceName: "Rounded Rectangle_Prime")//view.asImage()
        self.slider!.delegate = self
        self.slider!.isUserInteractionEnabled = true
        self.sliderdisplayUIVIEW.addSubview(self.slider!)
        self.slider!.createSlider(withImages:["Diamond","noadsicon"] , title: ["Unlimited Access To Live Wallpapers","No Ads"], withAutoScroll: false, in: self.sliderdisplayUIVIEW)
        self.slider?.startAutoPlay()
    }
}
