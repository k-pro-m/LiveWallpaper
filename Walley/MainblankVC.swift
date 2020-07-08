//
//  MaintabbarVC.swift
//  Walley
//
//  Created by Milan Patel on 13/10/19.
//  Copyright © 2019 Bashar Madi. All rights reserved.
//

import UIKit

class MainblankVC: UIViewController,UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
//        MaintabbarVC
        let vc = (self.storyboard?.instantiateViewController(withIdentifier: "MaintabbarVC") as! MaintabbarVC)
        self.navigationController?.pushViewController(vc, animated: false)
    }

    
}
