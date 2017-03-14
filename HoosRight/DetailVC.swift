//
//  DetailVC.swift
//  HossRight
//
//  Created by ios on 10/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import ReachabilitySwift
import SDWebImage
import TagListView
import ActiveLabel

class DetailVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var detailTableView: UITableView!
    var details:JSON!
    var result:UITableViewCell! = nil
    let userDetail:Dictionary = UserDefaults.standard.dictionary(forKey: "UserLoginDetails")!
    var userId:String!
    var api:String!
    let requestManager = RestApiManager()
    let validator = Validation()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "DETAILS"
        print("details view : \(details)")
        

    }

    override func viewWillAppear(_ animated: Bool) {
        //userId = userDetail["id"] as! String
        //self.getPostDetails(postID: details["post_details"]["id"].string!)
    }
    
    func getPostDetails(postID:String) {
        
        api = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.postdetailsAPI)"
        print("API::\(api)")
        self.requestManager.resetSearch()
        
        let parameters = [
            "post_id"    : postID,
            "user_id" : userId
        ]
        requestManager.postRandomPosts(path: api, Parameters: parameters as [String : AnyObject]!, onCompletion: {
            (json) ->Void in
            print("hello world \(json)")
            if json == [JSON.null] {
                self.validator.showGSMessage(message: "No record(s) are available!", fromController: self.view, typeOfStyle: .warning)
            }
                
            else {
                //json[0]["post_details"]: [1:2]
                 self.details = json[0]
                 print("hello world \(json[0]["post_details"])")
                 //self.detailTableView.reloadData()

                }
        })
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch details["post_details"]["file_type"].stringValue {
            case "V":
                return 650
            default:
                return 640
            }
        case 1:
            return 80
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    if indexPath.section == 0 {
            let sectionOne : SectionOne  = tableView.dequeueReusableCell(withIdentifier: "sectionOne", for: indexPath) as! SectionOne
            sectionOne.selectionStyle = UITableViewCellSelectionStyle.none
        sectionOne.tagListView.removeAllTags()
        
        if let images = details["post_details"]["post_tags"].string  {
            for item in images.words() {
                sectionOne.tagListView.addTag(item)
            }
        }
        sectionOne.postTitle.text = "\( details["post_details"]["post_name"].stringValue)"
        sectionOne.addDateByUsername.text = "Started \(details["post_details"]["added_post"].stringValue) by \(details["post_details"]["first_user"].stringValue)"
        switch details["post_details"]["file_type"].stringValue {
        case "V":
         sectionOne.stackViedo.alpha = 1.0
            print("video.............")
        default:
            sectionOne.stackViedo.alpha = 0.0
            sectionOne.stackViedo.heightAnchor.constraint(equalToConstant: 0.0).isActive = true
            sectionOne.firstPostImageView.sd_setImage(with: NSURL(string:   details["post_details"]["upload_file"].stringValue) as URL!, placeholderImage: nil)
            sectionOne.secondPostImageView.sd_setImage(with: NSURL(string:   details["post_details"]["upload_file2"].stringValue) as URL!, placeholderImage: nil)
        }

        sectionOne.firstProfileImageView.sd_setImage(with: NSURL(string:   details["post_details"]["first_prof_image"].stringValue) as URL!, placeholderImage: nil)
        sectionOne.secondProfileImageView.sd_setImage(with: NSURL(string:   details["post_details"]["second_prof_image"].stringValue) as URL!, placeholderImage: nil)
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: "By #\(details["post_details"]["first_user"].stringValue)", attributes: underlineAttribute)
        
        sectionOne.firstName.attributedText = underlineAttributedString
        sectionOne.firstName.handleHashtagTap { hashtag in
            self.performSegue(withIdentifier: "favComment", sender: self)
            print("\(hashtag) tapped2")
        }
        
        let underlineAttributedString2 = NSAttributedString(string: "#\( details["post_details"]["second_user"].stringValue)", attributes: underlineAttribute)
        sectionOne.secondName.attributedText = underlineAttributedString2
        sectionOne.secondName.handleHashtagTap { hashtag in
            self.performSegue(withIdentifier: "favDetails", sender: self)
            print("\(hashtag) tapped")
        }
        
        switch details["isLike"].stringValue {
        case "Yes":
            sectionOne.likeBtn.select()
        default:
            sectionOne.likeBtn.deselect()
        }
        
        sectionOne.textViewOne.text = "\( details["post_details"]["description"].stringValue)"
        sectionOne.textViewTwo.text = "\( details["post_details"]["description2"].stringValue)"
        sectionOne.descriptionOne.text = "SIDE A - \( details["post_details"]["first_user"].stringValue)"
        sectionOne.descriptionTwo.text = "SIDE B - \( details["post_details"]["second_user"].stringValue)"
        sectionOne.firstUserVoter.setTitle("@\( details["post_details"]["first_user"].stringValue)",for: .normal)
        sectionOne.secondUserVoter.setTitle("@\( details["post_details"]["second_user"].stringValue)",for: .normal)
            result = sectionOne

        }
        if indexPath.section == 1 {
            let sectionTwo : SectionTwo  = tableView.dequeueReusableCell(withIdentifier: "sectionTwo", for: indexPath) as! SectionTwo
            sectionTwo.selectionStyle = UITableViewCellSelectionStyle.none
            

            
            result = sectionTwo

        }
         return result
 
    }


    @IBAction func firstUserVoteAction(_ sender: Any) {
    }
    
    
    @IBAction func secondUserVoteAction(_ sender: Any) {
    }
    
    
    @IBAction func likeAction(_ sender: Any) {
        if details["isLike"].string == "N" {
            api = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.postLike)"
            //(sender as AnyObject).select()
             // sender.select()
        }
        else {
            api = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.postUnlike)"
            //(sender as AnyObject).deselect()
           // sender.deselect()
        }
        let parameters = [
            "user_id"    : userId!,
            "post_id" : details["id"].string!,
            "friend_id" : details["second_user_id"].string!
        ]
        print("api:\(api!)")
        print("parameters:\(parameters)")
        RestApiManager.sharedInstance.postRandomPosts(path: api!, Parameters: parameters as [String : AnyObject], onCompletion: {
            json ->Void in
            let index = json[0]["post_details"]
            switch index["isLike"] {
            case "N" :
                self.details.dictionaryObject = json[0]["post_details"].dictionaryObject
                DispatchQueue.main.async {
                    let indexPath = IndexPath(item: 1, section: 0)
                    self.detailTableView.rectForRow(at: indexPath)
                }
                
            case "Y"  :
                self.details.dictionaryObject = json[0]["post_details"].dictionaryObject
                DispatchQueue.main.async {
                    let indexPath = IndexPath(item: 1, section: 0)
                    self.detailTableView.rectForRow(at: indexPath)
                    
                }
                break
            default :
                print("Case 3...............")
                break
            }
            
        })

    }

    
    
    @IBAction func commentAction(_ sender: Any) {
    }
    
    @IBAction func moreAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Hoosright!", message: "What do you want to do?", preferredStyle: .actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            alertController.dismiss( animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let shareToFacebook = UIAlertAction(title: "Share to Facebook", style: .default, handler: nil)
        alertController.addAction(shareToFacebook)
        let tweet = UIAlertAction(title: "Tweet", style: .default, handler: nil)
        alertController.addAction(tweet)
        let report = UIAlertAction(title: "Report", style: .default, handler: nil)
        alertController.addAction(report)
        
        if details["user_id"].stringValue == userId! || self.details["second_user_id"].stringValue == userId! {
            
            let deletPost = UIAlertAction(title: "Delete Post", style: .default, handler: nil)
            alertController.addAction(deletPost)
        }
        
        present(alertController, animated: true, completion: nil)
        
    }

    
}



