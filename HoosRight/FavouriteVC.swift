//
//  FavouriteVC.swift
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
import Social
import MessageUI


class FavouriteVC: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, MFMailComposeViewControllerDelegate {

    var refreshControl = UIRefreshControl()
    var dateFormatter = DateFormatter()
    let reuseIdentifier = "FavouriteCell"
    
    var favouriteResults = [JSON]() {
        didSet {
            collectionView.reloadData()
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
    let notificationName = Notification.Name("rechabilitySwift")
    let validator = Validation()
    var userType = false
    
    @IBOutlet weak var sideMenuBarBtn: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var api:String!
    var userId:String!
    let prefs = UserDefaults.standard
    let details:Dictionary = UserDefaults.standard.dictionary(forKey: "UserLoginDetails")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuBarBtn.target = self.revealViewController()
        sideMenuBarBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        userId = details["id"] as! String
        
        self.dateFormatter.dateStyle = DateFormatter.Style.short
        self.dateFormatter.timeStyle = DateFormatter.Style.long
        
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.black
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(FavouriteVC.PullRefresh), for: UIControlEvents.valueChanged)
        self.collectionView.addSubview(refreshControl)
        self.navigationItem.title = "FAVORITE"
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
            self.getPosts(pG: self.pageString)
        }
        
    }
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        if reachability.isReachable {
            self.getPosts(pG: pageString)
            
        } else {
            self.validator.showGSMessage(message: "No internet connection", fromController: self.view, typeOfStyle: .error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return favouriteResults.count
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:CustomFavCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CustomFavCell
        
        cell.tagListView.removeAllTags()
        if let images = favouriteResults[indexPath.row]["post_tags"].string  {
            for item in images.words() {
                cell.tagListView.addTag(item)
            }
        }
        
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: "By #\(favouriteResults[indexPath.row]["first_user"].stringValue)", attributes: underlineAttribute)
        
        cell.firstName.attributedText = underlineAttributedString
        cell.firstName.handleHashtagTap { hashtag in
            self.userType = false
            self.performSegue(withIdentifier: "favprofile", sender: indexPath)
        }
        
        let underlineAttributedString2 = NSAttributedString(string: "#\( favouriteResults[indexPath.row]["second_user"].stringValue)", attributes: underlineAttribute)
        cell.secondName.attributedText = underlineAttributedString2
        cell.secondName.handleHashtagTap { hashtag in
            self.userType = true
            self.performSegue(withIdentifier: "favprofile", sender: indexPath)
        }
        
        
        cell.postTitle.text = "\( favouriteResults[indexPath.row]["post_name"].stringValue)"
        cell.descriptionTxt.text = "\( favouriteResults[indexPath.row]["description"].stringValue)"
        cell.firstImageView.sd_setImage(with: NSURL(string:   favouriteResults[indexPath.row]["first_prof_image"].stringValue) as URL!, placeholderImage: nil)
        cell.secondImageView.sd_setImage(with: NSURL(string:   favouriteResults[indexPath.row]["second_prof_image"].stringValue) as URL!, placeholderImage: nil)
        cell.addDateLabel.text = "\( favouriteResults[indexPath.row]["added_post"].stringValue) by \(favouriteResults[indexPath.row]["first_user"].stringValue)"
        switch favouriteResults[indexPath.row]["isLike"].stringValue {
        case "Y":
            cell.likeBtn.select()
        default:
            cell.likeBtn.deselect()
        }
        
        cell.likeBtn.tag = indexPath.row
        cell.commentBtn.tag = indexPath.row
        cell.moreBtn.tag = indexPath.row
        
        if indexPath.row == favouriteResults.count - 1 { // last cell
            if self.requestManager.hasMore {
                print("checking.........\(indexPath.row)")
                getNextPage()
            }
        }
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.item)!")
        collectionView.deselectItem(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "favDetails", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "favDetails" {
        let destinationVC : DetailVC = segue.destination as! DetailVC
        let indexPath = sender as! NSIndexPath
        destinationVC.details = JSON(["post_details":self.favouriteResults[indexPath.row]])
            
        }
        if segue.identifier == "favcomment" {
            print("checking comment.......")
        }
        if segue.identifier == "favprofile" {
            let destinationVC : ProfileVC = segue.destination as! ProfileVC
            let indexPath = sender as! NSIndexPath
            switch userType {
            case true:
                userId = self.favouriteResults[indexPath.row]["second_user_id"].stringValue
            default:
                userId = self.favouriteResults[indexPath.row]["user_id"].stringValue
            }
            destinationVC.profileId = userId
            
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: 240.0)
    }
    
    func getPosts(pG:String) {
        
        api = "\(ConstantsAPI.HoosRightServer)favorite_post.php?user_id=\(userId!)&limit=\(pG)"
        print("API::\(api)")
        self.requestManager.resetSearch()
        self.requestManager.getRandomPosts(path: api, onCompletion: {
            (json) ->Void in
            if json == [JSON.null] {
            self.validator.showGSMessage(message: "No record(s) are available!", fromController: self.view, typeOfStyle: .warning)
            }
            else {
                self.favouriteResults = json
            }
        })
        
        let now = Date()
        let updateString = "Last Updated at " + self.dateFormatter.string(from: now)
        self.refreshControl.attributedTitle = NSAttributedString(string: updateString)
        self.refreshControl.endRefreshing()
        
    }
    
    
    func getNextPage() {
        pageNumber += 1
        api = "\(ConstantsAPI.HoosRightServer)favorite_post.php?user_id=\(userId!)&limit=\(pageNumber)"
        print("Next Page ::\(api)")
        
        requestManager.getRandomPosts(path:api, onCompletion: {
            (json) ->Void in
            if json == [JSON.null] {
                self.validator.showGSMessage(message: "No record(s) are available!", fromController: self.view, typeOfStyle: .warning)
            }
            else {
                self.favouriteResults = self.requestManager.postResults
            }
            
        })
    }
    
    
    
    @IBAction func likeAction(_ sender: DOFavoriteButton) {
        if let row = (sender as AnyObject).tag {
            if self.favouriteResults[row]["isLike"].string == "N" {
                api = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.postLike)"
                sender.select()
            }
            else {
                api = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.postUnlike)"
                sender.deselect()
            }
            let parameters = [
                "user_id"    : userId!,
                "post_id" : self.favouriteResults[row]["id"].string!,
                "friend_id" : self.favouriteResults[row]["second_user_id"].string!
            ]
            print("api:\(api!)")
            print("parameters:\(parameters)")
            RestApiManager.sharedInstance.postRandomPosts(path: api!, Parameters: parameters as [String : AnyObject], onCompletion: {
                json ->Void in
                let index = json[0]["post_details"]
                print("Clik Like :\(index)")
                switch index["isLike"] {
                case "N" :
                    print("Case 1...............")
                    print("Previous  \(self.favouriteResults)")
                    self.favouriteResults[row].arrayObject?.remove(at: row)
                    self.favouriteResults = self.favouriteResults.filter { $0 != JSON.null }
                    print("Updated  \(self.favouriteResults)")

                case "Y"  :
                    self.favouriteResults[row].dictionaryObject = json["post_details"].dictionaryObject
                    break
                default :
                    print("Case 3...............")
                    break
                }
                
            })
            
        }

    }

    @IBAction func commentAction(_ sender: Any) {
          self.performSegue(withIdentifier: "favComment", sender: self)
    }
    
    @IBAction func moreAction(_ sender: Any) {
        let row = (sender as AnyObject).tag
        let alertController = UIAlertController(title: "Hoosright!", message: "What do you want to do?", preferredStyle: .actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            alertController.dismiss( animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let facebookPostAction = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.default) { (action) -> Void in
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                let vc = SLComposeViewController(forServiceType:SLServiceTypeFacebook)
                //\(self.postsResults[row!]["id"].string)"
                vc?.add(URL(string: "http://www.hoosrightapp.com/"))
                vc?.setInitialText("Hoosright!")
                self.present(vc!, animated: true, completion: nil)
            }
            else {
                self.validator.showAlert(title: "Hoosright!", message: "You are not connected to your Facebook account.", fromController: self)
                
            }
        }
        alertController.addAction(facebookPostAction)
        
        let tweetAction = UIAlertAction(title: "Tweet", style: UIAlertActionStyle.default) { (action) -> Void in
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                let vc = SLComposeViewController(forServiceType:SLServiceTypeTwitter)
                vc?.add(URL(string: "http://www.hoosrightapp.com/"))
                vc?.setInitialText("Hoosright!")
                self.present(vc!, animated: true, completion: nil)
            }
            else {
                self.validator.showAlert(title: "Hoosright!", message: "You are not logged in to your Twitter account.", fromController: self)
            }
            
            
        }
        alertController.addAction(tweetAction)
        
        let report = UIAlertAction(title: "Report", style: UIAlertActionStyle.default) { (action) -> Void in
            if !MFMailComposeViewController.canSendMail() {
                self.validator.showAlert(title: "Hoosright!", message: "Mail services are not available", fromController: self)
                return
            }
            else {
                self.composeMail(ReportId:self.favouriteResults[row!]["id"].string!)
            }
        }
        alertController.addAction(report)
        
        
        if self.favouriteResults[row!]["user_id"].string! == userId! || self.favouriteResults[row!]["second_user_id"].string! == userId! {
            let deletPost = UIAlertAction(title: "Delete Post", style: UIAlertActionStyle.default) { (action) -> Void in
                self.api = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.deletPostAPI)"
                let parameters = [
                    "post_id" : self.favouriteResults[row!]["id"].string!
                ]
                print("api:\(self.api!)")
                print("parameters:\(parameters)")
                self.requestManager.postRandomPosts(path: self.api!, Parameters: parameters as [String : AnyObject]!, onCompletion: {
                    json ->Void in
                    let index = json[0]["status"]
                    switch index {
                    case 1,0  :
                        self.validator.showAlert(title: "Hoosright!", message: json[0]["msg"].stringValue, fromController: self)
                        if index == 1 {
                            print("enterd into condition............")
                            self.favouriteResults[row!].arrayObject?.remove(at: row!)
                            self.favouriteResults = self.favouriteResults.filter { $0 != JSON.null }
                        }
                    case JSON.null  :
                        self.validator.showAlert(title: "Hoosright!", message: "Something went wrong", fromController: self)
                    default :
                        self.validator.showAlert(title: "Hoosright!", message: "Something went wrong", fromController: self)
                        break
                    }
                    
                    
                })
                
            }
            alertController.addAction(deletPost)
        }
        present(alertController, animated: true, completion: nil)
    }
    
    
        func composeMail(ReportId:String)  {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            // Configure the fields of the interface.
            composeVC.setToRecipients(["Info@hoosrightapp.com"])
            composeVC.setSubject("Report on the post id:\(ReportId)")
            composeVC.setMessageBody("How can we assest you", isHTML: false)
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult, error: Error?) {
            // Check the result or perform other tasks.
            
            // Dismiss the mail compose view controller.
            controller.dismiss(animated: true, completion: nil)
        }


}









class CustomFavCell: UICollectionViewCell, TagListViewDelegate {
    
    
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var postTitle: CustomTitleLabel!
    @IBOutlet weak var firstImageView: CustomImageView!
    @IBOutlet weak var secondImageView: CustomImageView!
    @IBOutlet weak var descriptionTxt: UILabel!
    @IBOutlet weak var likeBtn: DOFavoriteButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var addDateLabel: UILabel!
    @IBOutlet weak var firstName: ActiveLabel!
    @IBOutlet weak var secondName: ActiveLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tagListView.delegate = self
        tagListView.textFont = UIFont.systemFont(ofSize: 10)
        tagListView.shadowRadius = 2
        tagListView.shadowOpacity = 0.4
        tagListView.shadowColor = UIColor.black
        tagListView.shadowOffset = CGSize(width: 1, height: 1)
        tagListView.alignment = .right
    }
   }


