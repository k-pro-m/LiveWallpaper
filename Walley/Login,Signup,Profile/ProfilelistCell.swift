//
//  ProfilelistCell.swift
//  Walley
//
//  Created by Milan Patel on 11/10/19.
//  Copyright © 2019 Bashar Madi. All rights reserved.
//

import UIKit

class ProfilelistCell: UITableViewCell {
    @IBOutlet var titleLBL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        if let backColorData = UserDefaults.standard.object(forKey: DefaultKeys.backcolorKey) as? Data {
//                   if let backColor = NSKeyedUnarchiver.unarchiveObject(with:backColorData as Data) as? UIColor {
//                       logoutBTN.setTitleColor(backColor, for: .normal)
//                   }
//               }
               if let titleColorData = UserDefaults.standard.object(forKey: DefaultKeys.titlecolorKey) as? Data{
               do {
                   let titleColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: titleColorData)
                       
                       titleLBL.textColor = titleColor

                   }
                  catch { print(error) }
               }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
