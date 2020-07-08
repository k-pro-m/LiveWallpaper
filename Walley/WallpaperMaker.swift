//
//  WallpaperMaker.swift
//  Walley
//
//  Created by Bashar Madi on 2/13/19.
//  Copyright © 2019 Bashar Madi. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices
import RSSelectionMenu
import MapKit
import CoreLocation

struct FilePaths {
    static let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask,true)[0] as AnyObject
    struct VidToLive {
        static var livePath = FilePaths.documentsPath.appending("/")
    }
}


class WallpaperMaker: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var mainbackUIVIEW: UIView!
    @IBOutlet var mainLBL: UILabel!
    @IBOutlet var sharBtn: UIButton!
    
    @IBOutlet var liberaryBTN: UIButton!
    
    
    @IBOutlet weak var livePhotoView: PHLivePhotoView! 
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var welomeLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var saveIndicator: UIActivityIndicatorView!
    
    
    var categoryArray:[categorylistObject] = []
//    var simpleSelectedArray = [String,String]
    var locationManager = CLLocationManager()
    var location: CLLocation?

    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?

    // here I am declaring the iVars for city and country to access them later

    var city: String?
    var country: String?
    var countryShortName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
    }
    override func viewWillAppear(_ animated: Bool) {
        setcolor()
         if self.country != nil || self.country != ""{
             self.setlocationpermission()
         }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setcolor() {
        if let backColorData = UserDefaults.standard.object(forKey: DefaultKeys.backcolorKey) as? Data {
            
            do {
                let backColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backColorData)
                
                       mainbackUIVIEW.backgroundColor = backColor
                        liberaryBTN.setTitleColor(backColor, for: .normal)
                        saveBtn.setTitleColor(backColor, for: .normal)
                        sharBtn.setTitleColor(backColor, for: .normal)
                        welomeLabel.textColor = backColor
            } catch { print(error) }
            
        }
            if let titleColorData = UserDefaults.standard.object(forKey: DefaultKeys.titlecolorKey) as? Data{
                do {
                    let titleColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: titleColorData)
                    
                        mainLBL.textColor = titleColor
                        liberaryBTN.backgroundColor = titleColor
                        saveBtn.backgroundColor = titleColor
                        sharBtn.backgroundColor = titleColor
                        livePhotoView.backgroundColor = titleColor
                        
                } catch { print(error) }
            }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                self.indicator.startAnimating()
                self.welomeLabel.isHidden = true
                self.loadVideoWithVideoURL(url)
            }
        }
    }
    
    
    
    func loadVideoWithVideoURL(_ videoURL: URL) {
        livePhotoView.livePhoto = nil
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        
        let secondrandom = Int.random(in: 0 ..< Int(durationTime))

        let time = NSValue(time: CMTimeMakeWithSeconds(Float64(secondrandom), preferredTimescale: asset.duration.timescale))
        generator.generateCGImagesAsynchronously(forTimes: [time]) { [weak self] _, image, _, _, _ in
            if let image = image, let data = UIImage(cgImage: image).pngData() {
                let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let imageURL = urls[0].appendingPathComponent("image.jpg")
                try? data.write(to: imageURL, options: [.atomic])
                
                let image = imageURL.path
                let mov = videoURL.path
                let output = FilePaths.VidToLive.livePath
                let assetIdentifier = UUID().uuidString
                let _ = try? FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true, attributes: nil)
                do {
                    try FileManager.default.removeItem(atPath: output + "IMG.JPG")
                    try FileManager.default.removeItem(atPath: output + "IMG.MOV")
                    
                } catch {
                    
                }
                JPEG(path: image).write(output + "/IMG.JPG",
                                        assetIdentifier: assetIdentifier)
                QuickTimeMov(path: mov).write(output + "/IMG.MOV",
                                              assetIdentifier: assetIdentifier)
                
                //self?.livePhotoView.livePhoto = LPDLivePhoto.livePhotoWithImageURL(NSURL(fileURLWithPath: FilePaths.VidToLive.livePath.stringByAppendingString("/IMG.JPG")), videoURL: NSURL(fileURLWithPath: FilePaths.VidToLive.livePath.stringByAppendingString("/IMG.MOV")))
                //self?.exportLivePhoto()
                _ = DispatchQueue.main.sync {
                    PHLivePhoto.request(withResourceFileURLs: [ URL(fileURLWithPath: FilePaths.VidToLive.livePath + "IMG.MOV"), URL(fileURLWithPath: FilePaths.VidToLive.livePath + "IMG.JPG")],
                                        placeholderImage: nil,
                                        targetSize: self!.view.bounds.size,
                                        contentMode: PHImageContentMode.aspectFit,
                                        resultHandler: { (livePhoto, info) -> Void in
                                            self?.livePhotoView.livePhoto = livePhoto
                                            //self?.exportLivePhoto()
                                            self?.saveBtn.isHidden = false
                                            self?.sharBtn.isHidden = false
                                            self?.indicator.stopAnimating()
                    })
                }
            }
        }
    }
    
    
    @IBAction func shareBTNAction(_ sender: Any) {
        if self.country != nil || self.country != ""{
            self.setlocationpermission()
        }
        
         self.uploadwallpaper(categoryid: "13")
//        let catarra = UserDefaults.standard.array(forKey:  DefaultKeys.categoriesKey) as! [Dictionary<String, String>]
//
//        categoryArray.append(categorylistObject(id: "13", Name: "User Submitted"))
//        categoryArray.append(categorylistObject(id: "14", Name: "Popular"))
//        categoryArray.append(categorylistObject(id: "15", Name: "New"))
//        for item in catarra {
//            categoryArray.append(categorylistObject(id: "\(item["cat_id"] ?? "")", Name: item["cat_name"] ?? ""))
//        }
//
//        self.showAsAlertController(style: .actionSheet, title: "Select category", action: "Cancel", height: nil)

        
    }
    
   
    
    func exportLivePhoto () {
        PHPhotoLibrary.shared().performChanges({ () -> Void in
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            
            
            creationRequest.addResource(with: PHAssetResourceType.pairedVideo, fileURL: URL(fileURLWithPath: FilePaths.VidToLive.livePath + "IMG.MOV"), options: options)
            creationRequest.addResource(with: PHAssetResourceType.photo, fileURL: URL(fileURLWithPath: FilePaths.VidToLive.livePath + "IMG.JPG"), options: options)
            
        }, completionHandler: { (success, error) -> Void in
            if !success {
               // DTLog((error?.localizedDescription)!)
                
                DispatchQueue.main.async {
                    self.saveIndicator.stopAnimating()
                    self.saveBtn.isHidden = false
                    self.sharBtn.isHidden = false
                }
            }
            else {
                DispatchQueue.main.async {
                    self.saveIndicator.stopAnimating()
                }
                
               
            }
        })
    }
    
    
    
    @IBAction func cameraBtnAction(_ sender: Any) {
        if let obj = UserDefaults.standard.object(forKey: DefaultKeys.userdataKey) as? Dictionary<String,Any> {
            
            
            if (AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined || AVCaptureDevice.authorizationStatus(for: .video) == .authorized) {
                   let picker = UIImagePickerController()
                   picker.delegate = self
                   picker.sourceType = .camera
                   picker.mediaTypes = [kUTTypeMovie as String]
                   present(picker, animated: true, completion: nil)
                   }
                   else {
                       DispatchQueue.main.async {
                           self.welomeLabel.text = "Please allow access to Camera and Photos to be able to create your wallpapers"
                       }
                   }
        }
        else
        {
            Common.showAlert(with: "Please Login Account", message: "", for: self)
        }
    }
    @IBAction func libraryBtnAction(_ sender: Any) {
         if let obj = UserDefaults.standard.object(forKey: DefaultKeys.userdataKey) as? Dictionary<String,Any> {
           
                if (AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined || AVCaptureDevice.authorizationStatus(for: .video) == .authorized) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary
                picker.mediaTypes = [kUTTypeMovie as String]
                present(picker, animated: true, completion: nil)
                }
                else {
                    DispatchQueue.main.async {
                        self.welomeLabel.text = "Please allow access to Camera and Photos to be able to create your wallpapers"
                    }
                }
        }
        else
        {
            Common.showAlert(with: "Please Login Account", message: "", for: self)
        }
        
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        managePhotoPermissions()
    }
    
    func savePhoto() {
//        self.saveBtn.isHidden = ÏÏtrue
        self.saveIndicator.startAnimating()
        self.exportLivePhoto()
    }
    
    func displayPaymentView() {

        DispatchQueue.main.async {
//            self.performSegue(withIdentifier: "purchaseUpload", sender: self)
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        
    }
    
    func managePhotoPermissions() {

        let photoPerm = PHPhotoLibrary.authorizationStatus()

        if (photoPerm == .notDetermined) {

            PHPhotoLibrary.requestAuthorization({(status) in
                if status == .authorized {
                    if Api().checkProFlag() == false {
                        self.displayPaymentView()
                        self.savePhoto()
                    }
                    else {
                        self.savePhoto()
                    }
                }
                else {
                    self.displayPermissionsWarning()
                }
            })
        }

        else if (photoPerm == .authorized) {
            if Api().checkProFlag() == false {
                self.displayPaymentView()
                self.savePhoto()
            }
            else {
                self.savePhoto()
            }
        }

        else {
            displayPermissionsWarning()
        }
    }
   
    func displayPermissionsWarning() {
        let alertControl = UIAlertController.init(title: "Permission Denied", message: "Walley needs photos permission in order to save your wallpapers! There's no where else to save them :(", preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in
            
        })
        alertControl.addAction(alertAction)
        self.present(alertControl, animated: true, completion: nil)
    }
   
}

