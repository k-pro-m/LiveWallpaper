//
//  CategoryViewController.swift
//  Walley
//
//  Created by Bashar Madi on 7/9/18.
//  Copyright © 2018 Bashar Madi. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMobileAds
import FirebaseAnalytics
import OneSignal


// Global variable for Wallpaper Id
var W_id = ""

class CategoryViewController:UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,GADInterstitialDelegate {
    
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var mainbackUIVIEW: UIView!
    @IBOutlet var mainLBL: UILabel!
    
    let api = Api()
    var interstitial:GADInterstitial!
    var bannerView:GADBannerView!
    var proFlag:Bool?
    var start = 0
    let count = 19
    var liveThumb:UIImage?
    var selectedImage = Dictionary<String,String>()
    var globalData:Array<Any> = []
    var dataArray:[Dictionary<String,String>] = []
    var selectedCategory = Dictionary<String,String>()
    var categoryArray:[Dictionary<String,String>] = []
//    var unlockedData:Array<String> = []
//    var ischeckrewardvideo = false

//    ["Abstract","Animals","Cities","Flowers","Mountains","Nature","Science","Sports","Underwater","Other"]
//    var categories = ["live-abstract","live-animals","live-cities","live-flowers","live-mountains","live-nature","live-science","live-sports","live-underwater","live-other"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let valArray = UserDefaults.standard.object(forKey: DefaultKeys.unlockedArraylistKey) {
//                   let arrlist = valArray as! Array<String>
//                   unlockedData = arrlist
//        }
        self.proFlag = api.checkProFlag()
//        self.selectedCategory = "live-abstract"
//        self.getCategory(category: "live-abstract", categoryName: "Abstract")
        implementLayout()
       
