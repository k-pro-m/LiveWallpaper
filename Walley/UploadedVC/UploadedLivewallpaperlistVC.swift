//
//  UploadedLivewallpaperlistVC.swift
//  Walley
//
//  Created by Milan Patel on 12/10/19.
//  Copyright © 2019 Bashar Madi. All rights reserved.
//

import UIKit
import SDWebImage
import OneSignal

protocol UploadedLiveWallpaperDelegate {
    func onSelectedItem(data: Dictionary<String,String>)
}

class UploadedLivewallpaperlistVC: UIViewController {
    @IBOutlet var mainUIVIEW: UIView!
    @IBOutlet var mainLBL: UILabel!
    @IBOutlet var collectionview: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var delegate: UploadedLiveWallpaperDelegate?
    var isSelectionMode = false
    
    var start = 0
    let count = 19
    var globalData:Array<Any> = []
    var selectedImage = Dictionary<String,String>()
    var dataArray:[Dictionary<String,String>] = []
    var liveThumb:UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionview.dataSource = self
        self.collectionview.delegate = self
//        self.implementLayout()
        setcolor()
        getuserlivewallpaperlist()
    }
    

    @IBAction func backBTNwasPressed(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func setcolor() {
        if let backColorData = UserDefaults.standard.object(forKey: DefaultKeys.backcolorKey) as? Data {
            
            do {
                let backColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: backColorData)
                
                   mainUIVIEW.backgroundColor = backColor
                } catch { print(error) }
        }
        if let titleColorData = UserDefaults.standard.object(forKey: DefaultKeys.titlecolorKey) as? Data
        {
            do {
            let titleColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: titleColorData)
            
               mainLBL.textColor = titleColor
            } catch { print(error) }
        }
            
        }
    
    
   

}
// MARK: APIs
extension UploadedLivewallpaperlistVC {
    fileprivate func getuserlivewallpaperlist() {
        
        self.dataArray.removeAll()
        start = 0
        DispatchQueue.main.async {
            self.collectionview.reloadData()
            self.collectionview.isHidden = true
            self.activityIndicator.startAnimating()
        }
        let user_id = UserDefaults.standard.string(forKey: "U_id")
        print(user_id)
        
        var parameters: APIDict = [:]
        parameters["user_id"] = Common.getUserid()
        parameters["cat_id"] = ""
//        parameters["device_id"] = user_id
       
        LambdaManager.shared.CallApi(configs.user_uploaded_wallpaper, parameters) { (data, header, statusCode, error) in
            guard let json = data else { return }
            if json.safeBool("success") {
               
                
                let dataDict:Array<Any> = json["data_user_wallpaper"] as! Array<Any>
                self.globalData = dataDict
                self.didReceiveCategory(data: dataDict, category: "")
                
            }
            else
            {
                Common.showToast(with: "\(json["message"] ?? "")")
            }
        }
    }
    
    func didReceiveCategory(data:Array<Any>, category:String) {
        let tempArray = data as! [Dictionary<String,String>]
//        for i in start ... start+count {
        for i in 0 ... tempArray.count {
            if (i < tempArray.count) {
            dataArray.append(tempArray[i])
            }
            else {
                break
            }
        }
        DispatchQueue.main.async {
            self.collectionview.reloadData()
            self.activityIndicator.stopAnimating()
            self.collectionview.isHidden = false

        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offset = self.collectionview.contentOffset.y
//        let height = self.collectionview.contentSize.height
//        if offset > height - scrollView.frame.size.height && height > 0 && dataArray.count != 0 {
//            start = start + 20
//            self.didReceiveCategory(data: globalData, category: "")
//        }
//    }
}


extension UploadedLivewallpaperlistVC:UICollectionViewDelegate,UICollectionViewDataSource
{
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return dataArray.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell:customCell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbCell", for: indexPath) as! customCell
    //        let fileName = dataArray[indexPath.item]["thumb"]!
    //        let title = dataArray[indexPath.item]["title"]!
           
            
            //"\(urlApi)thumbs/live/\(title)/Image.jpg"
            if let imagePath = dataArray[indexPath.item]["thumb"] {
                let NimagePath = imagePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                let imageUrl:URL = URL(string: NimagePath)!
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
            }
            
            
           return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if self.isSelectionMode {
                let controller = UIAlertController(title: "Confirm", message: "Are you sure you want to add this wallpaper to the contest?", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    print(self.dataArray[indexPath.row])
                    self.delegate?.onSelectedItem(data: self.dataArray[indexPath.row])
                    self.navigationController?.popViewController(animated: true)
                }))
                controller.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                }))
                self.present(controller, animated: true, completion: nil)
            } else {
                self.selectedImage = dataArray[indexPath.item]
                let cell = self.collectionview.cellForItem(at: indexPath) as! customCell
                if cell.imageView.image != nil {
                    self.liveThumb = cell.imageView.image!
                }
                //               self.performSegue(withIdentifier: "showLive", sender: self)
                self.pushlivewallpaper()
            }
        }
   
        
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = UIScreen.main.bounds.size.width;
            let size = CGSize(width: width/2.2, height: (width/2.2)/0.55)
            return size
        }
        
        func implementLayout() {
            let layout:UICollectionViewFlowLayout = self.collectionview.collectionViewLayout as! UICollectionViewFlowLayout
            layout.minimumInteritemSpacing = 0.0
            layout.minimumLineSpacing = 15.0
            layout.sectionInset = UIEdgeInsets.init(top: 10.0, left: 10.0, bottom: 0, right: 10.0)
            self.collectionview.collectionViewLayout.invalidateLayout()
            DispatchQueue.main.async {
                self.collectionview.reloadData()
            }
        }
    
    func pushlivewallpaper() {
        if self.liveThumb != nil
        {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let destination = storyBoard.instantiateViewController(withIdentifier: "LiveViewController") as! LiveViewController
            destination.mainimageDic = self.selectedImage
            destination.placeHolderImage = self.liveThumb!
            self.navigationController?.pushViewController(destination, animated: true)
//            let destination:LiveViewController = segue.destination as! LiveViewController
            
        }
    }
    

}
