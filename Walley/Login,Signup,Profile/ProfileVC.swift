//
//  ProfileVC.swift
//  Walley
//
//  Created by Milan Patel on 08/10/19.
//  Copyright © 2019 Bashar Madi. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileVC: UIViewController {

    @IBOutlet var mainbackUIVIEW: UIView!
    @IBOutlet var mainLBL: UILabel!
    @IBOutlet var tableview: UITableView!
    var imagePicker = UIImagePickerController()

    
    @IBOutlet var profileVIEW: UIView!
    
    @IBOutlet var loginsignupVIEW: UIView!
    
    
    @IBOutlet var profileIMGVIEW: UIImageView!
    
    @IBOutlet var nameLBL: UILabel!
    
    @IBOutlet var emailLBL: UILabel!
    
    @IBOutlet var loginBTN: UIButton!
    
    @IBOutlet var signupBTN: UIButton!
    
    var listArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tableview.register(ProfilelistCell.self, forCellReuseIdentifier: "ProfilelistCell")
//        self.tableview.register(logoutCell.self, forCellReuseIdentifier: "logoutCell")

        tableview.delegate = self
        tableview.dataSource = self
        
        profileIMGVIEW.layer.borderWidth = 1.0
        profileIMGVIEW.layer.masksToBounds = false
        profileIMGVIEW.layer.cornerRadius = profileIMGVIEW.frame.size.width / 2
        profileIMGVIEW.clipsToBounds = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
       setcolor()
        rfereshLogindata()
    }
    func setcolor() {
        if let backColorData = UserDefaults.standard.object(forKey: DefaultKeys.backcolorKey) as? Data {
            
            do {
                let backColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backColorData)
                
                    mainbackUIVIEW.backgroundColor = backColor
                                      loginBTN.setTitleColor(backColor, for: .normal)
                                      signupBTN.setTitleColor(backColor, for: .normal)
            } catch { print(error) }
            
        }
            if let titleColorData = UserDefaults.standard.object(forKey: DefaultKeys.titlecolorKey) as? Data{
                do {
                    let titleColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: titleColorData)
                    
                        mainLBL.textColor = titleColor
                        signupBTN.backgroundColor = titleColor
                        loginBTN.backgroundColor = titleColor
                                          
                        emailLBL.textColor = titleColor
                        nameLBL.textColor = titleColor
                    profileIMGVIEW.layer.borderColor = (titleColor ?? .black).cgColor
                } catch { print(error) }
            }
        
    }
   
    
    func rfereshLogindata() {
        if let obj = UserDefaults.standard.object(forKey: DefaultKeys.userdataKey) as? Dictionary<String,Any> {
            profileVIEW.isHidden = false
            loginsignupVIEW.isHidden = true
            nameLBL.text = obj["user_name"] as? String
            emailLBL.text = obj["user_email"] as? String
//            DispatchQueue.global(qos: .background).async {
            if let imagePath = obj["user_image"] as? String {
                
                let NimagePath = imagePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                let imageUrl:URL = URL(string: NimagePath)!
//                let data = try? Data(contentsOf: imageUrl)
//
//                if let imageData = data {
//                    let image = UIImage(data: imageData)
//                    DispatchQueue.main.async {
//                         self.profileIMGVIEW.image = image
//                    }
//                }
                
                profileIMGVIEW.sd_setImage(with: imageUrl, completed: nil)
//                    profileIMGVIEW.sd_setImage(with: imageUrl, completed: {
//                       (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
//                           if error != nil
//                           {
//                           }
//
//                           })
//                   }
            }
            //purchase,chnagepwd,uploadlivewallpaper,logout
            listArray = ["Uploaded Live Wallpaper","Change Password","Purchase","Logout"]
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            
        }
        else
        {
            //purchase
            listArray = ["Purchase"]
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            profileVIEW.isHidden = true
            loginsignupVIEW.isHidden = false
        }
    }
    @IBAction func signupBTNwasPressed(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SignupVC") as? SignupVC
        vc?.SignupVCDelegate  = self
        self.present(vc!, animated: true, completion: nil)
    }
    @IBAction func loginBTNwasPressed(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
        vc?.LoginVCDelegate  = self
        self.present(vc!, animated: true, completion: nil)
    }
    @IBAction func changeProfileWasPressed(_ sender: Any) {
        imagepickeropen()
    }
}

