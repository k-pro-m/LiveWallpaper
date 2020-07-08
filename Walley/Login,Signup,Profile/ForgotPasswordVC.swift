//
//  ForgotPasswordVC.swift
//  Walley
//
//  Created by Milan Patel on 09/10/19.
//  Copyright © 2019 Bashar Madi. All rights reserved.
//

import UIKit
protocol ForgotPasswordVCDelegate:NSObjectProtocol {
    func loginVcopen()
}
class ForgotPasswordVC: UIViewController {
    var ForgotPasswordVCDelegate:ForgotPasswordVCDelegate?

    @IBOutlet var mainbackUIVIEW: UIView!
    @IBOutlet var mainLBL: UILabel!
    
    @IBOutlet var movetologinLBL: UIButton!
    @IBOutlet var emailTXT: UITextField!
    
  
    @IBOutlet var forgotpwdBTN: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBTNwasPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func forgotBTNwasPressed(_ sender: Any) {
        if validateFields() {
            ForgotPasswordUser()
        }
        self.dismissKeyboard()
    }
    @IBAction func movetologinBTNwasPressed(_ sender: Any) {
        ForgotPasswordVCDelegate?.loginVcopen()
    }
}


// MARK: Helpers
extension ForgotPasswordVC {
    fileprivate func setupView() {
        let formattedString = NSMutableAttributedString()
        formattedString.normal("Already have an account? ", size: 14, color: nil).bold("Login", size: 16, color: nil)
        movetologinLBL.setAttributedTitle(formattedString, for: .normal)
        emailTXT.delegate = self
        setcolor()
    }
    func setcolor() {
        
        if let backColorData = UserDefaults.standard.object(forKey: DefaultKeys.backcolorKey) as? Data {
                    
                    do {
                        let backColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backColorData)
                       
                        mainbackUIVIEW.backgroundColor = backColor
                        forgotpwdBTN.setTitleColor(backColor, for: .normal)
                        
                        if let titleColorData = UserDefaults.standard.object(forKey: DefaultKeys.titlecolorKey) as? Data {
                            let titleColor =  try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: titleColorData)
                                mainLBL.textColor = titleColor
                                emailTXT.textColor = titleColor
                                
                                emailTXT.attributedPlaceholder = NSAttributedString(
                                    string: "Email id",
                                    attributes: [
                                        NSAttributedString.Key.foregroundColor: titleColor ?? .black, NSAttributedString.Key.font:emailTXT.font ?? UIFont.systemFont(ofSize: 14.0)
                                    ]
                                )
                                
                                forgotpwdBTN.backgroundColor = titleColor
                        }
                        
                    } catch { print(error) }
                   
                }
        }
    fileprivate func validateFields() -> Bool {
        if !emailTXT.text!.isValidEmail() {
            // show alert for invalid email
            Common.showToast(with: "Enter Valid Email id")
            return false
        }
       
        // same way check other fields if needed before sending any requests
        
        return true
    }
    
    func cleartextfieldValues() {
        emailTXT.text = ""
    }
}

// MARK: Uitextfielddelegate
extension ForgotPasswordVC:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTXT { // Switch focus to other text field
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
extension ForgotPasswordVC {
    fileprivate func ForgotPasswordUser() {
        var parameters: APIDict = [:]
        parameters["user_email"] = emailTXT.text ?? ""
       
        LambdaManager.shared.CallApi(configs.forgotpassword, parameters) { (data, header, statusCode, error) in
            guard let json = data else { return }
            if json.safeBool("success") {
                
                self.cleartextfieldValues()
                
                Common.showAlert(with: "Password reset link hasbeen sent in email,click on reset link after login with any new password", message: "", for: self)

                self.backBTNwasPressed(self)
                
            }
            else
            {
                Common.showToast(with: "\(json["message"] ?? "")")
                self.cleartextfieldValues()
            }
        }
    }
}
