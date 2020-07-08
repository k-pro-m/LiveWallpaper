//
//  logoutCell.swift
//  Walley
//
//  Created by Milan Patel on 11/10/19.
//  Copyright © 2019 Bashar Madi. All rights reserved.
//

import UIKit

class logoutCell: UITableViewCell {

    @IBOutlet var logoutBTN: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if let backColorData = UserDefaults.standard.object(forKey: DefaultKeys.backcolorKey) as? Data {
        
        do {
            let backColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backColorData)
                logoutBTN.setTitleColor(backColor, for: .normal)

        } catch { print(error) }
        }
       if let titleColorData = UserDefaults.standard.object(forKey: DefaultKeys.titlecolorKey) as? Data{
          do {
              let titleColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: titleColorData)
           logoutBTN.backgroundColor = titleColor

       } catch { print(error) }
        
            }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


