//
//  LiveViewController.swift
//  Walley
//
//  Created by Bashar Madi on 12/15/17.
//  Copyright © 2017 Bashar Madi. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import GoogleMobileAds
import Firebase

class LiveViewController:UIViewController {
 var mainimageDic = Dictionary<String,String>()
var proFlag:Bool?
let api = Api()
var selectedCategory = ""
var canDownloadThumbs = true
var placeHolderImage:UIImage?
var ischeckrewardvideo = false
    
var purchaseImgIdArray = [String]()
    
    
    @IBOutlet var mainbackUIVIEW: UIView!
    
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successBtn: UIButton!
    @IBOutlet weak var clockView: UIImageView!
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var placeHolderImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var downloadStatusView: UIView!
    @IBOutlet weak var dismissBtn: UIButton!
    
    var imgUrl:URL!
    var liveView = PHLivePhotoView()
    var vidUrl:URL!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let imgiddata = CoredataClass.sharedInstance.GetData_of_Purchase_Image_List_entity()
        for data in imgiddata {
            let id : String = (data.value(forKey: "imgid") ?? "") as! String
            purchaseImgIdArray.append(id)
        }

        
        self.proFlag = api.checkProFlag()
        if self.placeHolderImage != nil
        {
            self.placeHolderImageView.image = self.placeHolderImage!
        }
        
