//
//  Comments.swift
//  Walley
//
//  Created by Muhammad Ahsan Riaz on 08/01/2020.
//  Copyright © 2020 Bashar Madi. All rights reserved.
//

import UIKit
import  Alamofire

class commentsdata {
    var u_name:String!
    var u_image:String!
    var u_comment_id: String!
    var u_parent_id:String!
    var u_comments:String!
    var u_comment_date: String!
    
    init(name:String,comments:String,image:String,date:String){
        
        u_name = name
        u_comments = comments 
        u_image = image
        u_comment_date = date
        
    }
}

class Comments: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var CommentTextField: UITextField!
    var data = [commentsdata]()

    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.CommentTextField.delegate = self 
        // comments placeholder color
        CommentTextField.attributedPlaceholder = NSAttributedString(string: "Write Comment",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        get_comments()
       
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentViewCell
        
        cell.userName.text = data[indexPath.row].u_name
        cell.userComment.text = data[indexPath.row].u_comments
        cell.userImage.image = UIImage(named:data[indexPath.row].u_image)
        cell.CommentDate.text = data[indexPath.row].u_comment_date
        
        
        
        return cell
    }
    
    @IBAction func closAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
       // self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func Comment_send(_ sender: Any) {
        
        if CommentTextField.text != ""
        {
            Add_comments()
        }
            else{
                let alert = UIAlertController(title: "Alert", message: "please Write Comment", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //textField code
        textField.resignFirstResponder()  //if desired
        Add_comments()
        return true
    }
    
    
    
    func get_comments() {
        
        let url = "http://livewallpapershd.com/livewallpapersandhdthemes/Api/get_comments_reply"

        let  parameters = ["im_ti_id":W_id]
        Alamofire.request(url, method: .post, parameters: parameters,encoding: URLEncoding.default)
            .responseJSON { response in
                print(response.result)
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let dta = value as! Dictionary<String, Any>
                        let cnt = dta["total_comments"] as! NSNumber
                        
                        if cnt == 0
                        {
                            
                        }
                        else
                        {
                        
                        let ct = dta["comments"] as! Array<Dictionary<String,Any>>
                        guard let cmnt = dta["comments"] as? Array<Dictionary<String, Any>> else{
                            print("No Comments")
                            return
                        }
                        for dic in cmnt
                        {
                            let vlu = dic as! NSDictionary
                            var nam = vlu["user_name"] as? String
                            if nam == nil
                           {
                            nam = "Web Comment"
                            }
                            self.data.append(commentsdata.init(name: nam as! String, comments: vlu["comment_text"] as! String, image: "AppIcon",date: vlu["comment_date"]as! String))
                        }
                        self.tableview.reloadData()
                            self.tableview.scrollTableViewToBottom(animated: true)
                        //self.tableview.scrollTableViewToBottom(animated: true)
                        print(cnt)
                      
                        print(value)
                        }
                    }
                case .failure(let error):
                    print(error)
                }


        }
        
    }
    
    
    func Add_comments() {
        
        let dateFormatter : DateFormatter = DateFormatter()
        //  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        
        let cmnt = CommentTextField.text
        let Dev_id = UserDefaults.standard.string(forKey: "U_id")
            
        let url = "http://livewallpapershd.com/livewallpapersandhdthemes/Api/Add_comments"
        let  parameters = ["im_ti_id":W_id,"comment_text":cmnt ?? "",
                           "device_id":Dev_id ?? "",
                           "parent_id":"0",
                           "user_id":Common.getUserid()] as [String : Any]
        print(parameters)
        Alamofire.request(url, method: .post, parameters: parameters,encoding: URLEncoding.default)
            .responseJSON { response in
                print(response.result)
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        DispatchQueue.main.async {
                            self.data.append(commentsdata.init(name: Common.getUsername() , comments: cmnt as! String, image: "AppIcon",date: dateString as! String))
                            self.tableview.reloadData()
                            self.tableview.scrollTableViewToBottom(animated: true)
                        }
                        
                      print(value)
                    }
                case .failure(let error):
                    print(error)
                }
                
                
        }
        CommentTextField.text = ""
        
        
        
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UITableView {
    func scrollTableViewToBottom(animated: Bool) {
        guard let dataSource = dataSource else { return }
        
        var lastSectionWithAtLeasOneElements = (dataSource.numberOfSections?(in: self) ?? 1) - 1
        
        while dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeasOneElements) < 1 {
            lastSectionWithAtLeasOneElements -= 1
        }
        
        let lastRow = dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeasOneElements) - 1
        
        guard lastSectionWithAtLeasOneElements > -1 && lastRow > -1 else { return }
        
        let bottomIndex = IndexPath(item: lastRow, section: lastSectionWithAtLeasOneElements)
        scrollToRow(at: bottomIndex, at: .bottom, animated: animated)
    }
}
