//
//  Api.swift
//  Walley
//
//  Created by Bashar Madi on 8/23/17.
//  Copyright © 2017 Bashar Madi. All rights reserved.
//

import Foundation
import UIKit
let urlApi = "http://livewallpapershd.com/livewallpapersandhdthemes/"
//"http://192.168.1.8/livewallpapersandhdthemes/"
//"https://s3.eu-north-1.amazonaws.com/livewallpapersandhdthemes/"

class Api {
let userDefaults = UserDefaults.standard
    
init() {
        
}
    
    
    public func getCategory(category:String, start:Int, count:Int, completion:@escaping (Array<Any>,Int,Int) -> Void) {
        let path = "\(urlApi)Categories/\(category).json"
        let pathUrl:URL = URL(string: path)!
        let request = URLRequest(url: pathUrl)
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringCacheData
        config.urlCache = nil
        let session = URLSession.init(configuration: config)
        let task = session.dataTask(with: request, completionHandler: {(data,response,error) in
            
            do {
                if let dataSet = data {
                guard let json = try JSONSerialization.jsonObject(with: dataSet, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject] else {
                    print("error parsing json")
                    return
                }
                let dataDict:Array<Any> = json["data"] as! Array<Any>
                completion(dataDict,start,start+count)
             }
            }
            catch {
                print("error")
                return
            }
            
            
        })
        
        
        task.resume()
        
    }
    
    public func downloadHQImage(url:URL?, completion:@escaping (UIImage?) -> Void) {
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {
            (data,response,error) in
            if (error == nil) {
            let image = UIImage(data: data!)
            completion(image)
            }
        })
        task.resume()
    }
    
    
    public func getPhoneModel() -> String {
        var phoneModel = ""
        let screenHeight = UIScreen.main.bounds.size.height
        switch screenHeight {
        case 568:
            phoneModel = "se"
        case 667:
            phoneModel = "iphone6"
        case 736:
            phoneModel = "iphone6plus"
        default:
            phoneModel = "iphone6"
        }
        return phoneModel
    }
    
    public func checkProFlag() -> Bool {
        var proFlag:Bool?
        if let proStatus = self.userDefaults.value(forKey: "proFlag") {
            proFlag = proStatus as? Bool
        }
        else {
            self.userDefaults.set(false, forKey: "proFlag")
            proFlag = false
        }
        
        return proFlag!
    }
    
    public func setProFlag(state:Bool) {
        self.userDefaults.set(state, forKey: "proFlag")
    }
    
   
    
}
