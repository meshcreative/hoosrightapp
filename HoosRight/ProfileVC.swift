//
//  ProfileVC.swift
//  HoosRight
//
//  Created by ios on 20/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class ProfileVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var selectedIndexPath: IndexPath!
    var profileId:String!
    let validator = Validation()
    let requestManger = RestApiManager()
    var api:String!
    var userId:String!
    var storedOffsets = [Int: CGFloat]()
    let details:Dictionary = UserDefaults.standard.dictionary(forKey: "UserLoginDetails")!
    var profileResults = [JSON]() {
        didSet {
            self.profileTable.reloadData()
        }
    }
    
    let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Apologies something went wrong. Please try again later..."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    @IBOutlet weak var profileOic: CustomImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var otherLabel: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profileTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "PROFILE"
        view.addSubview(errorMessageLabel)
        errorMessageLabel.fillSuperview()
        self.profileTable.tableHeaderView?.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        api = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.userProfileAPI)"
        userId = details["id"] as! String
        
        if !(profileId != nil) || (profileId == userId){
            print("My Profile...............")
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(ProfileVC.EditProfile)), animated: true)
            let parameters = [
                "user_id"    : userId,
                "type" : "user"
            ]
            self.getProfile(apiPath: api, parameters: parameters as [String : AnyObject]!)
                   }
        else {
              print("Friend Profile...............")
                let parameters = [
                    "user_id"    : profileId,
                    "type" : "friend",
                    "loggedUserId" : userId
                ]
                self.getProfile(apiPath: api, parameters: parameters as [String : AnyObject]!)
           
        }
    }
    

    
    func getProfile(apiPath:String,parameters:[String : AnyObject]!) {
        
        requestManger.postRandomPosts(path: apiPath, Parameters: parameters as [String : AnyObject]!, onCompletion: {
            json ->Void in
            if json == [JSON.null] {
                self.errorMessageLabel.isHidden = false
                return
            }
                
            else {
                 self.errorMessageLabel.isHidden = true
                 self.profileResults = [json[0]["userProfile"]]
                self.profileOic.sd_setImage(with: NSURL(string:  self.profileResults[0]["user_info"][0]["prof_image"].stringValue) as URL!, placeholderImage: nil)
                self.nameLabel.text = "\(self.profileResults[0]["user_info"][0]["name"])"
                self.username.text = "\(self.profileResults[0]["user_info"][0]["user_name"])"
                self.otherLabel.text = "\(self.profileResults[0]["user_info"][0]["address"])"
                 self.profileTable.tableHeaderView?.isHidden = false
                if self.profileResults[0]["isfriend"].exists() {
                    let friend = self.profileResults[0]["isfriend"]
                    switch friend {
                    case "No":
                        self.addFriendBarItem()
                        break
                    default:
                        self.removeFriendBarItem()
                        break
                    }
                }
            }
        })

    }

    func addFriendBarItem() {
        let rightItem = UIBarButtonItem(title: "+", style: .plain, target: self, action:  #selector(ProfileVC.followFriend))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 30.0)!], for: UIControlState.normal)
        rightItem.setTitlePositionAdjustment(UIOffsetMake(0.0, 5.0), for: UIBarMetrics.default)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    
    func removeFriendBarItem()  {
        let rightItem = UIBarButtonItem(title: "-", style: .plain, target: self, action:  #selector(ProfileVC.unfollowFriend))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 40.0)!], for: UIControlState.normal)
        rightItem.setTitlePositionAdjustment(UIOffsetMake(0.0, 5.0), for: UIBarMetrics.default)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            let count = self.profileResults[0]["user_post"].count
            switch count {
            case 0,1,2,3:
                 return 150
            default:
                return 250.0
            }
            
        case 1:
            return 44.0
        case 2:
            return 80.0
        default:
            return 80.0
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var countmaster = 0
         if self.profileResults.count > 0 {
            countmaster = self.profileResults.count + 2
        }
        else  {
            countmaster = 0
        }
        
        return countmaster
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         if self.profileResults.count > 0 {
            if indexPath.row == 0 {
                let cellOne:postCollectionCell  = tableView.dequeueReusableCell(withIdentifier: "proCell", for: indexPath) as! postCollectionCell
                    cellOne.postCollectionView.isHidden = false
                if !(profileId != nil) || (profileId == userId){
                    if !(self.profileResults[0]["user_post"].count == 0) {
                    }
                    else {
                        self.errorMessageLabel.isHidden = false
                        self.errorMessageLabel.textColor = UIColor.lightGray
                        self.errorMessageLabel.text = "No Posts Yet : HoosRight"
                        cellOne.contentView.addSubview(errorMessageLabel)
                        errorMessageLabel.fillSuperview()
                    }

                }
                else {
                    if !(self.profileResults[0]["user_info"][0]["privateAccount"].intValue == 0) {
                        cellOne.postCollectionView.isHidden = true
                        self.errorMessageLabel.isHidden = false
                        self.errorMessageLabel.textColor = UIColor.lightGray
                        self.errorMessageLabel.text = "🔒 Private Account"
                        cellOne.contentView.addSubview(errorMessageLabel)
                        errorMessageLabel.fillSuperview()
                    }
                    
                }
                cellOne.selectionStyle = UITableViewCellSelectionStyle.none
                return cellOne
            }
            if indexPath.row == 1 {
                let cellOne  = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
                cellOne.textLabel?.textColor = UIColor.lightGray
                switch self.profileResults[0]["total_friend"] {
                case 0:
                    cellOne.textLabel?.text = "No Friend Available"
                case 1:
                    cellOne.textLabel?.text = "\(self.profileResults[0]["total_friend"].stringValue) FRIEND"
                default:
                    cellOne.textLabel?.text = "\(self.profileResults[0]["total_friend"].stringValue) FRIENDS"

                }
                cellOne.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cellOne.selectionStyle = UITableViewCellSelectionStyle.none
                return cellOne
            }
            else {
                let cellOne:friendCellOne  = tableView.dequeueReusableCell(withIdentifier: "friendCellOne", for: indexPath) as! friendCellOne
                cellOne.selectionStyle = UITableViewCellSelectionStyle.none
                return cellOne
            }
        }
         else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            // Configure the cell...
            return cell
        }
    }
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (cell is friendCellOne) {
            guard let tableViewCell = cell as? friendCellOne else { return }
            
            tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            tableViewCell.collectionViewOffset = self.storedOffsets[indexPath.row] ?? 0
        }
        else if (cell is postCollectionCell) {
            guard let tableViewCell = cell as? postCollectionCell else { return }
            
            tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            tableViewCell.collectionViewOffset = self.storedOffsets[indexPath.row] ?? 0
        }

    }
    
     func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (cell is friendCellOne) {
            guard let tableViewCell = cell as? friendCellOne else { return }
            storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
        }
        else if (cell is postCollectionCell) {
            guard let tableViewCell = cell as? postCollectionCell else { return }
            storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
        }

    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func EditProfile()  {
       self.performSegue(withIdentifier: "editProfile", sender: self)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "friendList" {
        let destinationVC : FriendsVC = segue.destination as! FriendsVC
            destinationVC.profileId = self.profileResults[0]["user_info"][0]["id"].stringValue
        }
    }
    
    
    func followFriend()  {
        let alertController = UIAlertController(title: "Hoosright!", message: "Do you want to start following?", preferredStyle: .actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            alertController.dismiss( animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        let startFollowing = UIAlertAction(title: "Start following", style: .default) { (action) -> Void in
            self.api = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.followFriendAPI)"
            let parameters = [
                "user_id"    : self.userId,
                "friend_id" : self.profileId
            ]

            self.requestManger.postRandomPosts(path: self.api!, Parameters: parameters as [String : AnyObject]!, onCompletion: {
                json ->Void in
                let index = json[0]["status"]
                switch index {
                case 1,0  :
                    self.validator.showAlert(title: "Hoosright!", message: json[0]["msg"].stringValue, fromController: self)
                    if index == 1 {
                        self.removeFriendBarItem()
                    }
                case JSON.null  :
                    self.validator.showAlert(title: "Hoosright!", message: "Something went wrong", fromController: self)
                default :
                    self.validator.showAlert(title: "Hoosright!", message: "Something went wrong", fromController: self)
                    break
                }

       })
        }
        alertController.addAction(startFollowing)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func unfollowFriend()  {
        let alertController = UIAlertController(title: "Hoosright!", message: "Do you want to start following?", preferredStyle: .actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            alertController.dismiss( animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        let unfollowing = UIAlertAction(title: "Unfollowing", style: .default)  { action -> Void in
            self.api = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.UnfollowFriendAPI)"
            let parameters = [
                "user_id"    : self.userId,
                "friend_id" : self.profileId
            ]

            self.requestManger.postRandomPosts(path: self.api!, Parameters: parameters as [String : AnyObject]!, onCompletion: {
                json ->Void in
                let index = json[0]["status"]
                switch index {
                case 1,0  :
                    self.validator.showAlert(title: "Hoosright!", message: json[0]["msg"].stringValue, fromController: self)
                     if index == 1 {
                        self.addFriendBarItem()
                    }
                case JSON.null  :
                    self.validator.showAlert(title: "Hoosright!", message: "Something went wrong", fromController: self)
                default :
                    self.validator.showAlert(title: "Hoosright!", message: "Something went wrong", fromController: self)
                    break
                }

            })
        }
        alertController.addAction(unfollowing)
        present(alertController, animated: true, completion: nil)
    }
}



class postCollectionCell: UITableViewCell {
    

    @IBOutlet weak var postCollectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        postCollectionView.delegate = dataSourceDelegate
        postCollectionView.dataSource = dataSourceDelegate
        postCollectionView.tag = row
        postCollectionView.setContentOffset(postCollectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        postCollectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { postCollectionView.contentOffset.x = newValue }
        get { return postCollectionView.contentOffset.x }
    }

}

class friendCellOne: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        collectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { collectionView.contentOffset.x = newValue }
        get { return collectionView.contentOffset.x }
    }
}

class collectionCellFriendsImage: UICollectionViewCell {
    @IBOutlet weak var friendsImage: CustomImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

class collectionCellPostImage: UICollectionViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}


extension ProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView.tag == 2) {
            return self.profileResults[0]["total_friend"].intValue
       
        }
        else {
            return self.profileResults[0]["user_post"].count
         
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView.tag == 2) {
        let cell:collectionCellFriendsImage = collectionView.dequeueReusableCell(withReuseIdentifier: "friendProfileImage", for: indexPath) as! collectionCellFriendsImage
        cell.friendsImage.sd_setImage(with: NSURL(string:self.profileResults[0]["user_friend"][indexPath.row]["prof_image"].stringValue) as URL!, placeholderImage: nil)
        return cell
        }
        else {
            let cell:collectionCellPostImage = collectionView.dequeueReusableCell(withReuseIdentifier: "postCellIdentifier", for: indexPath) as! collectionCellPostImage
            cell.postImageView.sd_setImage(with: NSURL(string:self.profileResults[0]["user_post"][indexPath.row]["user_file"].stringValue) as URL!, placeholderImage: nil)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.tag == 2) {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            secondViewController.profileId = self.profileResults[0]["user_friend"][indexPath.row]["follow_firend_id"].stringValue
            self.navigationController?.pushViewController(secondViewController, animated: true)
         }
        else{
           print("Post Image id:\(self.profileResults[0]["user_post"][indexPath.row]["user_file"])")
             self.performSegue(withIdentifier: "detailPost", sender: self)
        }

    }
    
}