        liveView = PHLivePhotoView(frame: mainContainer.bounds)
        self.downloadBtn.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(afterPurchaseAction), name: NSNotification.Name(rawValue: "afterPurchaseNotif"), object: nil)
        self.downloadLivePhoto(res: "normal", completion: {(imageUrl,vidUrl)
                in
               print(imageUrl)
                print(vidUrl)
            
            LivePhoto.generate(from: imageUrl, videoURL: vidUrl, progress: { percent in }, completion: { livePhoto, resources in
                // Display the Live Photo in a PHLivePhotoView
//                livePhotoView.livePhoto = livePhoto
                // Or save the resources to the Photo library
//                LivePhoto.saveToLibrary(resources)
                
                
                
                self.liveView.livePhoto = livePhoto
                self.placeHolderImageView.isHidden = true
                self.mainContainer.addSubview(self.liveView)
                self.liveView.startPlayback(with: .full)
                self.activityIndicator.stopAnimating()
                self.mainContainer.bringSubviewToFront(self.helpView)
                self.mainContainer.bringSubviewToFront(self.clockView)
                self.animateHelpView()
                self.downloadBtn.isEnabled = true
                self.infoBtn.isHidden = false
            })
             if !self.proFlag! {
                self.loadrewardads()
            }
//                PHLivePhoto.request(withResourceFileURLs: [vidUrl,imageUrl], placeholderImage:nil, targetSize: CGSize.zero, contentMode: .aspectFill, resultHandler: { (livePhoto, infoDict)
//                    in
//                    liveView.livePhoto = livePhoto
//                    self.placeHolderImageView.isHidden = true
//                    self.mainContainer.addSubview(liveView)
//                    liveView.startPlayback(with: .full)
//                    self.activityIndicator.stopAnimating()
//                    self.mainContainer.bringSubviewToFront(self.helpView)
//                    self.mainContainer.bringSubviewToFront(self.clockView)
//                     self.animateHelpView()
//                    self.downloadBtn.isEnabled = true
//                    self.infoBtn.isHidden = false
//                    
//                })
                
            })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(afterPurchaseWallpaperPack), name: NSNotification.Name(rawValue: "afterPurchaseWallpaperPackNotif"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "afterPurchaseWallpaperPackNotif"), object: nil)
       
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
       
    
    
    func downloadLivePhoto(res:String, completion:@escaping(URL,URL)->Void) {
        var imgPath = "\(mainimageDic["thumb"] ?? "")"
        //"\(urlApi)thumbs/live/\(mainTitle)/Image.jpg"
        var vidPath = "\(mainimageDic["live_thumbs"] ?? "")"
        //"\(urlApi)liveThumbs/\(mainTitle)/Image.mov"
        if res == "normal" {
            imgPath = "\(mainimageDic["thumb"] ?? "")"
            //"\(urlApi)thumbs/live/\(mainTitle)/Image.jpg"
            vidPath = "\(mainimageDic["live_thumbs"] ?? "")"
//            "\(urlApi)liveThumbs/\(mainTitle)/Image.mov"
        }
        else if res == "high" {
            imgPath = "\(mainimageDic["walls_live"] ?? "")"//"\(urlApi)walls/live/\(mainTitle)/Image.jpg"
            vidPath = "\(mainimageDic["live_walls"] ?? "")"
            //"\(urlApi)liveWalls/\(mainTitle)/Image.mov"
        }
        imgPath = imgPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        vidPath = vidPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        imgUrl = URL(string:imgPath)
        vidUrl = URL(string: vidPath)
    
        let request = URLRequest(url: imgUrl)
        let vidRequest = URLRequest(url: vidUrl)
        let session = URLSession.shared
        let task = session.downloadTask(with: request, completionHandler: {(imgLocation,response,error)
            in
            if let imgLocation = imgLocation, error == nil {
                let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let destination = documentUrl!.appendingPathComponent("\(imgLocation.lastPathComponent).jpg")
                do {
                    try FileManager.default.copyItem(at: imgLocation, to: destination)
                    print(destination.absoluteURL)
                }
                catch (let writeError) {
                    print(writeError.localizedDescription)
                }
                let vidTask = session.downloadTask(with: vidRequest, completionHandler: {(vidLocation,resp,err)
                    in
                    if let vidLocation = vidLocation, err == nil {
                        let destinationVid = documentUrl!.appendingPathComponent("\(vidLocation.lastPathComponent).mov")
                        do {
                            try FileManager.default.copyItem(at: vidLocation, to: destinationVid)
                            print(destinationVid.absoluteURL)
                        }
                        catch (let writeError) {
                            print(writeError.localizedDescription)
                        }
                        
                        completion(destination,destinationVid)
                      
                    }
                    else {
                        print(err?.localizedDescription ?? "error")
                    }
                })
                vidTask.resume()
            }
            else {
                print (error?.localizedDescription ?? "error")
            }
        })
        task.resume()
    }
    
    
    func animateDownloadStatusView(op:String) {
        if op == "show" {
//            UIApplication.shared.isStatusBarHidden = true
            UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.statusBar

            self.downloadStatusView.isHidden = false
            self.mainContainer.bringSubviewToFront(self.downloadStatusView)
            self.downloadStatusView.frame = CGRect(x: self.downloadStatusView.frame.origin.x, y: self.downloadStatusView.frame.origin.y - self.downloadStatusView.frame.size.height, width: self.downloadStatusView.frame.size.width, height: self.downloadStatusView.frame.size.height)
            
            UIView.animate(withDuration: 0.5, animations: {
                if UIDevice().userInterfaceIdiom == .phone {
                    let height = UIScreen.main.nativeBounds.height
                    if height == 2436 {
                         self.downloadStatusView.frame = CGRect(x: self.downloadStatusView.frame.origin.x, y: 0, width: self.downloadStatusView.bounds.width, height: 99)
                    }
                    else {
                
                 self.downloadStatusView.frame = CGRect(x: self.downloadStatusView.frame.origin.x, y: 0, width: self.downloadStatusView.bounds.width, height: self.downloadStatusView.bounds.height)
                    }
                }
                
            })
            
        }
        else {
            UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.normal

//            UIApplication.shared.isStatusBarHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.downloadStatusView.frame = CGRect(x: self.downloadStatusView.frame.origin.x, y:  (-1) * self.downloadStatusView.bounds.height, width: self.downloadStatusView.bounds.width, height: self.downloadStatusView.bounds.height)
            }, completion: {(finished)
                in
                
                self.downloadStatusView.isHidden = true
            })
        }
    }
    
    @objc func afterPurchaseAction() {
        self.proFlag = api.checkProFlag()
        self.managePhotoPermissions()
    }
    
    
    func managePhotoPermissions() {
        let photoPerm = PHPhotoLibrary.authorizationStatus()
        if (photoPerm == .notDetermined) {
            PHPhotoLibrary.requestAuthorization({(status) in
                
                if status == .authorized {
                    
                    self.saveLivePhoto()
                    
                }
                else {
                    self.displayPermissionsWarning()
                }
            })
        }
            
        else if (photoPerm == .authorized) {
            
            self.saveLivePhoto()
        }
            
        else {
            self.displayPermissionsWarning()
        }
    }
    
    func animateHelpView() {
        UIView.animate(withDuration: 1.0, animations: {
            self.helpView.alpha = 1.0
        }, completion: {(finished) in
            UIView.animate(withDuration: 10, animations: {
                self.helpView.alpha = 0
            })
        })
    }
    func animateAlertViews(view:UIView, action:String) {
        if action == "open" {
            DispatchQueue.main.async {
                view.isHidden = false
                self.blurView.alpha = 0.0
                self.blurView.isHidden = false
                view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 0)
                UIView.animate(withDuration: 0.5, animations: {
                    self.blurView.alpha = 1.0
                    view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 346.0)
                })
            }
        }
        else if action == "close" {
            DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.blurView.alpha = 0.0
                view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 0)
            }, completion: {
                (finished) in
                self.blurView.isHidden = true
                view.isHidden = true
            })
            }
        }
    }
    
    func displayPermissionsWarning() {
        let alertControl = UIAlertController.init(title: "Permission Denied", message: "Walley needs photos permission in order to save your wallpapers! There's no where else to save them :(", preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in
            
        })
        alertControl.addAction(alertAction)
        self.present(alertControl, animated: true, completion: nil)
    }
    
    func saveLivePhoto() {
//        if self.proFlag! || self.selectedCategory == "13" {
            DispatchQueue.main.async {
                self.animateDownloadStatusView(op: "show")
            }
        
            self.downloadLivePhoto(res: "high", completion: {(imageUrl,vidUrl)
                in
                DispatchQueue.main.async {
                    self.downloadStatusView.isHidden = true
                    
                    self.placeHolderImageView.isHidden = true
                }
                    LivePhoto.saveToLibrary((imageUrl,vidUrl)) { (success) in
                        if (success) {
                            self.animateAlertViews(view: self.successView, action: "open")
                            }
                            else {
                                
                           
                            DispatchQueue.main.async {
                                let activityViewController = UIActivityViewController(activityItems: [self.liveView.livePhoto!,"click below to view and download this live wallpaper https://apps.apple.com/us/app/live-wallpapers-and-hd-themes/id1315773855"] , applicationActivities: nil)
                                if let popoverController = activityViewController.popoverPresentationController {
                                    popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                                  popoverController.sourceView = self.view
                                    popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                                }
                              self.present(activityViewController, animated: true, completion: nil)
                            }
//                                let alertController = UIAlertController(title: "Saving Failed", message: "Something went wrong, we couldn't save your wallpaper. Please try again later", preferredStyle: UIAlertController.Style.alert)
//                                let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
//                                alertController.addAction(action)
//                                self.present(alertController, animated: true, completion: nil)
                            }
                    }
//                }
//                    DispatchQueue.main.async {
//                        self.downloadStatusView.isHidden = true
//
//                        self.placeHolderImageView.isHidden = true
//                        //self.mainContainer.addSubview(liveView!)
//                        //liveView?.startPlayback(with: .full)
//                        PHPhotoLibrary.shared().performChanges({
//                            let request = PHAssetCreationRequest.forAsset()
//                            request.addResource(with: .photo, fileURL:imageUrl , options: nil)
//                            request.addResource(with: .pairedVideo, fileURL: vidUrl, options: nil)
//                        }, completionHandler: {(success,error) in
//                            if (success) {
//                               self.animateAlertViews(view: self.successView, action: "open")
//                            }
//                            else {
//                                let alertController = UIAlertController(title: "Saving Failed", message: "Something went wrong, we couldn't save your wallpaper. Please try again later", preferredStyle: UIAlertController.Style.alert)
//                                let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
//                                alertController.addAction(action)
//                                self.present(alertController, animated: true, completion: nil)
//                            }
//                        })
//                    }
                    
                
            })
            
            
            
//        }
//        else {
//            DispatchQueue.main.async {
////                self.performSegue(withIdentifier: "purchaseSegue", sender: self)
//
//                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
//                self.navigationController?.pushViewController(nextViewController, animated: true)
//            }
//
//        }
    }
    
    
    @IBAction func downloadBtnAction(_ sender: Any) {

         if !self.proFlag! {
            
            if purchaseImgIdArray.contains(mainimageDic["im_ti_id"]!) {
                self.managePhotoPermissions()
            }
            else
            {
                self.RewardView_Add_View()
            }
            
        }
        else
        {
            self.managePhotoPermissions()
        }
//        self.managePhotoPermissions()
    }
    
    @IBAction func successBtnAction(_ sender: Any) {
        self.animateAlertViews(view: self.successView, action: "close")
    }
    
    @IBAction func dismissBtnAction(_ sender: Any) {
//        self.presentingViewController?.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
 
    
}

