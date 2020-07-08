//
//  ViewController.swift
//  Walley
//
//  Created by Bashar Madi on 8/21/17.
//  Copyright © 2017 Bashar Madi. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMobileAds
import AVFoundation
import Firebase
import PopupDialog
import OneSignal
import Alamofire


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, GADInterstitialDelegate, UICollectionViewDelegateFlowLayout {
let api = Api()
var start = 0
let count = 19
var globalData:Array<Any> = []
//var unlockedData:Array<String> = []
var selectedImage = Dictionary<String,String>()
var lockedStatus = ""
var liveThumb:UIImage?
var selectedCategory = ""
var tempCategory = ""
var bannerView:GADBannerView!
var interstitial:GADInterstitial!
let storage = UserDefaults.standard
var proFlag:Bool?
let remoteConfig = RemoteConfig.remoteConfig()
//var ischeckrewardvideo = false
    
// Timer
var countingTimer: Timer?
var tickCount = 0
let tickRate = 1.0
let totalTicks = 180                        // Delay time second
var progressIncrement: Float = 0.0
var selectedCategoryId = "14"
    
    @IBOutlet var mainbackUIVIEW: UIView!
    @IBOutlet var toptabbarUIVIEW: UIView!
    @IBOutlet var maintitleLBL: UILabel!
    
    
    
@IBOutlet weak var freeBtn: UIButton!
@IBOutlet weak var newBtn: UIButton!
@IBOutlet weak var popularBtn: UIButton!
@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
//@IBOutlet weak var menuBtn: UIButton!
@IBOutlet weak var headerLabel: UILabel!
//@IBOutlet weak var embedView: UIView!    
@IBOutlet weak var collectionView: UICollectionView!
@IBOutlet var categoryRecognizer: UITapGestureRecognizer!
@IBAction func unwindToMain(segue:UIStoryboardSegue) {
        
}

    var dataArray:[Dictionary<String,String>] = []
    
    
    
    // add Comment count
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        
                let hasPrompted = status.permissionStatus.hasPrompted
                print("hasPrompted = \(hasPrompted)")
                let userStatus = status.permissionStatus.status
                print("userStatus = \(userStatus)")
        
                let isSubscribed = status.subscriptionStatus.subscribed
                print("isSubscribed = \(isSubscribed)")
                let userSubscriptionSetting = status.subscriptionStatus.userSubscriptionSetting
                print("userSubscriptionSetting = \(userSubscriptionSetting)")
                let userID = status.subscriptionStatus.userId
                print("userID = \(String(describing: userID))")
                let pushToken = status.subscriptionStatus.pushToken
                print("pushToken = \(String(describing: pushToken))")
        
        UserDefaults.standard.set(userID, forKey: "U_id")
        UserDefaults.standard.set(pushToken, forKey: "push_token")
        
        
        
//        if let valArray = UserDefaults.standard.object(forKey: DefaultKeys.unlockedArraylistKey) {
//            let arrlist = valArray as! Array<String>
//            unlockedData = arrlist
//        }
        
        
        self.proFlag = api.checkProFlag()
        self.setupRemoteConfig()
        if !self.proFlag! {
       // self.loadBannerAd()
        self.interstitial = self.loadInterstitialAd()
//            self.loadrewardads()
        }
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
//        self.selectedCategory = "live-popular"
       
//         self.selectedCategory = "14"
//        self.getCategory(category: "14", categoryName: "Popular")
        self.implementLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(categorySelectListener(_:)), name: Notification.Name(rawValue:"categorySelectNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(afterPurchaseAction), name: NSNotification.Name(rawValue: "afterPurchaseNotif"), object: nil)
        
        popularBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        
        startTimer()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.getCategory(category: "14", categoryName: "Popular")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
       // self.getCategory(category: "14", categoryName: "Popular")
        super.viewWillAppear(animated)
        setcolor()
  
        
        if UserDefaults.standard.bool(forKey: "uploadimg") != nil
        {
        
        if UserDefaults.standard.bool(forKey: "uploadimg") {
            if popularBtn.isSelected {
                self.popularBtnAction(self)
            } else if freeBtn.isSelected {
                self.freeBtnAction(self)
            } else if newBtn.isSelected {
                self.newBtnAction(self)
            }
           // UserDefaults.standard.set(false, forKey: "uploadimg")
        }
        else
        {
             self.popularBtnAction(self)
        }
        }
        else
        {
            self.popularBtnAction(self)
        }
//        UIApplication.shared.isStatusBarHidden = false
//        UIApplication.shared.statusBarStyle = .default
       
    }
    
    
    
    
    
    override var prefersStatusBarHidden: Bool
    {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        if #available(iOS 13.0, *) {
            return .lightContent
        } else {
            return .lightContent
        }
    }
    
    func setcolor() {
        
        if let backColorData = UserDefaults.standard.object(forKey: DefaultKeys.backcolorKey) as? Data {
            
            do {
                let backColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backColorData)
               
                mainbackUIVIEW.backgroundColor = backColor
                toptabbarUIVIEW.backgroundColor = backColor
//                print(records)
                
                if let titleColorData = UserDefaults.standard.object(forKey: DefaultKeys.titlecolorKey) as? Data {
                    let titleColor =  try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: titleColorData)
                        maintitleLBL.textColor = titleColor
                        newBtn.setTitleColor(titleColor, for: .normal)
                        freeBtn.setTitleColor(titleColor, for: .normal)
                        popularBtn.setTitleColor(titleColor, for: .normal)
                }
                
            } catch { print(error) }
           
        }
        
    }
    //Purchase Button Dialog
    
    @IBAction func BtnPurchaseopenVCAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
