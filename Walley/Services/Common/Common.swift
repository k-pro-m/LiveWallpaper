import UIKit
import Foundation
import Toaster
import UserNotifications


typealias APIDict = [String: Any]
typealias StringDict = [String: String]

// MARK: - Singleton
final class SharedManager {
    
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    static let instance = SharedManager()
}


// MARK: Common class
open class Common {

    static let instance = Common()
    public init(){}
    
    
    // Method for dislay an alert
    class func showAlert(with title:String?, message:String?, for viewController:UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    // Method for dislay an Toaster
    class func showToast(with message:String!){
        let toast = Toast(text: message)
        toast.show()
    }
    
    class func getUserid() -> String {
        if let obj = UserDefaults.standard.object(forKey: DefaultKeys.userdataKey) as? Dictionary<String,Any> {
            return obj["user_id"] as! String
        }
        
        return "0"
    }
    class func getUsername() -> String {
        if let obj = UserDefaults.standard.object(forKey: DefaultKeys.userdataKey) as? Dictionary<String,Any> {
            return obj["user_name"] as! String
        }
        
        return ""
    }
    // To get app delegate
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    class func showPopup(_ controller: UIViewController, sourceView: UIView, sourceController: UIViewController) {
        let presentationController = PresentAsPopover.configurePresentation(forController: controller)
        presentationController.sourceView = sourceView
        presentationController.sourceRect = sourceView.bounds
        presentationController.permittedArrowDirections = [.up]
        DispatchQueue.main.async {
            sourceController.present(controller, animated: false)
        }
    }
    
    class func Back_PushView(PushVc:UIViewController,navigationController:UINavigationController) {
            navigationController.popViewController(animated: false)
            navigationController.pushViewController(PushVc, animated: true)
    }
}

// MARK:  User Management
extension Common {
    
    class func shareText(with text: String, sender: UIView, for viewController:UIViewController) {
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = sender
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        DispatchQueue.main.async {
            viewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}


