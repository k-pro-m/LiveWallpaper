//
//  Button+At.swift
//  bogo
//
//  Created by Appernaut on 05/07/19.
//  Copyright © 2019 Appernaut. All rights reserved.
//

import UIKit


// Button class to use in reusable cells
@IBDesignable class ATButton: UIButton {
    @IBInspectable var isSupportImage : Bool = false
    
    @IBInspectable public var spacing: CGFloat = 0.0 {
        didSet {
            update()
        }
    }
    
    private func update() {
        let insetAmount = spacing / 2
        let writingDirection = UIApplication.shared.userInterfaceLayoutDirection
        let factor: CGFloat = writingDirection == .leftToRight ? 1 : -1
        
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount*factor, bottom: 0, right: insetAmount*factor)
        self.titleEdgeInsets = UIEdgeInsets(top: self.titleEdgeInsets.top, left: insetAmount*factor, bottom: self.titleEdgeInsets.bottom, right: -insetAmount*factor)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }
    
    typealias DidTapButton = (ATButton) -> ()
    
    // Set click event handler
    var didTouchUpInside: DidTapButton? {
        didSet {
            if didTouchUpInside != nil {
                addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
            } else {
                removeTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
            }
        }
    }
    
    // Action
    @objc func didTouchUpInside(_ sender: UIButton) {
        if let handler = didTouchUpInside {
            handler(self)
        }
    }
}
