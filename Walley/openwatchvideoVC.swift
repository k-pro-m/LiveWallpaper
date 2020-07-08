//
//  openwatchvideoVC.swift
//  Walley
//
//  Created by Milan Patel on 12/10/19.
//  Copyright © 2019 Bashar Madi. All rights reserved.
//

import UIKit
import StoreKit


protocol openwatchvideoVCDelegate:NSObjectProtocol {
    func Open_rewardVideo_premiumview(isrewardviewopen:Bool)
    func Open_PurchaseVideo(ispurchasePack:Bool)
    func backopenrewardvideoVIEW()
}
class openwatchvideoVC: UIViewController,SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    
    var openwatchvideoVCDelegate:openwatchvideoVCDelegate?

    @IBOutlet var imageview: UIImageView!
    @IBOutlet var mainbackUIVIEW: UIView!
    
    @IBOutlet var lblDownloadPackValue: UILabel!
    @IBOutlet var buttonshowVIEW: UIView!
    @IBOutlet var watchvideoBTN: UIButton!
    @IBOutlet var openPremiumBTN: UIButton!
    var thumbimage = UIImage()
    @IBOutlet var backBTN: UIButton!
    @IBOutlet var blurbackUIVIEW: UIView!
    
    var productRequest:SKProductsRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurbackUIVIEW.addSubview(blurEffectView)
        setcolor()
        
        imageview.image = thumbimage
        
               if SKPaymentQueue.canMakePayments() {
                   let productIds:NSSet = NSSet(objects: Constants.perpiecewallpaper)
                   productRequest = SKProductsRequest(productIdentifiers: productIds as! Set<String>)
                   productRequest?.delegate = self
                   productRequest?.start()
               }
        
        
    }
    

    @IBAction func backBTNwasPressed(_ sender: Any) {
        self.openwatchvideoVCDelegate?.backopenrewardvideoVIEW()
    }
    @IBAction func watchvideoBTNwasPressed(_ sender: Any) {
        self.openwatchvideoVCDelegate?.Open_PurchaseVideo(ispurchasePack: true)
//        self.openwatchvideoVCDelegate?.Open_rewardVideo_premiumview(isrewardviewopen: true)
    }
    
    @IBAction func premiumviewBTNwasPressed(_ sender: Any) {
        self.openwatchvideoVCDelegate?.Open_rewardVideo_premiumview(isrewardviewopen: false)
    }

    func setcolor() {
        if let backColorData = UserDefaults.standard.object(forKey: DefaultKeys.backcolorKey) as? Data {
            
            do {
                let backColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backColorData)
                
                      mainbackUIVIEW.backgroundColor = backColor
            } catch { print(error) }
            
        }
            if let titleColorData = UserDefaults.standard.object(forKey: DefaultKeys.titlecolorKey) as? Data{
                do {
                    let titleColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: titleColorData)
                    
                        buttonshowVIEW.backgroundColor = titleColor
                        
                } catch { print(error) }
            }
        
    }
    
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
            
    //        payment = SKPayment(product: self.productList[0])
            DispatchQueue.main.async {
                let products = response.products
                print("Products count:\(products.count)")
                for product in products {
                   
                    
                    if product.productIdentifier == Constants.perpiecewallpaper {
                       
                        self.lblDownloadPackValue.text = "\(product.localizedPrice ?? "\(product.price)") / WALLPAPER"
                        
                    }
                }

            }
           
            
            
        }
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
}