// MARK: APIs
extension WallpaperMaker {
    fileprivate func uploadwallpaper(categoryid:String) {
        
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        
        UserDefaults.standard.set(true, forKey: "uploadimg") //Bool
        
        let u_id = UserDefaults.standard.string(forKey: "U_id")
        print(u_id)
        
        var parameters: APIDict = [:]
        parameters["user_id"] = Common.getUserid()
        parameters["device_id"] = u_id
        
        if self.country != nil || self.country != ""{
            parameters["comment"] = "uploaded by \(Common.getUsername()) from \(city ?? ""), \(country ?? "")"
        }
        else
        {
             parameters["comment"] = "uploaded by \(Common.getUsername())"
        }
       
        parameters["cat_id"] = "\(categoryid)"
//        parameters["live_wallpaper"] = ""
//        parameters["wallpaper"] = ""
//        "uploaded by XXXX from Los Angeles, California"
//        URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.MOV"), options: options)
//        creationRequest.addResource(with: PHAssetResourceType.photo, fileURL: URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.JPG"), options: options)
        var parupArray = [Dictionary<String,Any>]()
        var dic = Dictionary<String,Any>()
        dic["fileurl"] = URL(fileURLWithPath: FilePaths.VidToLive.livePath + "IMG.MOV")
        dic["uploadField"] = "live_wallpaper"
        dic["uploadAs"] = "prmovie.mov"
        dic["mimeType"] = "video/quicktime"
        
        parupArray.append(dic)
        
        dic = Dictionary<String,Any>()
        dic["fileurl"] = URL(fileURLWithPath: FilePaths.VidToLive.livePath + "IMG.JPG")
        dic["uploadField"] = "wallpaper"
        dic["uploadAs"] = "primage.jpg"
        dic["mimeType"] = "image/jpeg"
        
        parupArray.append(dic)

        LambdaManager.shared.CallUplaod_MOV_IMG_Api(configs.user_upload_wallpaper, parupArray, parameters){ (data, header, statusCode, error) in
            guard let json = data else { return }
            if json.safeBool("success") {
               Common.showToast(with: "Upload Successful")
            }
            else
            {
                Common.showToast(with: "\(json["message"] ?? "")")
               
            }
           
        }
    }
}

