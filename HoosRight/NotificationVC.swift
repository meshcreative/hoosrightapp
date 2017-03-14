//
//  NotificationVC.swift
//  HossRight
//
//  Created by ios on 03/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit
import SwiftyJSON
import ReachabilitySwift
import SDWebImage
import TagListView
import ActiveLabel


class NotificationVC: UIViewController,UITableViewDelegate,UITableViewDataSource  {

    var refreshControl = UIRefreshControl()
    var dateFormatter = DateFormatter()
    
    
    var notificationResults =  [JSON]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var pageString: String {
        if pageNumber == 0 {
            return "0"
        } else {
            return "\(pageNumber)&"
        }
    }
    var pageNumber = 0
    let requestManager = RestApiManager()
    let reachability = Reachability()!
    let validator = Validation()
    let notificationName = Notification.Name("rechabilitySwift")
    
    
    @IBOutlet weak var sideBarBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    let details:Dictionary = UserDefaults.standard.dictionary(forKey: "UserLoginDetails")!
    var userId:String!
    var api:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideBarBtn.target = self.revealViewController()
        sideBarBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        // Do any additional setup after loading the view.
        userId = details["id"] as! String
        self.dateFormatter.dateStyle = DateFormatter.Style.short
        self.dateFormatter.timeStyle = DateFormatter.Style.long
        
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.black
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(NotificationVC.PullRefresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = "NOTIFICATION"
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: ReachabilityChangedNotification,
                                                  object: reachability)
    }
    
    
    func PullRefresh()
    {
        let deadlineTime = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.pageNumber = 0
            self.getNotifications(pG: self.pageString)
        }
    }
    
    
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        if reachability.isReachable {
            self.getNotifications(pG: pageString)
            print("Feed Reachable ")
        } else {
            print("Page22 Network not reachable")
         self.validator.showGSMessage(message: "No internet connection", fromController: self.view, typeOfStyle: .error)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let noteCell:CustomNoteCell  = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! CustomNoteCell
       
        if (notificationResults[indexPath.row]["read_status"].stringValue == "U") {
            noteCell.backgroundColor = UIColor.white
        }
        else {
            noteCell.backgroundColor = UIColor.init(colorLiteralRed: 225.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1)
        }
      
        let text = NSMutableAttributedString()
        
        let s1 = NSAttributedString(string: "@\(notificationResults[indexPath.row]["sender_name"].stringValue) ", attributes: [
            NSForegroundColorAttributeName : UIColor.lightGray,
            NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline).withSize(14)
            ])
        
        let longText = "\( notificationResults[indexPath.row]["action_type"].stringValue)"
        let s2 = NSAttributedString(string: longText, attributes: [
            NSForegroundColorAttributeName : UIColor.lightGray,
            NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body).withSize(4)
            ])
        text.append(s1)
        text.append(s2)
        
        noteCell.titleLabel.attributedText = text
        noteCell.titleLabel.handleMentionTap { hashtag in
            print("\(hashtag) tapped")
            
        }
        
        noteCell.profileImageView.sd_setImage(with: NSURL(string:  notificationResults[indexPath.row]["prof_image"].stringValue) as URL!, placeholderImage: nil)
        
        if (notificationResults[indexPath.row]["post_title"].stringValue == " ") {
            noteCell.descriptionLabel.text = "\( notificationResults[indexPath.row]["sender_name"].stringValue)\( notificationResults[indexPath.row]["action_type"].stringValue)"
        }
        else {
            noteCell.descriptionLabel.text = "\( notificationResults[indexPath.row]["post_title"].stringValue)"
        }
        
      
        if indexPath.row == notificationResults.count - 1 { // last cell
            print(requestManager.hasMore)
            if requestManager.hasMore {
                getNextNotificationPage()
            }
        }
        noteCell.selectionStyle = UITableViewCellSelectionStyle.none
 
        return noteCell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("index path::\(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    
    
    func getNotifications(pG:String) {

        api = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.notificationAPI)"
        print("API::\(api)")
        self.requestManager.resetSearch()
        
        let parameters = [
            "limit"    : pG,
            "user_id" : userId
        ]
        requestManager.postRandomNotification(path: api, Parameters: parameters as [String : AnyObject]!, onCompletion: {
            (json) ->Void in
            
            if json == [JSON.null] {
                self.validator.showGSMessage(message: "No record(s) are available!", fromController: self.view, typeOfStyle: .warning)
            }
                
            else {
               
                self.notificationResults = json

            }
        })

        let now = Date()
        let updateString = "Last Updated at " + self.dateFormatter.string(from: now)
        self.refreshControl.attributedTitle = NSAttributedString(string: updateString)
        self.refreshControl.endRefreshing()
    }

    func getNextNotificationPage() {
        pageNumber += 1
       api = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.notificationAPI)"
        let parameters = [
            "limit"    : pageNumber,
            "user_id" : userId
            ] as [String : Any]
        requestManager.postRandomNotification(path: api, Parameters: parameters as [String : AnyObject]!, onCompletion: {
            json ->Void in
            if json == [JSON.null] {
                self.validator.showGSMessage(message: "No record(s) are available!", fromController: self.view, typeOfStyle: .warning)
            }
            else {
                self.notificationResults = self.requestManager.postResults
            }
        })
        
    }
}



class CustomNoteCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: CustomImageView!
    @IBOutlet weak var titleLabel: ActiveLabel!
    @IBOutlet weak var descriptionLabel: ActiveLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = UIColor.yellow
        titleLabel.hashtagColor = UIColor(red: 223.0/255, green: 80.0/255, blue: 63.0/255, alpha: 1)
        titleLabel.mentionColor = UIColor(red: 223.0/255, green: 80.0/255, blue: 63.0/255, alpha: 1)
    }
}