extension LiveViewController:GADRewardBasedVideoAdDelegate
{
    func loadrewardads() {
           GADRewardBasedVideoAd.sharedInstance().delegate = self
           GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
               withAdUnitID: "ca-app-pub-3383891844202178/4648543482")
//            "ca-app-pub-3940256099942544/1712485313")
    }
   
    
    func showRewardvideoAds() {
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
          GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        }
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
        didRewardUserWith reward: GADAdReward) {
      print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }

    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
      print("Reward based video ad is received.")
    }

    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
      print("Opened reward based video ad.")
    }

    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
      print("Reward based video ad started playing.")
    }

    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
      print("Reward based video ad has completed.")
       
//        if let id = self.selectedImage["im_ti_id"]{
//            unlockedData.append(id)
//            UserDefaults.standard.set(unlockedData, forKey: DefaultKeys.unlockedArraylistKey)
            ischeckrewardvideo = true
//        }
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }
    }

    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
        loadrewardads()
        if ischeckrewardvideo {
//            self.performSegue(withIdentifier: "showLive", sender: self)
            self.managePhotoPermissions()
            ischeckrewardvideo = false
        }
    }

    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
      print("Reward based video ad will leave application.")
    }

    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
        didFailToLoadWithError error: Error) {
      print("Reward based video ad failed to load.")
    }
}