class SectionOne: UITableViewCell {
    
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var postTitle: CustomTitleLabel!
    @IBOutlet weak var addDateByUsername: UILabel!
    @IBOutlet weak var firstPostImageView: PostImageView!
    @IBOutlet weak var secondPostImageView: PostImageView!
    @IBOutlet weak var firstProfileImageView: CustomImageView!
    @IBOutlet weak var secondProfileImageView: CustomImageView!
    @IBOutlet weak var firstName: ActiveLabel!
    @IBOutlet weak var secondName: ActiveLabel!
    @IBOutlet weak var firstVote: UILabel!
    @IBOutlet weak var secondVote: UILabel!
    @IBOutlet weak var textViewOne: UITextView!
    @IBOutlet weak var textViewTwo: UITextView!
    @IBOutlet weak var descriptionOne: UILabel!
    @IBOutlet weak var descriptionTwo: UILabel!
    @IBOutlet weak var firstUserVoter: UIButton!
    @IBOutlet weak var secondUserVoter: UIButton!
    @IBOutlet weak var likeBtn: DOFavoriteButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var stackViedo: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.firstUserVoter.layer.cornerRadius = 20
        self.firstUserVoter.layer.borderWidth = 2
        self.firstUserVoter.layer.borderColor = UIColor.white.cgColor
        self.secondUserVoter.layer.cornerRadius = 20
        self.secondUserVoter.layer.borderWidth = 2
        self.secondUserVoter.layer.borderColor = UIColor.white.cgColor
    }
}


class SectionTwo: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}



class PostImageView: UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        
        self.layoutIfNeeded()
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        //self.clipsToBounds = true
    }
    
}


