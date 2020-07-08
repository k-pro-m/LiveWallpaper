//
//  CategoryCell.swift
//  Walley
//
//  Created by Bashar Madi on 7/9/18.
//  Copyright © 2018 Bashar Madi. All rights reserved.
//

import UIKit

class CategoryCell:UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var lockedIMGVIEW: UIImageView!
    
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var Comment: UIButton!
    @IBOutlet weak var CommentCount: UILabel!
    
    override func prepareForReuse() {
        if (self.titleLabel != nil) {
        for view:UIView in self.titleLabel.subviews {
          
                view.removeFromSuperview()
           }
        }
        
    }
    
    override var isSelected: Bool {
        didSet {
            if (titleLabel != nil) {
            if isSelected {
                let margins = self.titleLabel.bounds.size.width - self.titleLabel.intrinsicContentSize.width
                let frame = CGRect(x: margins/2, y: self.titleLabel.bounds.height - 1, width: self.titleLabel.intrinsicContentSize.width, height: 2)
                let selectedView = UIView(frame: frame)
                selectedView.backgroundColor = UIColor.white
                self.titleLabel.addSubview(selectedView)
            }
            else {
                for view:UIView in self.titleLabel.subviews {
                    
                    view.removeFromSuperview()
                }
            }
            }
        }
            
    }
  
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
    }
    
    
}