        if !self.proFlag! {
         //   self.loadBannerAd()
            self.interstitial = self.loadInterstitialAd()
//            self.loadrewardads()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(afterPurchaseAction), name: NSNotification.Name(rawValue: "afterPurchaseNotif"), object: nil)
       LoadCategoriesList()
       
    }
    override func viewWillAppear(_ animated: Bool) {
        LoadCategoriesList()
        super.viewWillAppear(animated)
         setcolor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        LoadCategoriesList()
    }
    override var prefersStatusBarHidden: Bool
    {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .default
    }
    func setcolor() {
        if let backColorData = UserDefaults.standard.object(forKey: DefaultKeys.backcolorKey) as? Data {
            
            do {
                let backColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backColorData)
                
                       mainbackUIVIEW.backgroundColor = backColor
            } catch { print(error) }
            
        }
            if let titleColorData = UserDefaults.standard.object(forKey: DefaultKeys.titlecolorKey) as? Data{
                do {
                    let titleColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: titleColorData)
                    
                        mainLBL.textColor = titleColor
                        
                } catch { print(error) }
            }
        
    }

    func LoadCategoriesList() {
        let catarra = UserDefaults.standard.array(forKey:  DefaultKeys.categoriesKey)
        if catarra != nil {
            
            categoryArray = catarra as! [Dictionary<String, String>]
            
            //                for item in catarra! {
            //                    let arr = item as! Dictionary<String, Any>
            //                       let catClass = categorylistClass()
            //                       catClass.cat_id = arr["cat_id"]
            //                       catClass.cat_name = arr["cat_name"]
            //
            //                   }
            DispatchQueue.main.async {
                self.categoryCollectionView.reloadData()
                if self.categoryArray.count > 0
                {
                    let cat = self.categoryArray[0]
                    self.NgetCategory(category: cat, categoryName: cat["cat_name"] ?? "")
                    self.categoryCollectionView.isUserInteractionEnabled = false
                    self.categoryCollectionView.selectItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
                }
            }
        }
        else
        {
            getcategoryList()
        }
    }
    func getcategoryList() {
                var parameters: APIDict = [:]
                parameters["user_id"] = "1"
        LambdaManager.shared.CallApi(configs.GetcategoryList, parameters) { (data, header, statusCode, error) in
                guard let json = data else { return }
                if json.safeBool("success") {
                    let dataDict:Array<Any> = json["data_category"] as! Array<Any>
                    UserDefaults.standard.set(dataDict, forKey: DefaultKeys.categoriesKey)
                    self.LoadCategoriesList()
                }
                    
            }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var size = 0
        if collectionView == self.categoryCollectionView {
            size = self.categoryArray.count
        }
        else {
           size =  self.dataArray.count
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCell
        
        if collectionView == self.categoryCollectionView {
            
            
            let cat = self.categoryArray[indexPath.item]
            
//            cell.imageView.image = UIImage(named: "\(cat["cat_name"] ?? "")")
            cell.titleLabel.text = cat["cat_name"]
            
            if let imagePath = cat["cat_image"] {
                let NimagePath = imagePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                let imageUrl:URL = URL(string: NimagePath)!
                 cell.imageView.sd_setImage(with: imageUrl)
//                cell.imageView.sd_setImage(with: imageUrl, completed: {
//                (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
//                    if error != nil
//                    {
//                        print("url==============================\(String(describing: imageURL))")
//                    }
//                })
            }
            
        }
        
        else {
//             let cell:customCell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbCell", for: indexPath) as! customCell
            
            if let imagePath = dataArray[indexPath.item]["thumb"] {
                let NimagePath = imagePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                let imageUrl:URL = URL(string: NimagePath)!
                cell.lockedIMGVIEW.isHidden = true
                cell.imageView.sd_setImage(with: imageUrl, completed: {
                (image:UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL?) in
                    if error != nil
                    {
                        print("url==============================\(String(describing: imageURL))")
                    }
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.imageView.alpha = 1.0
                       
                        })
                    
                        
                    })
                cell.lockedIMGVIEW.isHidden = true
                var isLike = dataArray[indexPath.item]["is_like"]!
                if isLike == "0" {
                    cell.btnLike.setImage(UIImage(named: "ic_unlike"), for: .normal)
                } else {
                    cell.btnLike.setImage(UIImage(named: "ic_like"), for: .normal)
                }
                cell.CommentCount.text = dataArray[indexPath.item]["comment_count"]
                cell.btnLike.addTarget(self, action: #selector(btnLikeDidClicked(sender:)), for: .touchUpInside)
                cell.btnLike.tag = indexPath.item
                
                cell.Comment.addTarget(self, action: #selector(show_comments(sender:)), for: .touchUpInside)
                cell.Comment.tag = indexPath.item
                
                if let likeCount = dataArray[indexPath.item]["like_count"] {
                    cell.lblLikeCount.text = likeCount
                }
//              if !self.proFlag! {
//                    if dataArray[indexPath.item]["locked"] == "1" {
//                            cell.lockedIMGVIEW.isHidden = false
//                        }
//                    else
//                        {
//                            cell.lockedIMGVIEW.isHidden = true
//                        }
//
//                    if unlockedData.contains(dataArray[indexPath.item]["im_ti_id"] ?? "") {
//                            cell.lockedIMGVIEW.isHidden = true
//                        }
//                }
//                else
//              {
//                    cell.lockedIMGVIEW.isHidden = true
//                }
            }
            
            
             
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
        let parameters: APIDict = ["cat_id":"\(self.selectedCategory["cat_id"] ?? "")",
                                   "im_ti_id":imageTitleId,
                                   "is_like":isLike,
                                   "user_id":"1",
                                   "device_id":OneSignal.app_id()]
        LambdaManager.shared.CallApi(configs.imageLike, parameters) { (data, header, statusCode, error) in
            guard let json = data else { return }
            if json.safeBool("success") {
                self.dataArray[sender.tag]["like_count"] = "\(json["like_count"]!)"
                self.dataArray[sender.tag]["is_like"] = "\(json["is_like"]!)"
                self.detailCollectionView.reloadItems(at: [IndexPath(item: sender.tag, section: 0)])
               // self.NgetCategory(category: self.selectedCategory, categoryName: "\(self.selectedCategory["cat_name"] ?? "")")
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.categoryCollectionView {
            let cat = self.categoryArray[indexPath.item]
            self.NgetCategory(category: cat, categoryName: cat["cat_name"] ?? "")
            self.categoryCollectionView.isUserInteractionEnabled = false
        }
        else {
            
            self.selectedImage = dataArray[indexPath.item]

            let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
            if cell.imageView.image != nil {
                self.liveThumb = cell.imageView.image!
            }
            
            if !self.proFlag! {
                if (self.interstitial.isReady) {
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

           
//            self.performSegue(withIdentifier: "showLiveCategory", sender: self)
            
//            if !self.proFlag! {
//                if dataArray[indexPath.item]["locked"] == "1" {
//                            if unlockedData.contains(dataArray[indexPath.item]["im_ti_id"] ?? "") {
//                //                show direct
//                //                unlock video
//
//                                if !self.proFlag! {
//                                    if (self.interstitial.isReady) {
//                                            self.interstitial.present(fromRootViewController: self)
//                                            Analytics.logEvent("id-interstitial", parameters: [
//                                                "interstitial": "ads"
//                                                ])
//
//                                        }
//                                    }
//
//                                    self.selectedImage = dataArray[indexPath.item]
//
//                                    let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
//                                    if cell.imageView.image != nil {
//                                        self.liveThumb = cell.imageView.image!
//                                    }
//                                    self.performSegue(withIdentifier: "showLiveCategory", sender: self)
//
//                            }
//                            else
//                            {
//                //                locked
//
//
//                               self.selectedImage = dataArray[indexPath.item]
//
//                               let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
//                               if cell.imageView.image != nil {
//                                   self.liveThumb = cell.imageView.image!
//                                    RewardView_Add_View()
//                                }
//                            }
//                        }
//                        else
//                        {
//                             if !self.proFlag! {
//                                if (self.interstitial.isReady) {
//                                        self.interstitial.present(fromRootViewController: self)
//                                        Analytics.logEvent("id-interstitial", parameters: [
//                                            "interstitial": "ads"
//                                            ])
//
//                                    }
//                                }
//
//                                self.selectedImage = dataArray[indexPath.item]
//
//                                let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
//                                if cell.imageView.image != nil {
//                                    self.liveThumb = cell.imageView.image!
//                                }
//                                self.performSegue(withIdentifier: "showLiveCategory", sender: self)
//                        }
//            }
//            else
//            {
//                self.selectedImage = dataArray[indexPath.item]
//
//                let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
//                if cell.imageView.image != nil {
//                    self.liveThumb = cell.imageView.image!
//                }
//                self.performSegue(withIdentifier: "showLiveCategory", sender: self)
//            }
//
//
        }
    }
    
    
    
    
    func NgetCategory(category:Dictionary<String,String>, categoryName:String) {
        self.selectedCategory = category
        self.dataArray.removeAll()
        start = 0
        DispatchQueue.main.async {
            self.detailCollectionView.reloadData()
            self.detailCollectionView.isHidden = true
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
        parameters["user_id"] = Common.getUserid()
                parameters["cat_id"] = "\(category["cat_id"] ?? "")"
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
    
    
    func didReceiveCategory(data:Array<Any>, category:Dictionary<String,String>) {
        let tempArray = data as! [Dictionary<String,String>]
        for i in start ... start+count {
            if (i < tempArray.count) {
                dataArray.append(tempArray[i])
            }
            else {
                break
            }
        }
        DispatchQueue.main.async {
            self.detailCollectionView.reloadData()
            self.activityIndicator.stopAnimating()
            self.detailCollectionView.isHidden = false
            self.categoryCollectionView.isUserInteractionEnabled = true
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size:CGSize?
        let width = UIScreen.main.bounds.size.width;
        if collectionView == self.detailCollectionView {
        size = CGSize(width: width/2.2, height: (width/2.2)/0.55)
            return size!
        }
        else {
            size = CGSize(width: width * 0.336, height: width * 0.288)
        }
      
        return size!
        
    }
    
    func implementLayout() {
        let layout:UICollectionViewFlowLayout = self.detailCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 15.0
        // layout.headerReferenceSize = CGSize(width: self.view.bounds.width, height: 200)
        layout.sectionInset = UIEdgeInsets.init(top: 10.0, left: 10.0, bottom: 0, right: 10.0)
        self.detailCollectionView.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async {
            self.detailCollectionView.reloadData()
        }
    }
    func pushlivewallpaper() {
               if self.liveThumb != nil
               {
                   let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                   let destination = storyBoard.instantiateViewController(withIdentifier: "LiveViewController") as! LiveViewController
                   destination.placeHolderImage = self.liveThumb!
                    destination.mainimageDic = self.selectedImage
                    destination.selectedCategory = "\(self.selectedCategory["cat_id"] ?? "")"
                   self.navigationController?.pushViewController(destination, animated: true)
       //            let destination:LiveViewController = segue.destination as! LiveViewController
                   
               }
           }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showLiveCategory") {
            if self.liveThumb != nil
            {
//                let destination:LiveViewController = segue.destination as! LiveViewController
////                destination.mainTitle = self.selectedImage
//                destination.placeHolderImage = self.liveThumb!
//                destination.mainimageDic = self.selectedImage
//                destination.selectedCategory = "\(self.selectedCategory["cat_id"] ?? "")"
                
            }
            
        }
    }
    
    func loadInterstitialAd() -> GADInterstitial {
        let inter = GADInterstitial(adUnitID: "ca-app-pub-3383891844202178/8382510645")
        inter.delegate = self
        inter.load(GADRequest())
        return inter
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.interstitial = self.loadInterstitialAd()
//        self.performSegue(withIdentifier: "showLiveCategory", sender: self)
        self.pushlivewallpaper()
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
    
    @objc func afterPurchaseAction() {
        self.proFlag = api.checkProFlag()
        if (self.bannerView != nil) {
            self.bannerView.removeFromSuperview()
        }
        
        DispatchQueue.main.async {
            self.detailCollectionView.reloadData()
        }
    }
    
  
    
    @objc func show_comments(sender:UIButton) {
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
            
        }
        }
        
        
        
    }
    
    
    

//extension CategoryViewController:GADRewardBasedVideoAdDelegate
//{
//    func loadrewardads() {
//           GADRewardBasedVideoAd.sharedInstance().delegate = self
//           GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
//               withAdUnitID: "ca-app-pub-3383891844202178/4648543482")
//        //"ca-app-pub-3940256099942544/1712485313")
//    }
//
//
//    func showRewardvideoAds() {
//        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
//          GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
//        }
//    }
//
//    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
//        didRewardUserWith reward: GADAdReward) {
//      print("Reward received with currency: \(reward.type), amount \(reward.amount).")
//    }
//
//    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
//      print("Reward based video ad is received.")
//    }
//
//    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
//      print("Opened reward based video ad.")
//    }
//
//    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
//      print("Reward based video ad started playing.")
//    }
//
//    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
//      print("Reward based video ad has completed.")
//
//        if let id = self.selectedImage["im_ti_id"]{
//            unlockedData.append(id)
//            UserDefaults.standard.set(unlockedData, forKey: DefaultKeys.unlockedArraylistKey)
//             ischeckrewardvideo = true
//        }
//        DispatchQueue.main.async {
//             self.detailCollectionView.reloadData()
//        }
//
//    }
//
//    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
//        print("Reward based video ad is closed.")
//        loadrewardads()
//        if ischeckrewardvideo {
//                 self.performSegue(withIdentifier: "showLiveCategory", sender: self)
//                  ischeckrewardvideo = false
//              }
//    }
//
//    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
//      print("Reward based video ad will leave application.")
//    }
//
//    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
//        didFailToLoadWithError error: Error) {
//      print("Reward based video ad failed to load.")
//    }
//}
//
//
//extension CategoryViewController:openwatchvideoVCDelegate
//{
//    func Open_rewardVideo_premiumview(isrewardviewopen: Bool) {
//        if isrewardviewopen
//        {
//            var noadsshow = true
//            if !self.proFlag! {
//                if (GADRewardBasedVideoAd.sharedInstance().isReady) {
//                    GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
//                    Analytics.logEvent("id-Rewardads", parameters: ["Rewardads": "ads"])
//                                    noadsshow = false
//                }
//                else
//                {
//                    if (self.interstitial.isReady) {
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
//                }
//                if noadsshow {
////                   self.performSegue(withIdentifier: "showLiveCategory", sender: self)
//                }
//
//        }
//        else
//        {
////            premiumscreenopen
//            RewardView_Remove_View()
//            DispatchQueue.main.async {
//                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
//                self.navigationController?.pushViewController(nextViewController, animated: true)
//            }
//        }
//    }
//
//    func backopenrewardvideoVIEW() {
//        RewardView_Remove_View()
//    }
//
//    func RewardView_Add_View() {
//
//        let openwatchVC = (self.storyboard?.instantiateViewController(withIdentifier: "openwatchvideoVC") as! openwatchvideoVC)
//        openwatchVC.openwatchvideoVCDelegate = self
//        openwatchVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//        openwatchVC.thumbimage = self.liveThumb!
//        openwatchVC.view.backgroundColor = UIColor.clear
//        self.navigationController!.pushViewController(openwatchVC, animated: true)
//
//    }
//    func RewardView_Remove_View() {
//       self.navigationController?.popViewController(animated: true)
//
//    }
//}
