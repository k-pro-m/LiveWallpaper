//
//  SignupVC.swift
//  Walley
//
//  Created by Milan Patel on 08/10/19.
//  Copyright © 2019 Bashar Madi. All rights reserved.
//

import UIKit
protocol SignupVCDelegate:NSObjectProtocol {
    func loginVcopen()
    func RefreshVCAfterSignUp()
}
class SignupVC: UIViewController {
    var SignupVCDelegate:SignupVCDelegate?

    @IBOutlet var mainbackUIVIEW: UIView!
    @IBOutlet var mainLBL: UILabel!
    
    @IBOutlet var signupBTN: UIButton!
    @IBOutlet var profileIMGVIEW: UIImageView!
    @IBOutlet var nameTXT: UITextField!
    @IBOutlet var emailTXT: UITextField!
    @IBOutlet var passwordTXT: UITextField!
    
    @IBOutlet var moveloginBTN: UIButton!
    
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    @IBAction func signupwasPressed(_ sender: Any) {
        if validateFields() {
            signupUser()
        }
        self.dismissKeyboard()
    }
    @IBAction func backBTNwasPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func moveloginwasPressed(_ sender: Any) {
        SignupVCDelegate?.loginVcopen()
    }
    @IBAction func profilechangewasPressed(_ sender: Any) {
        imagepickeropen()
    }
}

// MARK: Helpers
extension SignupVC {
    fileprivate func setupView() {
        let formattedString = NSMutableAttributedString()
        formattedString.normal("Already have an account? ", size: 14, color: nil).bold("Login", size: 16, color: nil)
        moveloginBTN.setAttributedTitle(formattedString, for: .normal)
        emailTXT.delegate = self
        nameTXT.delegate = self
        passwordTXT.delegate = self
       
        
        profileIMGVIEW.layer.borderWidth = 1.0
        profileIMGVIEW.layer.masksToBounds = false
        profileIMGVIEW.layer.cornerRadius = profileIMGVIEW.frame.size.width / 2
        profileIMGVIEW.clipsToBounds = true
        
        setcolor()
    }
    func setcolor() {
        if let backColorData = UserDefaults.standard.object(forKey: DefaultKeys.backcolorKey) as? Data {
            
            do {
                let backColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backColorData)
                    mainbackUIVIEW.backgroundColor = backColor
                    signupBTN.setTitleColor(backColor, for: .normal)
            } catch { print(error) }
            
        }
            if let titleColorData = UserDefaults.standard.object(forKey: DefaultKeys.titlecolorKey) as? Data{
                do {
                    let titleColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: titleColorData)
                    
                       mainLBL.textColor = titleColor
                          nameTXT.textColor = titleColor
                          emailTXT.textColor = titleColor
                          passwordTXT.textColor = titleColor
                                 
                          nameTXT.attributedPlaceholder = NSAttributedString(
                                                 string: "Name",
                                                 attributes: [
                                                     NSAttributedString.Key.foregroundColor: titleColor ?? .black, NSAttributedString.Key.font:nameTXT.font ?? UIFont.systemFont(ofSize: 14.0)
                                                         ]
                                                 )
                          
                          emailTXT.attributedPlaceholder = NSAttributedString(
                              string: "Email id",
                              attributes: [
                                  NSAttributedString.Key.foregroundColor: titleColor ?? .black, NSAttributedString.Key.font:emailTXT.font ?? UIFont.systemFont(ofSize: 14.0)
                                      ]
                              )
                          
                        passwordTXT.attributedPlaceholder = NSAttributedString(
                                      string: "Password",
                                      attributes: [
                                              NSAttributedString.Key.foregroundColor: titleColor ?? .black, NSAttributedString.Key.font:passwordTXT.font ?? UIFont.systemFont(ofSize: 14.0)
                                              ]
                                      )
                          signupBTN.backgroundColor = titleColor
                    profileIMGVIEW.layer.borderColor = (titleColor ?? .black).cgColor
                } catch { print(error) }
            }
        
    }
    
    fileprivate func validateFields() -> Bool {
        if !nameTXT.text!.isValidText() {
            Common.showToast(with: "Enter Name")
            return false
        }
        else if !emailTXT.text!.isValidEmail() {
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
    func cleartextfieldValues() {
        emailTXT.text = ""
        passwordTXT.text = ""
        nameTXT.text = ""
    }
}

// MARK: Uitextfielddelegate
extension SignupVC:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameTXT { // Switch focus to other text field
            emailTXT.becomeFirstResponder()
        }
        else if textField == emailTXT
        {
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
extension SignupVC {
    fileprivate func signupUser() {
        var parameters: APIDict = [:]
        parameters["name"] = nameTXT.text ?? ""
        parameters["email"] = emailTXT.text ?? ""
        parameters["password"] = passwordTXT.text ?? ""
       
        LambdaManager.shared.CallUplaodimageApi(configs.signup, profileIMGVIEW.image , parameters) { (data, header, statusCode, error) in
            guard let json = data else { return }
            if json.safeBool("success") {
                if let data = json["data_user"] as? Array<Any>
                {
                    self.cleartextfieldValues()
                    UserDefaults.standard.set(data[0], forKey: DefaultKeys.userdataKey)
                    self.backBTNwasPressed(self)
                    self.SignupVCDelegate?.RefreshVCAfterSignUp()
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

extension SignupVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    
    func imagepickeropen() {

           if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
               print("Button capture")

               imagePicker.delegate = self
               imagePicker.sourceType = .savedPhotosAlbum
               imagePicker.allowsEditing = false

               present(imagePicker, animated: true, completion: nil)
           }
       }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
         self.profileIMGVIEW.image = image
        
    }
}
