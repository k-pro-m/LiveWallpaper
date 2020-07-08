//
//  Extensions.swift
//  MealPlanner
//
//  Created by somsongold on 7/26/18.
//  Copyright © 2018 somsongold. All rights reserved.
//

import UIKit
import SystemConfiguration
import SDWebImage

//extension UIView {
//    @IBInspectable var cornerRadius : CGFloat {
//        set {
//            layer.cornerRadius = newValue
//            layer.masksToBounds = newValue > 0
//        }
//        get {
//            return layer.cornerRadius
//        }
//    }
//
//    @IBInspectable var borderWidth : CGFloat {
//        set {
//            layer.borderWidth = newValue
//        }
//
//        get {
//            return layer.borderWidth
//        }
//    }
//
//    @IBInspectable var borderColor : UIColor? {
//        set {
//            guard newValue != nil else {
//                layer.borderColor = nil
//                return
//            }
//            layer.borderColor = newValue?.cgColor
//        }
//        get {
//            guard let color = layer.borderColor else {
//                return nil
//            }
//            return UIColor(cgColor: color)
//        }
//    }
//}

//extension UIFont {
//    class func defaultFont(_ size: CGFloat = 14) -> UIFont {
//        return UIFont(name: ATFonts.regular, size: size)!
//    }
//
//    class func lightFont(_ size: CGFloat = 14) -> UIFont {
//        return UIFont(name: ATFonts.light, size: size)!
//    }
//    
//    class func mediumFont(_ size: CGFloat = 14) -> UIFont {
//        return UIFont(name: ATFonts.medium, size: size)!
//    }
//
//    class func boldFont(_ size: CGFloat = 14) -> UIFont {
//        return UIFont(name: ATFonts.bold, size: size)!
//    }
//    
//    class func navigationBarFont(_ size: CGFloat = 20) -> UIFont {
//        return defaultFont(20)
//    }
//}

extension Collection where Index == Int {
    
    /**
     Picks a random element of the collection.
     
     - returns: A random element of the collection.
     */
    func randomElement() -> Iterator.Element? {
        return isEmpty ? nil : self[Int(arc4random_uniform(UInt32(endIndex)))]
    }
    
}

extension UILayoutPriority {
    static func +(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
        return UILayoutPriority(lhs.rawValue + rhs)
    }
    
    static func -(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
        return UILayoutPriority(lhs.rawValue - rhs)
    }
}

var hasTopNotch: Bool {
    if #available(iOS 11.0,  *) {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
    }
    return false
}

extension UIImageView {
    func setImage(with urlString: String, placeholder: UIImage?) {
        if let imageURL = URL(string: urlString) {
            self.sd_setImage(with: imageURL, placeholderImage: placeholder)
        }
    }
}

extension String {

  func CGFloatValue() -> CGFloat? {
    guard let doubleValue = Double(self) else {
      return nil
    }

    return CGFloat(doubleValue)
  }
}

//extension UIApplication {
//
//
//public class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
//    if let nav = base as? UINavigationController {
//        return topViewController(nav.visibleViewController)
//    }
//    if let tab = base as? UITabBarController {
//        if let selected = tab.selectedViewController {
//            return topViewController(selected)
//        }
//    }
//    if let presented = base?.presentedViewController {
//        return topViewController(presented)
//    }
//    return base
//}}
