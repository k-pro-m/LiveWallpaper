//
//  ContestTabViewController.swift
//  Walley
//
//  Created by Naveed Ahmed on 18/02/2020.
//  Copyright © 2020 Bashar Madi. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMobileAds
import FirebaseAnalytics
import OneSignal

class ContestTabViewController: UIViewController, GADInterstitialDelegate {

    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var contestTitleText: UILabel!
    @IBOutlet weak var contestDescriptionText: UILabel!
    @IBOutlet weak var contestStartDateText: UILabel!
    @IBOutlet weak var contestEndDateText: UILabel!
    @IBOutlet weak var contestPrizeText: UILabel!
    
    let api = Api()
    var interstitial:GADInterstitial!
    var bannerView:GADBannerView!
    var selectedCategoryId: String?
    var proFlag:Bool?
    var start = 0
    let count = 19
    var liveThumb:UIImage?
    var selectedImage = Dictionary<String,String>()
    var globalData:Array<Any> = []
    var dataArray:[Dictionary<String,String>] = []
    var selectedCategory = Dictionary<String,String>()
    var categoryArray:[Dictionary<String,String>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.proFlag = api.checkProFlag()
        self.detailCollectionView.delegate = self
        self.detailCollectionView.dataSource = self
        implementLayout()
        getContestWallpapers()
        getContestDetails()
        if !self.proFlag! {
            self.interstitial = self.loadInterstitialAd()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(afterPurchaseAction), name: NSNotification.Name(rawValue: "afterPurchaseNotif"), object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
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
        if self.liveThumb != nil {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let destination = storyBoard.instantiateViewController(withIdentifier: "LiveViewController") as! LiveViewController
            destination.placeHolderImage = self.liveThumb!
            destination.mainimageDic = self.selectedImage
            destination.selectedCategory = "\(self.selectedCategory["cat_id"] ?? "")"
            self.navigationController?.pushViewController(destination, animated: true)
            //            let destination:LiveViewController = segue.destination as! LiveViewController
            
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
        if user_id == "0" {
            let alert = UIAlertController(title: "Alert", message: "please first Login", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else{
            let next = self.storyboard?.instantiateViewController(withIdentifier: "CommentsView") as! Comments
            self.present(next, animated: true, completion: nil)
            
        }
    }
    
    func addWallpaperToContest(_ id: String) {
        var parameters: APIDict = [:]
        parameters["im_ti_id"] = id
        LambdaManager.shared.CallApi(configs.addWallpaperToContest, parameters) { (data, header, statusCode, error) in
            guard let json = data else { return }
            if let value = json["msg"] as? String, value.lowercased() == "duplicated" {
                let controller = UIAlertController(title: "Oops", message: "Seems like you've already added this wallpaper to the contest", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(controller, animated: true, completion: nil)
            } else {
                let controller = UIAlertController(title: "Success", message: "Successfully Added Wallpaper to Contest", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                   self.getContestWallpapers()
                }))
                self.present(controller, animated: true, completion: nil)
            }
            
        }
    }

    func getContestWallpapers() {
        var parameters: APIDict = [:]
        LambdaManager.shared.CallApi(configs.GetContestWallpapers, parameters) { (data, header, statusCode, error) in
            guard let json = data else { return }
            if json.safeBool("success") {
                let categoryId = String(json["category_id"] as! Int)
                self.selectedCategoryId = categoryId
                let dataDict:Array<Any> = json["data"] as! Array<Any>
                for item in dataDict {
                    let dict = item as! Dictionary<String, String>
                    self.dataArray.append(dict)
                }
                self.detailCollectionView.reloadData()
            }
            
        }
    }
    
    func getContestDetails() {
        let parameters: APIDict = [:]
        LambdaManager.shared.CallApi(configs.GetContestDetails, parameters) { (data, header, statusCode, error) in
            guard let json = data else { return }
            if let detail = json["detail"] as? Dictionary<String,String> {
                self.contestTitleText.text = detail["contest_name"]
                self.contestDescriptionText.text = detail["contest_description"]
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let startDate = formatter.date(from: detail["start_date"] ?? "2020-01-01 00:00:00")!
                let endDate = formatter.date(from: detail["end_date"] ?? "2020-01-01 00:00:00")!
                
                formatter.dateFormat = "MMM dd, yyyy"
                
                self.contestStartDateText.text = "Start Date: " + formatter.string(from: startDate)
                self.contestEndDateText.text = "End Date: " + formatter.string(from: endDate)
                self.contestPrizeText.text = "Winning Prize: $" + (detail["prize"] ?? "0")
                
            }
        }
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "UploadedLivewallpaperlistVC") as! UploadedLivewallpaperlistVC
        vc.delegate = self
        vc.isSelectionMode = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ContestTabViewController: UploadedLiveWallpaperDelegate {
    func onSelectedItem(data: Dictionary<String, String>) {
        if let id = data["im_ti_id"] {
            self.addWallpaperToContest(id)
        }
    }
}

extension ContestTabViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCell
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
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    }
    
    @objc func btnLikeDidClicked(sender:UIButton) {
        let imageTitleId = dataArray[sender.tag]["im_ti_id"]!
        var isLike = dataArray[sender.tag]["is_like"]!
        if isLike == "0" {
            isLike = "1"
        } else {
            isLike = "0"
        }
        let parameters: APIDict = ["cat_id":self.selectedCategoryId ?? "",
            "im_ti_id":imageTitleId,
            "is_like":isLike,
            "user_id":Common.getUserid(),
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

}
