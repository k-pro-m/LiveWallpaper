//
//  customCell.swift
//  Walley
//
//  Created by Bashar Madi on 8/23/17.
//  Copyright © 2017 Bashar Madi. All rights reserved.
//

import UIKit

class customCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryImageView: UIImageView!
    
    @IBOutlet var lockedIMGVIEW: UIImageView!
    
    @IBOutlet weak var categoryTitleLabel: UILabel!
   
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var gradientView: UIImageView!
    @IBOutlet weak var Comment: UIButton!
    @IBOutlet weak var CommentCount: UILabel!
    
    override func prepareForReuse() {
        for view:UIView in self.contentView.subviews {
        view.setNeedsLayout()
          //view.alpha = 0.0
           
        }
    }
    
    
}