extension WallpaperMaker:CLLocationManagerDelegate
{
    func setlocationpermission() {
        let authStatus = CLLocationManager.authorizationStatus()
         if authStatus == .notDetermined {
             locationManager.requestWhenInUseAuthorization()
         }

         if authStatus == .denied || authStatus == .restricted {
             // add any alert or inform the user to to enable location services
            let alert = UIAlertController(title: "Allow Location Access", message: "MyApp needs access to your location. Turn on Location Services in your device settings.", preferredStyle: UIAlertController.Style.alert)

            // Button to Open Settings
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
         }

        // here you can call the start location function
        startLocationManager()
    }
    func startLocationManager() {
        // always good habit to check if locationServicesEnabled
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.startUpdatingLocation()
//        }
        
        if CLLocationManager.locationServicesEnabled()
        {
           
            self.locationManager.delegate = self
            self.locationManager.distanceFilter = kCLDistanceFilterNone
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

            let authorizationStatus = CLLocationManager.authorizationStatus()
            if (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways)
            {
                self.locationManager.startUpdatingLocation()
            }
            else if (locationManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)))
            {
                 self.locationManager.startUpdatingLocation()
            }
            else
            {
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func stopLocationManager() {
       locationManager.stopUpdatingLocation()
       locationManager.delegate = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // print the error to see what went wrong
        print("didFailwithError\(error)")
        // stop location manager if failed
        stopLocationManager()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){        // if you need to get latest data you can get locations.last to check it if the device has been moved
        let latestLocation = locations.last!

        // here check if no need to continue just return still in the same place
        if latestLocation.horizontalAccuracy < 0 {
            return
        }
        location = locations[0]
        // if it location is nil or it has been moved
        if location != nil {

            
            // stop location manager
            stopLocationManager()

            // Here is the place you want to start reverseGeocoding
            geocoder.reverseGeocodeLocation(location!, completionHandler: { (placemarks, error) in
                    // always good to check if no error
                    // also we have to unwrap the placemark because it's optional
                    // I have done all in a single if but you check them separately
                    if error == nil, let placemark = placemarks, !placemark.isEmpty {
                        self.placemark = placemark.last
                    }
                    // a new function where you start to parse placemarks to get the information you need
                    self.parsePlacemarks()

               })
        }
    }
    
    func parsePlacemarks() {
       // here we check if location manager is not nil using a _ wild card
       if let _ = location {
            // unwrap the placemark
            if let placemark = placemark {
                // wow now you can get the city name. remember that apple refers to city name as locality not city
                // again we have to unwrap the locality remember optionalllls also some times there is no text so we check that it should not be empty
                if let city = placemark.locality, !city.isEmpty {
                    // here you have the city name
                    // assign city name to our iVar
                    self.city = city
                }
                // the same story optionalllls also they are not empty
                if let country = placemark.country, !country.isEmpty {

                    self.country = country
                }
                // get the country short name which is called isoCountryCode
                if let countryShortName = placemark.isoCountryCode, !countryShortName.isEmpty {

                    self.countryShortName = countryShortName
                }
                
                self.stopLocationManager()
            }


        } else {
           // add some more check's if for some reason location manager is nil
        }

    }
    
    
    // MARK:- Alert or Actionsheet - You can also provide buttons as needed
       
    func showAsAlertController(style: UIAlertController.Style, title: String?, action: String?, height: Double?) {
        var selectionStyle: SelectionStyle = style == .alert ? .single : .multiple
            selectionStyle = .single
           // create menu
           let selectionMenu =  RSSelectionMenu(selectionStyle: selectionStyle, dataSource: categoryArray) { (cell, name, indexPath) in
                cell.textLabel?.text = name.Name
           }
           
           // provide selected items
//           selectionMenu.setSelectedItems(items: simpleSelectedArray) { (text, index, isSelected, selectedItems) in
//           }
           
           // on dismiss handler
           selectionMenu.onDismiss = { items in
               
//            self.simpleSelectedArray = items
            
           
            if items.count > 0 {
                if self.country != nil || self.country != ""{
                    self.setlocationpermission()
                }
                self.uploadwallpaper(categoryid: items[0].id)
            }
           }
           
           // cell selection style
//        selectionMenu.cellSelectionStyle = .tickmark
           
           // show - with action (if provided)
           let menuStyle: PresentationStyle = style == .alert ? .alert(title: title, action: action, height: height) : .actionSheet(title: title, action: action, height: height)
           
           selectionMenu.show(style: menuStyle, from: self)
       }
    
   
}
