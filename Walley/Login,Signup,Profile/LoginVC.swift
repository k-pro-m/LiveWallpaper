//
//  LoginVC.swift
//  Walley
//
//  Created by Milan Patel on 08/10/19.
//  Copyright © 2019 Bashar Madi. All rights reserved.
//

import UIKit
import OneSignal

protocol LoginVCDelegate:NSObjectProtocol {
    func ForgotpwdVcopen()
    func RefreshVc()
}
class LoginVC: UIViewController {
    var LoginVCDelegate:LoginVCDelegate?

    @IBOutlet var mainbackUIVIEW: UIView!
    @IBOutlet var mainLBL: UILabel!
    
    @IBOutlet var emailidTXT: UITextField!
    
    @IBOutlet var passwordTXT: UITextField!
    
    @IBOutlet var loginBTN: UIButton!
    
    @IBOutlet var movesignupBTN: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @IBAction func loginWasPressed(_ sender: Any) {
           if validateFields() {
               loginUser()
           }
        self.dismissKeyboard()

    }
    @IBAction func backBTNwasPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func movesignupwasPressed(_ sender: Any) {
        LoginVCDelegate?.ForgotpwdVcopen()
    }
}

// MARK: Helpers
extension LoginVC {
    fileprivate func setupView() {
        let formattedString = NSMutableAttributedString()
        formattedString.normal("", size: 14, color: nil).bold("Forgot your password?", size: 16, color: nil)
        movesignupBTN.setAttributedTitle(formattedString, for: .normal)
        emailidTXT.delegate = self
        passwordTXT.delegate = self
        setcolor()
    }
    func setcolor() {
            if let backColorData = UserDefaults.standard.object(forKey: DefaultKeys.backcolorKey) as? Data {
                
                do {
                    let backColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backColorData)
                    
                        mainbackUIVIEW.backgroundColor = backColor
                        loginBTN.setTitleColor(backColor, for: .normal)
                    
                }catch { print(error) }
        }
                   if let titleColorData = UserDefaults.standard.object(forKey: DefaultKeys.titlecolorKey) as? Data
                   {
                    do {
                        let titleColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: titleColorData)
                        mainLBL.textColor = titleColor
                        emailidTXT.textColor = titleColor
                        passwordTXT.textColor = titleColor
                        
                        emailidTXT.attributedPlaceholder = NSAttributedString(
                            string: "Email id",
                            attributes: [
                                NSAttributedString.Key.foregroundColor: titleColor ?? .black, NSAttributedString.Key.font:emailidTXT.font ?? UIFont.systemFont(ofSize: 14.0)
                            ]
                        )
                        passwordTXT.attributedPlaceholder = NSAttributedString(
                            string: "Password",
                            attributes: [
                                NSAttributedString.Key.foregroundColor: titleColor  ?? .black, NSAttributedString.Key.font:passwordTXT.font ?? UIFont.systemFont(ofSize: 14.0)
                            ]
                        )
                        loginBTN.backgroundColor = titleColor
                    } catch { print(error) }
                }

        }
    fileprivate func validateFields() -> Bool {
        if !emailidTXT.text!.isValidEmail() {
            // show alert for invalid email
            Common.showToast(with: "Enter Valid Email id")
            return false
        }
        else if !passwordTXT.text!.isValidText() {
            Common.showToast(with: "Enter Password")
            return false
        }
        // same way check other fields if needed before sending any requests
        
        return true
    }
    fileprivate func pushHomeView()
    {
//        let vc = self.storyboard!.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
//        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func cleartextfieldValues() {
        emailidTXT.text = ""
        passwordTXT.text = ""
    }
}

// MARK: Uitextfielddelegate
extension LoginVC:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           
           if textField == emailidTXT { // Switch focus to other text field
               passwordTXT.becomeFirstResponder()
           }
           else if textField == passwordTXT
           {
                self.dismissKeyboard()
           }
           else
           {
               self.dismissKeyboard()
           }
           return true
       }
}
// MARK: APIs
extension LoginVC {
    fileprivate func loginUser() {
        var parameters: APIDict = [:]
        parameters["email"] = emailidTXT.text ?? ""
        parameters["password"] = passwordTXT.text ?? ""
       
        LambdaManager.shared.CallApi(configs.login, parameters) { (data, header, statusCode, error) in
            guard let json = data else { return }
            if json.safeBool("success") {
                if let data = json["data_login"] as? Array<Any>
                {
                    self.cleartextfieldValues()
                    UserDefaults.standard.set(data[0], forKey: DefaultKeys.userdataKey)
                    self.backBTNwasPressed(self)
                    self.LoginVCDelegate?.RefreshVc()
                    
                    
                    OneSignal.sendTag("user_id", value: Common.getUserid())
                }
            }
            else
            {
                Common.showToast(with: "\(json["message"] ?? "")")
                self.cleartextfieldValues()
            }
        }
    }
}


