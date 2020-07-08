//
//  ChangePasswordVC.swift
//  Walley
//
//  Created by Milan Patel on 11/10/19.
//  Copyright © 2019 Bashar Madi. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {

    @IBOutlet var oldpwdTXT: ATTextField!
    @IBOutlet var confirmpwdTXT: ATTextField!
    @IBOutlet var newpwdTXT: ATTextField!
    @IBOutlet var mainLBL: UILabel!
    
    @IBOutlet var mainbackVIEW: UIView!
    @IBOutlet var changepwdBTN: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @IBAction func backBTNwasPressed(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changepwdBTNwasPressed(_ sender: Any) {
        if validateFields() {
            changepwdforUser()
        }
        self.dismissKeyboard()
    }
}
// MARK: Helpers
extension ChangePasswordVC {
    fileprivate func setupView() {
       
        oldpwdTXT.delegate = self
        newpwdTXT.delegate = self
        confirmpwdTXT.delegate = self
        
        setcolor()
    }
    func setcolor() {
    if let backColorData = UserDefaults.standard.object(forKey: DefaultKeys.backcolorKey) as? Data {
        
        do {
            let backColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backColorData)
                mainbackVIEW.backgroundColor = backColor
                                   changepwdBTN.setTitleColor(backColor, for: .normal)
        } catch { print(error) }
        }
        
        if let titleColorData = UserDefaults.standard.object(forKey: DefaultKeys.titlecolorKey) as? Data{
            do {
                let titleColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: titleColorData)
                
                   mainLBL.textColor = titleColor
                oldpwdTXT.textColor = titleColor
                                   newpwdTXT.textColor = titleColor
                                   confirmpwdTXT.textColor = titleColor
                                   
                                   oldpwdTXT.attributedPlaceholder = NSAttributedString(
                                       string: "Old password",
                                       attributes: [
                                        NSAttributedString.Key.foregroundColor: titleColor ?? .black, NSAttributedString.Key.font:oldpwdTXT.font ?? UIFont.systemFont(ofSize: 14.0)
                                       ]
                                   )
                                   newpwdTXT.attributedPlaceholder = NSAttributedString(
                                       string: "New password",
                                       attributes: [
                                        NSAttributedString.Key.foregroundColor: titleColor ?? .black, NSAttributedString.Key.font:newpwdTXT.font ?? UIFont.systemFont(ofSize: 14.0)
                                       ]
                                   )
                                   confirmpwdTXT.attributedPlaceholder = NSAttributedString(
                                       string: "Confirm password",
                                       attributes: [
                                        NSAttributedString.Key.foregroundColor: titleColor ?? .black, NSAttributedString.Key.font:confirmpwdTXT.font ?? UIFont.systemFont(ofSize: 14.0)
                                       ]
                                   )
                                   changepwdBTN.backgroundColor = titleColor
                                  
            } catch { print(error) }
        }
    }

    
    fileprivate func validateFields() -> Bool {
        if !oldpwdTXT.text!.isValidText() {
            // show alert for invalid email
            Common.showToast(with: "Enter old password")
            return false
        }
        else if !newpwdTXT.text!.isValidText() {
            Common.showToast(with: "Enter new password")
            return false
        }
        else if !confirmpwdTXT.text!.isValidText() || newpwdTXT.text !=  confirmpwdTXT.text{
            Common.showToast(with: "Enter valid confirm password")
            return false
        }
        // same way check other fields if needed before sending any requests
        
        return true
    }
   
    func cleartextfieldValues() {
        oldpwdTXT.text = ""
        newpwdTXT.text = ""
        confirmpwdTXT.text = ""
    }
}

// MARK: Uitextfielddelegate
extension ChangePasswordVC:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           
           if textField == oldpwdTXT { // Switch focus to other text field
               newpwdTXT.becomeFirstResponder()
           }
           else if textField == newpwdTXT
           {
                confirmpwdTXT.becomeFirstResponder()
           }
           else
           {
               self.dismissKeyboard()
           }
           return true
       }
}
// MARK: APIs
extension ChangePasswordVC {
    fileprivate func changepwdforUser() {
        var parameters: APIDict = [:]
        parameters["user_id"] = Common.getUserid()
        parameters["oldpassword"] = oldpwdTXT.text ?? ""
        parameters["newpassword"] = newpwdTXT.text ?? ""
       
        LambdaManager.shared.CallApi(configs.changepassword, parameters) { (data, header, statusCode, error) in
            guard let json = data else { return }
            if json.safeBool("success") {
                self.cleartextfieldValues()
                Common.showToast(with: "\(json["message"] ?? "")")
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
