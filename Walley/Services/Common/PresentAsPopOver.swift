//
//  PresentAsPopOver.swift
//  AT
//
//  Created by Appernaut on 29/04/19.
//  Copyright © 2019 Appernaut. All rights reserved.
//

import UIKit

/**
 By default, when you use:
 
 ```
 controller.modalPresentationStyle = .popover
 ```
 
 in a horizontally compact environment (iPhone in portrait mode), this option behaves the same as fullScreen.
 You can make it to always show a popover by using:
 
 ```
 let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: controller)
 ```
 */
class PresentAsPopover : NSObject, UIPopoverPresentationControllerDelegate {
    
    // `sharedInstance` because the delegate property is weak - the delegate instance needs to be retained.
    private static let sharedInstance = PresentAsPopover()
    
    private override init() {
        super.init()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    static func configurePresentation(forController controller : UIViewController) -> UIPopoverPresentationController {
        controller.modalPresentationStyle = .popover
        let presentationController = controller.presentationController as! UIPopoverPresentationController
        presentationController.delegate = PresentAsPopover.sharedInstance
        presentationController.backgroundColor = .white
        return presentationController
    }
}
