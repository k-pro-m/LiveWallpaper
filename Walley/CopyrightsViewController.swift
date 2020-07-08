//
//  CopyrightsViewController.swift
//  Walley
//
//  Created by Bashar Madi on 11/7/17.
//  Copyright © 2017 Bashar Madi. All rights reserved.
//

import UIKit
import WebKit

class CopyrightsViewController:UIViewController,WKUIDelegate,WKNavigationDelegate {
    
    @IBOutlet weak var closeViewBtn: UIButton!
   // @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet var webview: WKWebView!
    
    @IBOutlet var mainbackUIVIEW: UIView!
    @IBOutlet var mainLBL: UILabel!

    var passurl : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.bodyLabel.sizeToFit()
        passurl = "\(urlApi)copyrights.html"
//        guard let url = URL(string: "\(urlApi)copyrights.html") else { return }
//        let request = URLRequest(url: url)
//
//
//        let webConfiguration = WKWebViewConfiguration()
//        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.webview.frame.size.height))
//        self.webview = WKWebView (frame: customFrame , configuration: webConfiguration)
//        webview.translatesAutoresizingMaskIntoConstraints = false
//        webview.topAnchor.constraint(equalTo: webview.topAnchor).isActive = true
//        webview.rightAnchor.constraint(equalTo: webview.rightAnchor).isActive = true
//        webview.leftAnchor.constraint(equalTo: webview.leftAnchor).isActive = true
//        webview.bottomAnchor.constraint(equalTo: webview.bottomAnchor).isActive = true
//        webview.heightAnchor.constraint(equalTo: webview.heightAnchor).isActive = true
//        webview.uiDelegate = self
//
//        //        let myURL = URL(string: htmlPath)
//        //        let myRequest = URLRequest(url: myURL!)
//        webview.load(request)
        
    
        loadwebview()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    @IBAction func closeViewBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadwebview() {
             if passurl != nil {
                 var url = URL(string: passurl.removingWhitespaces())
                 if url == nil {
                     url = URL(string: passurl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
                 }
                 if url != nil {
                     let requestObj = URLRequest(url: url!)
                     DispatchQueue.main.async {
                         self.webview.uiDelegate = self
                         self.webview.navigationDelegate = self
                         self.webview.load(requestObj)
                         self.view.sendSubviewToBack(self.webview)
                     }
                   
                 }
             }
             else
             {
 //                DispatchQueue.main.async {
 //                    self.dismiss(animated: true, completion: nil)
 //                }
                 
             }
             
         }
         
         func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
             print(error.localizedDescription)
             
         }
         func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
             print("Strat to load")
         }
         func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
             print("finish to load")
           
         }
         override func viewDidDisappear(_ animated: Bool) {
         }
 }
 extension String {
     func removingWhitespaces() -> String {
         return components(separatedBy: .whitespaces).joined()
     }
 }
