//
//  DiscountView.swift
//  Walley
//
//  Created by Bashar Madi on 12/8/18.
//  Copyright © 2018 Bashar Madi. All rights reserved.
//

import UIKit


class DiscountView:UIViewController {
    
    static func create() -> UIViewController {
        let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DiscountView") as! DiscountView
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAnimated()
    }
    
    
    func showAnimated() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 1.0
        })
    }
    
    func hideAnimated() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished) in
            if (finished) {
                self.removeFromParent()
            }
        })
    }
    
    
    @IBAction func closeBtnAction(_ sender: Any) {
        hideAnimated()
    }
    @IBAction func buyBtnAction(_ sender: Any) {
        let manager = ShopManager.sharedInstance
        manager.purchaseProduct(productId: Constants.removeAdsID)
    }
    
}