//        (nextViewController, animated:true)
//        self.present(nextViewController, animated:true)
    }
    //Popup Dialog
    
    @IBAction func showPurchaseDialog() {
        
        let alertControl = UIAlertController(title: "Claim Your $6.99 credit today!", message: "Try premium membership for a free 3-Day Trial", preferredStyle: .alert)
        
        let bonusAction = UIAlertAction(title: "Claim Your Bonus", style: .default, handler: {(action) in
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)

//            self.present(nextViewController, animated:true)
        })
        
        let noAction = UIAlertAction(title: "No, Thanks", style: .default, handler: {(action) in
            
        })
        alertControl.addAction(bonusAction)
        alertControl.addAction(noAction)
        tickCount = 1
        self.present(alertControl, animated: true, completion: nil)
    }

    // Timer On
    @IBAction func startTimer() {
        
        // Create and configure the timer for 1.0 second ticks.
        countingTimer = Timer.scheduledTimer(timeInterval: tickRate, target: self, selector: #selector(onTimerTick), userInfo: "Tick: ", repeats: true)
        
        // Helps UI stay responsive even with timer.
        RunLoop.current.add(countingTimer!, forMode: RunLoop.Mode.common)
        
    }
    
    // Real Timer
    @objc func onTimerTick(timer: Timer) -> Void {
        
        if tickCount >= totalTicks {
            if proFlag == false {
                
                var subIsActive:Bool?
                if let sub = UserDefaults.standard.value(forKey: "subIsActive") {
                    subIsActive = sub as? Bool
                }
                if subIsActive == false {
                    if UIApplication.topViewController()!.isKind(of: UIAlertController.self) {
                        print("UIAlertController is presented")
                    }
                    else
                    {
                         showPurchaseDialog()
                    }
                   
                }
            }
        }
        else {
            tickCount += 1
        }
        
    } // end func onTimerTick
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:customCell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbCell", for: indexPath) as! customCell
//        let fileName = dataArray[indexPath.item]["thumb"]!
//        let title = dataArray[indexPath.item]["title"]!
        cell.lockedIMGVIEW.isHidden = true
        
        //"\(urlApi)thumbs/live/\(title)/Image.jpg"
        if let imagePath = dataArray[indexPath.item]["thumb"] {
            let NimagePath = imagePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let imageUrl:URL = URL(string: NimagePath)!
            cell.imageView.sd_setImage(with: imageUrl)
//            cell.imageView.sd_setImage(with: imageUrl, completed: {
//            (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
//                if error != nil
//                {
//                    print("url==============================\(String(describing: imageURL))")
//                }
                UIView.animate(withDuration: 0.3, animations: {
                    cell.imageView.alpha = 1.0

                })
//
//
//                })
            cell.lockedIMGVIEW.isHidden = true
            var isLike = dataArray[indexPath.item]["is_like"]!
            if isLike == "0" {
                cell.btnLike.setImage(UIImage(named: "ic_unlike"), for: .normal)
            } else {
                cell.btnLike.setImage(UIImage(named: "ic_like"), for: .normal)
            }
            cell.btnLike.addTarget(self, action: #selector(btnLikeDidClicked(sender:)), for: .touchUpInside)
            cell.btnLike.tag = indexPath.item
            cell.CommentCount.text = dataArray[indexPath.item]["comment_count"] 
            cell.Comment.addTarget(self, action: #selector(comments_View(sender:)), for: .touchUpInside)
            cell.Comment.tag = indexPath.item
            if let likeCount = dataArray[indexPath.item]["like_count"] {
                cell.lblLikeCount.text = likeCount
            }
//            if !self.proFlag! {
//                if dataArray[indexPath.item]["locked"] == "1" {
//                    cell.lockedIMGVIEW.isHidden = false
//                }
//                else
//                {
//                    cell.lockedIMGVIEW.isHidden = true
//                }
//
//                if unlockedData.contains(dataArray[indexPath.item]["im_ti_id"] ?? "") {
//                    cell.lockedIMGVIEW.isHidden = true
//                }
//            }
        }
        
        
       return cell
    }
    
    @objc func btnLikeDidClicked(sender:UIButton) {
        let imageTitleId = dataArray[sender.tag]["im_ti_id"]!
        var isLike = dataArray[sender.tag]["is_like"]!
        if isLike == "0" {
            isLike = "1"
        } else {
            isLike = "0"
        }
        let parameters: APIDict = ["cat_id":selectedCategoryId,
                                   "im_ti_id":imageTitleId,
                                   "user_id":Common.getUserid(),
                                  // "is_like":isLike,
                                   "device_id":OneSignal.app_id()]
        LambdaManager.shared.CallApi(configs.imageLike, parameters) { (data, header, statusCode, error) in
            guard let json = data else { return }
            if json.safeBool("success") {
                self.dataArray[sender.tag]["like_count"] = "\(json["like_count"]!)"
                self.dataArray[sender.tag]["is_like"] = "\(json["is_like"]!)"
                self.collectionView.reloadItems(at: [IndexPath(item: sender.tag, section: 0)])
              //  self.getCategory(category: self.selectedCategoryId, categoryName: self.selectedCategory)
            }
            
        }
    }
    
    /*func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = self.collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "collectionHeader", for: indexPath)
        headerView.frame.size.height = 200
        headerView.backgroundColor = UIColor.white
        let path = Bundle.main.url(forResource: "Image", withExtension: "mov")
        let player = AVPlayer(url: path!)
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        player.rate = 0.50
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 9, y: 0.0, width: headerView.bounds.width - 18.0, height: headerView.bounds.height)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.cornerRadius = 13.0
        playerLayer.masksToBounds = true
        headerView.layer.addSublayer(playerLayer)
        player.play()
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidEndPlaying(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        let taprecognizer = UITapGestureRecognizer(target: self, action: #selector(tapRecognizerAction(_:)))
        let label = UILabel(frame: CGRect(x: 0, y: headerView.bounds.height/2 - 25, width: headerView.bounds.width, height: 50))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont(name: "HelveticaNeue-Thin", size: headerView.bounds.width * 0.1)
        label.text = "LIVE WALLPAPERS"
        headerView.addSubview(label)
       headerView.addGestureRecognizer(taprecognizer)
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var size = CGSize.zero
        if self.selectedCategory != "live" {
            size = CGSize(width: self.view.bounds.width, height: 200)
        }
        return size
    }*/
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        self.selectedImage = dataArray[indexPath.item]
              let cell = self.collectionView.cellForItem(at: indexPath) as! customCell
              if cell.imageView.image != nil {
                  self.liveThumb = cell.imageView.image!
              }
        
        if !self.proFlag! {
            if (self.interstitial.isReady && !self.remoteConfig["removeAds"].boolValue) {
                    self.interstitial.present(fromRootViewController: self)
                    Analytics.logEvent("interstitialSHOWADS", parameters: [
                                                   "interstitial": "ads"
                                                ])
                }
            else
            {
                self.pushlivewallpaper()
            }
        }
        else
        {
            self.pushlivewallpaper()
        }
      
        
//        self.performSegue(withIdentifier: "showLive", sender: self)
//         if !self.proFlag! {
//            if dataArray[indexPath.item]["locked"] == "1" {
//                        if unlockedData.contains(dataArray[indexPath.item]["im_ti_id"] ?? "") {
//            //                show direct
//            //                unlock video
//
//                            if !self.proFlag! {
//                                if (self.interstitial.isReady && !self.remoteConfig["removeAds"].boolValue) {
//                                        self.interstitial.present(fromRootViewController: self)
//                                        Analytics.logEvent("id-interstitial", parameters: [
//                                                                       "interstitial": "ads"
//                                                                    ])
//                                    }
//                            }
//                            self.selectedImage = dataArray[indexPath.item]
//                            let cell = self.collectionView.cellForItem(at: indexPath) as! customCell
//                            if cell.imageView.image != nil {
//                                self.liveThumb = cell.imageView.image!
//                            }
//
//                            self.performSegue(withIdentifier: "showLive", sender: self)
//
//                        }
//                        else
//                        {
//            //                locked
//
//
//                           self.selectedImage = dataArray[indexPath.item]
//                            let cell = self.collectionView.cellForItem(at: indexPath) as! customCell
//                            if cell.imageView.image != nil {
//                                self.liveThumb = cell.imageView.image!
//
//                                RewardView_Add_View()
//                            }
//                        }
//                    }
//                    else
//                    {
//                        if !self.proFlag! {
//                            if (self.interstitial.isReady && !self.remoteConfig["removeAds"].boolValue) {
//                                self.interstitial.present(fromRootViewController: self)
//                                Analytics.logEvent("id-interstitial", parameters: ["interstitial": "ads"])
//                                }
//                            }
//                            self.selectedImage = dataArray[indexPath.item]
//                            let cell = self.collectionView.cellForItem(at: indexPath) as! customCell
//                            if cell.imageView.image != nil {
//                                self.liveThumb = cell.imageView.image!
//                            }
//
//
//                            self.performSegue(withIdentifier: "showLive", sender: self)
//                    }
//        }
//        else
//         {
//
//
//            self.selectedImage = dataArray[indexPath.item]
//            let cell = self.collectionView.cellForItem(at: indexPath) as! customCell
//            if cell.imageView.image != nil {
//                self.liveThumb = cell.imageView.image!
//            }
//
//            self.performSegue(withIdentifier: "showLive", sender: self)
//        }
        
                   
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.size.width;
        let size = CGSize(width: width/2.2, height: (width/2.2)/0.55)
        return size
    }
    
    func implementLayout() {
        let layout:UICollectionViewFlowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 15.0
        layout.sectionInset = UIEdgeInsets.init(top: 10.0, left: 10.0, bottom: 0, right: 10.0)
        self.collectionView.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func didReceiveCategory(data:Array<Any>, category:String) {
        let tempArray = data as! [Dictionary<String,String>]
        for i in 0 ... tempArray.count {
            if (i < tempArray.count) {
            dataArray.append(tempArray[i])
            }
            else {
                break
            }
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
            self.collectionView.isHidden = false
            self.popularBtn.isEnabled = true
            self.newBtn.isEnabled = true
            self.freeBtn.isEnabled = true

        }
    }
    
//   func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offset = self.collectionView.contentOffset.y
//        let height = self.collectionView.contentSize.height
//        if offset > height - scrollView.frame.size.height && height > 0 && dataArray.count != 0 {
//            start = start + 20
//            self.didReceiveCategory(data: globalData, category: self.selectedCategory)
//        }
//    }
    
    func getCategory(category:String, categoryName:String) {
        self.selectedCategory = category
        self.dataArray.removeAll()
        start = 0
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.isHidden = true
            self.activityIndicator.startAnimating()
        }
       // self.headerLabel.text = categoryName
//        api.getCategory(category: category, start: 0, count: 20, completion: {
//            (data,first,end) in
//            self.globalData = data
//            self.didReceiveCategory(data: data, category: category)
//
//        })
        var parameters: APIDict = [:]
        
        if Common.getUserid() == nil {
            parameters["user_id"] = "0"
        }
        else{
            parameters["user_id"] = Common.getUserid()
        }
        
        
        parameters["cat_id"] = "\(category)"
        parameters["device_id"] = OneSignal.app_id()
        LambdaManager.shared.CallApi(configs.GetListOfCategoriesImage, parameters) { (data, header, statusCode, error) in
            guard let json = data else { return }
            if json.safeBool("success") {
                self.dismiss(animated: true, completion: nil)
                let dataDict:Array<Any> = json["data"] as! Array<Any>
                self.globalData = dataDict
                self.didReceiveCategory(data: dataDict, category: category)
//                Common.showToast(with: "\(json["message"] ?? "")")
            }
            else
            {
                Common.showToast(with: "\(json["message"] ?? "")")
                
            }
        }
            

    }
    
    @objc func categorySelectListener(_ notification:Notification) {
        if let category = notification.userInfo?["category"] {
           let categoryName = notification.userInfo?["categoryName"]
            self.selectedCategory = category as! String
            self.dataArray.removeAll()
            start = 0
            self.getCategory(category: category as! String, categoryName: categoryName as! String)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.collectionView.isHidden = true
                self.activityIndicator.startAnimating()
            }
            //UIView.animate(withDuration: 0.5, animations: {
                //self.embedView.frame = CGRect(x: 0, y: (-1)*self.embedView.frame.size.height, width: self.embedView.frame.size.width, height: self.embedView.frame.height)
          //  })
           
        }
    }
    
    func loadBannerAd() {
            self.bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            self.bannerView.frame = CGRect(x: 0, y: self.view.frame.size.height - self.bannerView.frame.size.height, width: self.bannerView.frame.size.width, height: self.bannerView.frame.size.height)
            self.view.addSubview(self.bannerView)
            self.bannerView.adUnitID = "ca-app-pub-3383891844202178/6600431787"
            self.bannerView.rootViewController = self
            self.bannerView.load(GADRequest())
            Analytics.logEvent("BannerSHOWADS", parameters: [
            "Banner": "ads"
            ])

    }
    
    func loadInterstitialAd() -> GADInterstitial {
        var inter = GADInterstitial(adUnitID: "ca-app-pub-3383891844202178/8382510645")
        inter.delegate = self
        inter.load(GADRequest())
        return inter
    }
   
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.interstitial = self.loadInterstitialAd()
//        self.performSegue(withIdentifier: "showLive", sender: self)
        self.pushlivewallpaper()
    }
    
    func itemDidEndPlaying(notification:Notification) {
        let player:AVPlayerItem = notification.object as! AVPlayerItem
        player.seek(to: CMTime.zero)
    }
    
    @objc func afterPurchaseAction() {
        self.proFlag = api.checkProFlag()
        if (self.bannerView != nil) {
            self.bannerView.removeFromSuperview()
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    @IBAction func menuBtnAction(_ sender: UIButton) {
        /*let yOrigin = self.embedView.frame.origin.y
        
        if (yOrigin < 0) {
        self.tempCategory = self.headerLabel.text!
        //self.headerLabel.text = "Categories"
        UIView.animate(withDuration: 0.3, animations: {
            self.embedView.frame = CGRect(x: 0, y: 0, width: self.embedView.frame.size.width, height: self.view.frame.height)
          })
        }
        else {
            self.headerLabel.text = self.tempCategory
            UIView.animate(withDuration: 0.3, animations: {
                self.embedView.frame = CGRect(x: 0, y: (-1)*self.embedView.frame.size.height, width: self.embedView.frame.size.width, height: self.embedView.frame.height)
            })

        }*/
     
    }
    
    @IBAction func tapRecognizerAction(_ sender:Any) {
        let categoryDict:Dictionary = ["category":"live","categoryName":"Live"]
        NotificationCenter.default.post(name: Notification.Name(rawValue:"categorySelectNotification"), object: nil, userInfo: categoryDict)
    }
    
    @IBAction func categoryRecognizerAction(_ sender: Any) {
        
    }

    @IBAction func popularBtnAction(_ sender: Any) {
        selectedCategoryId = "14"
        UserDefaults.standard.set(true, forKey: "uploadimg")
      //  UserDefaults.standard.set("\(selectedCategoryId)", forKey: "Sam")
    
        
        popularBtn.isSelected = true
        newBtn.isSelected = false
        freeBtn.isSelected = false
        newBtn.isEnabled = false
        freeBtn.isEnabled = false
        self.getCategory(category: "14", categoryName: "Popular")
    }
    
    @IBAction func newBtnAction(_ sender: Any) {
        selectedCategoryId = "15"
        UserDefaults.standard.set(true, forKey: "uploadimg")

       // UserDefaults.standard.set("\(selectedCategoryId)", forKey: "Sam")
        popularBtn.isSelected = false
        newBtn.isSelected = true
        freeBtn.isSelected = false
        popularBtn.isEnabled = false
        freeBtn.isEnabled = false
        self.getCategory(category: "15", categoryName: "New")
      
    }
    
    @IBAction func freeBtnAction(_ sender: Any) {
        selectedCategoryId = "13"
        UserDefaults.standard.set(true, forKey: "uploadimg")
        // UserDefaults.standard.set("\(selectedCategoryId)", forKey: "Sam")
        popularBtn.isSelected = false
        newBtn.isSelected = false
        freeBtn.isSelected = true
        newBtn.isEnabled = false
        popularBtn.isEnabled = false
        self.getCategory(category: "13", categoryName: "User Submitted")
        
    }
    
    
    
    func setupRemoteConfig(){
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled:false)
        self.remoteConfig.configSettings = remoteConfigSettings
        self.remoteConfig.setDefaults(fromPlist: "config")
        self.remoteConfig.fetch(completionHandler: {(status,error)
            in
            if status == .success {
                self.remoteConfig.activateFetched()
                self.freeBtn.isHidden = self.remoteConfig["freeBtnHide"].boolValue
                if self.remoteConfig["offerOnStart"].boolValue == true && !self.proFlag! {
//                    self.performSegue(withIdentifier: "offerOnStartSegue", sender: self)
                    self.BtnPurchaseopenVCAction(self)
                }
            }
        })
    }
    
     func pushlivewallpaper() {
            if self.liveThumb != nil
            {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let destination = storyBoard.instantiateViewController(withIdentifier: "LiveViewController") as! LiveViewController
               destination.mainimageDic = self.selectedImage
                destination.placeHolderImage = self.liveThumb!
                destination.selectedCategory = self.selectedCategory
                self.navigationController?.pushViewController(destination, animated: true)
    //            let destination:LiveViewController = segue.destination as! LiveViewController
                
            }
        }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showFullImage" {
//            let destination:FullImageViewController = segue.destination as! FullImageViewController
//            destination.imagePath = self.selectedImage
//
//        }
//        else
        if segue.identifier == "showLive" {
//            if self.liveThumb != nil
//            {
//                let destination:LiveViewController = segue.destination as! LiveViewController
//                destination.mainimageDic = self.selectedImage
//                destination.placeHolderImage = self.liveThumb!
//                destination.selectedCategory = self.selectedCategory
//            }
           
            
        }
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @objc func comments_View(sender:UIButton) {
        W_id=""
        W_id = dataArray[sender.tag]["im_ti_id"]!
        print(W_id)
        let user_id = Common.getUserid()
        if user_id == "0"
        {
            let alert = UIAlertController(title: "Alert", message: "please first Login", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let next = self.storyboard?.instantiateViewController(withIdentifier: "CommentsView") as! Comments
            self.present(next, animated: true, completion: nil)
//            self.performSegue(withIdentifier: "CommentsView", sender: self)
        }
        
    }
    

}

