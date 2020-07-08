//
//  FullImageViewController.swift
//  Walley
//
//  Created by Bashar Madi on 9/1/17.
//  Copyright © 2017 Bashar Madi. All rights reserved.
//


import UIKit
import SDWebImage
import Photos
import GoogleMobileAds
import Firebase


class FullImageViewController: UIViewController, GADInterstitialDelegate, GADRewardBasedVideoAdDelegate {

let api = Api()
var imagePath = ""
var lockedStatus = ""
var premiumStat = ""
var interstitial:GADInterstitial!
var rewarded = false
var videoAdLoading = true
var proFlag:Bool?
    
    @IBOutlet var mainbackUIVIEW: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successTitle: UILabel!
    @IBOutlet weak var successSub: UILabel!
    @IBOutlet weak var successBtn: UIButton!
    @IBOutlet weak var purchaseView: UIView!
    @IBOutlet weak var purchaseBtn: UIButton!
   
    @IBOutlet weak var purchaseViewCloseBtn: UIButton!
    //@IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var lockedView: UIView!
    @IBOutlet weak var getPremiumBtn: UIButton!
    
    @IBOutlet weak var lockedCloseBtn: UIButton!
     @IBOutlet weak var infoBtn: UIButton!
    
    
    
    
    override func viewDidLoad() {
      super.viewDidLoad()
        self.setImageLowQ()
        self.proFlag = api.checkProFlag()
        if (!self.proFlag!) {
        let request = GADRequest()
       
      GADRewardBasedVideoAd.sharedInstance().load(request, withAdUnitID: "")
        GADRewardBasedVideoAd.sharedInstance().delegate = self
      
      
        self.interstitial = self.loadInterstitialAd()
        
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        super.viewWillAppear(animated)
       
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    func setImageLowQ() {
        var path = "\(urlApi)thumbs/\(imagePath)"
        path = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let lowQImageURL = URL(string: path)
//        self.mainImageView.sd_setImage(with: lowQImageURL, completed: nil)
        self.mainImageView.sd_setImage(with: lowQImageURL, completed: {
            (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
            if error != nil
            {
                print("=======================url==============================\(imageURL)")
            }
        })
        //self.loadingView.isHidden = false
        self.downloadHQImage()
    }
    
    func downloadHQImage() {
        let api = Api()
        self.saveBtn.isEnabled = false
        
        let HQFileName:String = imagePath.replacingOccurrences(of: ".jpg", with: "_iphone6plus.jpg")
        var HQpath = "\(urlApi)walls/\(HQFileName)"
        HQpath = HQpath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
       
        let HQURL = URL(string: HQpath)
        api.downloadHQImage(url: HQURL, completion: {
            (image) in
            DispatchQueue.main.async {
                if (image?.size != nil) {
                self.mainImageView.image = image
                self.activityIndicator.stopAnimating()
                self.infoBtn.isHidden = false
                self.saveBtn.isEnabled = true
               
                }
                else {
                    self.mainImageView.backgroundColor = UIColor.black
                }
            }
            
        })
                
    }
    
    func managePhotoPermissions() {
        let photoPerm = PHPhotoLibrary.authorizationStatus()
        if (photoPerm == .notDetermined) {
            PHPhotoLibrary.requestAuthorization({(status) in
               
                if status == .authorized {
                    if !self.proFlag! {
                  self.loadVideoRewardAd()
                    }
                    else {
                      self.savingMechanism()
                    }
                    
                }
                else {
                   self.displayPermissionsWarning()
                }
            })
        }
        
        else if (photoPerm == .authorized) {
           if !self.proFlag! {
            self.loadVideoRewardAd()
            }
           else {
            self.savingMechanism()
            }
        }
            
        else {
            self.displayPermissionsWarning()
        }
    }
    
    
    func displayPermissionsWarning() {
        let alertControl = UIAlertController.init(title: "Permission Denied", message: "Walley needs photos permission in order to save your wallpapers! There's no where else to save them :(", preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in
            
        })
        alertControl.addAction(alertAction)
        self.present(alertControl, animated: true, completion: nil)
    }
    
    func savingMechanism() {
        let deltaX = 52
        let deltaY = 128
        let newImage = self.imageScaledToSize(size: CGSize.init(width: self.mainImageView.frame.size.width + CGFloat(deltaX), height: self.mainImageView.frame.size.height + CGFloat(deltaY)), image: self.mainImageView.image!)
        let frame = CGRect(x: 0, y: 0, width: self.mainImageView.frame.size.width + CGFloat(deltaX), height: self.mainImageView.frame.size.height + CGFloat(deltaY))
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        newImage.draw(in: frame)
        let imageToSave = UIGraphicsGetImageFromCurrentImageContext()
        UIImageWriteToSavedPhotosAlbum(imageToSave!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    
    func imageScaledToSize(size:CGSize, image:UIImage) -> UIImage {
        var oldRatio = 0.0
        var newRatio = 0.0
        var containerRatio = 0.0
        var scaledSize = CGSize.zero
        var diffX = 0.0
        var diffY = 0.0
        
        scaledSize.width = size.width
        scaledSize.height = size.height
        oldRatio = Double(image.size.width/image.size.height)
        containerRatio = Double(scaledSize.width/scaledSize.height)
        newRatio = Double(size.width/size.height)
        
        if (oldRatio < containerRatio && image.size.width != image.size.height) {
            oldRatio = Double(image.size.height/image.size.width)
            newRatio = Double(scaledSize.height/scaledSize.width)
            let correction = CGFloat(oldRatio/newRatio)
            scaledSize.height = scaledSize.height * correction
            diffY = Double(Swift.abs(size.height - scaledSize.height))
            diffY = diffY * (-1)
            diffY = diffY/2
            diffX = 0
            
        }
        else {
            let correction = CGFloat(oldRatio/newRatio)
            scaledSize.width = scaledSize.width * correction
            diffX = Double(Swift.abs(size.width - scaledSize.width))
            diffX = diffX * (-1)
            diffX = diffX/2
            diffY = 0
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let frame = CGRect(x: CGFloat(diffX), y: CGFloat(diffY), width: scaledSize.width, height: scaledSize.height)
        image.draw(in: frame)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return newImage!
        
    }
    
    @objc func image(_ image:UIImage, didFinishSavingWithError error:Error?, contextInfo:UnsafeRawPointer) {
       
        if let err = error {
            print(err.localizedDescription)
        }
        else {
            
            self.animateAlertViews(view: self.successView, action: "open")
        }
    }
    
    func animateAlertViews(view:UIView, action:String) {
        if action == "open" {
            view.isHidden = false
            self.blurView.alpha = 0.0
            self.blurView.isHidden = false
            view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 0)
            UIView.animate(withDuration: 0.5, animations: {
                self.blurView.alpha = 1.0
                view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 346.0)
            })

        }
        else if action == "close" {
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
    
    func loadInterstitialAd() -> GADInterstitial {
        let inter = GADInterstitial(adUnitID: "ca-app-pub-3383891844202178/8382510645")
        inter.delegate = self
        inter.load(GADRequest())
        return inter
    }
    func loadVideoRewardAd() {
        if (GADRewardBasedVideoAd.sharedInstance().isReady) {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        }
        else if (self.interstitial.isReady) {
            self.interstitial.present(fromRootViewController: self)
            Analytics.logEvent("interstitialSHOWADS", parameters: [
                "interstitial": "ads"
                ])
            self.savingMechanism()
        }
        else {
            self.savingMechanism()
        }
            
        
    }
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.interstitial = self.loadInterstitialAd()
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        rewarded = true
        self.savingMechanism()
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        let request = GADRequest()
        GADRewardBasedVideoAd.sharedInstance().load(request, withAdUnitID: "")
        
        if (!rewarded) {
        self.videoAdLoading = true
        self.animateAlertViews(view: self.lockedView, action: "open")
        self.successView.isHidden = true
        }
       
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        self.videoAdLoading = false
        rewarded = true
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        self.videoAdLoading = false
    }
    
    @IBAction func saveBtnAction(_ sender: UIButton) {
       
            
            self.managePhotoPermissions()
        
    }
   
    @IBAction func lockedCloseBtnAction(_ sender: UIButton) {
       self.animateAlertViews(view: self.lockedView, action: "close")
    }
    
    @IBAction func getPremiumBtnAction(_ sender: UIButton) {
        self.getPremiumBtn.setTitle("Loading...", for: UIControl.State.normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            if (GADRewardBasedVideoAd.sharedInstance().isReady) {
                GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
            }
            else {
                self.savingMechanism()
            }
            self.getPremiumBtn.setTitle("Ok, I'll Watch it!", for: UIControl.State.normal)
            self.animateAlertViews(view: self.lockedView, action: "close")
         })
        
    }
    
    @IBAction func successBtnAction(_ sender: UIButton) {
        self.animateAlertViews(view: self.successView, action: "close")
        SKStoreReviewController.requestReview()
        
    }
    
    @IBAction func purchaseBtnAction(_ sender: UIButton) {
    }
    @IBAction func purchaseViewCloseBtn(_ sender: UIButton) {
    
        self.animateAlertViews(view: self.purchaseView, action: "close")
        self.purchaseView.frame = CGRect(x: self.purchaseView.frame.origin.x, y: self.purchaseView.frame.origin.y, width: self.purchaseView.frame.size.width, height: 346.0)
        
    }
    @IBAction func infoBtnAction(_ sender: Any) {
        
    }
    
    
}
