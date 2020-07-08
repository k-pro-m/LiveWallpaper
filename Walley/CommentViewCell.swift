//
//  CommentViewCell.swift
//  Walley
//
//  Created by Muhammad Ahsan Riaz on 08/01/2020.
//  Copyright © 2020 Bashar Madi. All rights reserved.
//

import UIKit

class CommentViewCell: UITableViewCell {

    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userComment: UILabel!
    @IBOutlet weak var CommentDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.layer.cornerRadius = 35
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