extension LiveViewController:openwatchvideoVCDelegate
{
    @objc func afterPurchaseWallpaperPack() {
        purchaseImgIdArray.append(mainimageDic["im_ti_id"]!)
        self.managePhotoPermissions()
        CoredataClass.sharedInstance.storevalues(imgid: mainimageDic["im_ti_id"] ?? "")
        //store core data for that wallpaper
    }
    
    func Open_PurchaseVideo(ispurchasePack: Bool) {
        if ispurchasePack
        {
            RewardView_Remove_View()
            let manager = ShopManager.sharedInstance
            manager.purchaseProduct(productId: Constants.perpiecewallpaper)
             
        }
    }
    
    func Open_rewardVideo_premiumview(isrewardviewopen: Bool) {
        if isrewardviewopen
        {
//            openrewardvideo
            RewardView_Remove_View()
            
            
//            var noadsshow = true
            if !self.proFlag! {
                if (GADRewardBasedVideoAd.sharedInstance().isReady) {
                    GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
                    Analytics.logEvent("RewardadsSHOWADS", parameters: ["Rewardads": "ads"])
//                                    noadsshow = false
                }
                else
                {
                    self.managePhotoPermissions()
                }
//                else
//                {
//                    if (self.interstitial.isReady && !self.remoteConfig["removeAds"].boolValue) {
//                            self.interstitial.present(fromRootViewController: self)
//                            Analytics.logEvent("id-interstitial", parameters: ["interstitial": "ads"])
//                            noadsshow = false
//                        }
//                        else
//                        {
//                            noadsshow = true
//                        }
//                    }
//
            }
            else
            {
                self.managePhotoPermissions()
            }
//                if noadsshow {
////                   self.performSegue(withIdentifier: "showLive", sender: self)
//                }
                            
        }
        else
        {
//            premiumscreenopen
            
            RewardView_Remove_View()
            DispatchQueue.main.async {
                 let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }
    }
    
    func backopenrewardvideoVIEW() {
        RewardView_Remove_View()
    }
    
    func RewardView_Add_View() {
        
        
        let openwatchVC = (self.storyboard?.instantiateViewController(withIdentifier: "openwatchvideoVC") as! openwatchvideoVC)
        openwatchVC.openwatchvideoVCDelegate = self
        openwatchVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        if self.placeHolderImage != nil
        {
            openwatchVC.thumbimage = self.placeHolderImage!
        }
        
        openwatchVC.view.backgroundColor = UIColor.clear
//        addChild(openwatchVC)
//        openwatchVC.view.frame = self.view.bounds
        
//        let navigationController = (self.storyboard?.instantiateViewController(withIdentifier: "navigation") as! UINavigationController)
        self.navigationController!.pushViewController(openwatchVC, animated: true)
//        self.present(navigationController, animated: true, completion: nil)
        
       // self.view.addSubview(openwatchVC.view)
        //openwatchVC.didMove(toParent: self)
    }
    func RewardView_Remove_View() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