extension ProfileVC:LoginVCDelegate,SignupVCDelegate,ForgotPasswordVCDelegate
{
    func RefreshVc() {
        rfereshLogindata()
    }
    
    func RefreshVCAfterSignUp() {
        rfereshLogindata()
    }
    
    func ForgotpwdVcopen() {
        self.dismiss(animated: false) {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "ForgotPasswordVC") as? ForgotPasswordVC
            vc?.ForgotPasswordVCDelegate  = self
            self.present(vc!, animated: true, completion: nil)
        }
    }
    func signupVcopen() {
        self.dismiss(animated: false) {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "SignupVC") as? SignupVC
            vc?.SignupVCDelegate  = self
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
    func loginVcopen() {
        self.dismiss(animated: false) {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
            vc?.LoginVCDelegate  = self
            self.present(vc!, animated: true, completion: nil)
        }
    }
}
extension ProfileVC:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.listArray[indexPath.row] == "Logout"  {
            return 85
        }
        else
        {
            return 65
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // create a new cell if needed or reuse an old one
        if self.listArray[indexPath.row] == "Logout"  {
            let cell:logoutCell = tableView.dequeueReusableCell(withIdentifier: "logoutCell") as! logoutCell

                   // set the text from the data model
                   
            cell.logoutBTN?.addTarget(self, action: #selector(self.logoutBTNpressed(sender:)), for: .touchUpInside)

            return cell
        }
        else
        {
            let cell:ProfilelistCell = tableView.dequeueReusableCell(withIdentifier: "ProfilelistCell") as! ProfilelistCell

            // set the text from the data model
                   
            cell.titleLBL?.text = self.listArray[indexPath.row]

            return cell
        }
        
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        if self.listArray[indexPath.row] == "Uploaded Live Wallpaper" {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "UploadedLivewallpaperlistVC") as? UploadedLivewallpaperlistVC
            
//            self.present(vc!, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc!, animated: true)
            
        }
        else if self.listArray[indexPath.row] == "Change Password" {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC
            self.present(vc!, animated: true, completion: nil)
            
        }
        else if self.listArray[indexPath.row] == "Purchase" {
            let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)

//            self.present(nextViewController, animated:true)
        }
        else if self.listArray[indexPath.row] == "Logout" {
            UserDefaults.standard.removeObject(forKey: DefaultKeys.userdataKey)
            self.viewWillAppear(true)
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
    
    @objc func logoutBTNpressed(sender: UIButton!) {
       UserDefaults.standard.removeObject(forKey: DefaultKeys.userdataKey)
       self.viewWillAppear(true)
       DispatchQueue.main.async {
           self.tableview.reloadData()
       }
    }
}

extension ProfileVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    
    func imagepickeropen() {

           if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
               print("Button capture")

               imagePicker.delegate = self
               imagePicker.sourceType = .savedPhotosAlbum
               imagePicker.allowsEditing = true

               present(imagePicker, animated: true, completion: nil)
           }
       }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        self.profileIMGVIEW.image = image
        self.uploaduserpic()
    }
}

// MARK: APIs
extension ProfileVC {
    fileprivate func uploaduserpic() {
        var parameters: APIDict = [:]
        parameters["user_id"] = Common.getUserid()
      
       
        LambdaManager.shared.CallUplaodimageApi(configs.chnage_profile_pic, profileIMGVIEW.image , parameters) { (data, header, statusCode, error) in
            guard let json = data else { return }
            if json.safeBool("success") {
               Common.showToast(with: "Profile update successful")
                if let data = json["data_login"] as? Array<Any>
                {
                    UserDefaults.standard.set(data[0], forKey: DefaultKeys.userdataKey)
                    self.rfereshLogindata()
                }
                
            }
            else
            {
                Common.showToast(with: "\(json["message"] ?? "")")
                
            }
        }
    }
}
