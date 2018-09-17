
//
//  GistCommentsViewController.swift
//  QRCodeReader.swift
//
//  Created by Vivek on 16/09/18.

import UIKit
import Alamofire
import AlamofireImage
import AlamofireObjectMapper
class GistCommentsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate {
    @IBOutlet weak var tableview: UITableView!
    var commentsData = NSMutableArray()
    let cellReuseIdentifier = "cell"
    
    var GistID = NSString()

    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var textview: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getComments()
        self.tableview.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableview.delegate = self
        tableview.dataSource = self
        
        self.textview.layer.borderWidth = 1.0
        textview.layer.borderColor = UIColor.gray.cgColor
        

        
        textview.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(GistCommentsViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GistCommentsViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // Do any additional setup after loading the view.
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
           
                self.textview.frame.origin.y -= 190
          
            
           
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
          
                self.textview.frame.origin.y += 190
          
            
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getComments() {
   
        let Url: String = "https://api.github.com/gists/8a0c66db58d637291263b6820d28f25b/comments"
        Alamofire.request(Url, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                if let data = response.result.value{
                    // Response type-1
                    if  (data as? [[String : AnyObject]]) != nil{
                        print("data_1: \(data)")
                        for comments in data as! Array<AnyObject> {
                            let dict = comments as? NSDictionary
                            self.commentsData.addObjects(from: [dict as Any])
                            self.tableview.reloadData()
                        }
                    }
                }
        }
   
    }

    @IBAction func actionOnComment(_ sender: Any) {
         createComment()
    }
    func createComment() {
        
        let urlString = "https://api.github.com/gists/8a0c66db58d637291263b6820d28f25b/comments"
        Alamofire.request(urlString, method: .post, parameters: ["body":textview.text],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                print(response)
                break
            case .failure(let error):
                print(error)
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsData.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.tableview.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        let dataDic = self.commentsData[indexPath.row] as! NSDictionary
        let message = dataDic["body"] as? String
        cell.textLabel?.text = message
        return cell
    }
   
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}
