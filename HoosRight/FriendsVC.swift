//
//  FriendsVC.swift
//  HoosRight
//
//  Created by ios on 01/03/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit
import SwiftyJSON
import ReachabilitySwift

class FriendsVC: UITableViewController, UISearchResultsUpdating {

  
    
    var searchController = UISearchController()
    let validator = Validation()
    let requestManager = RestApiManager()
    let reachability = Reachability()!
    var mutableArray = NSMutableArray()
    var profileId:String!
    var api:String!
    var userId:String!
    let details:Dictionary = UserDefaults.standard.dictionary(forKey: "UserLoginDetails")!
    
    var validatedText: String {
        return searchController.searchBar.text!.replacingOccurrences(of: " ", with: "").lowercased()
    }

    var friendsList = [JSON]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    var searchFriendsList = [JSON]() {
        didSet {
           
            self.tableView.reloadData()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(errorMessageLabel)
        errorMessageLabel.fillSuperview()
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = "FRIENDS"
        self.searchController = UISearchController (searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search friend..."
        searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }

    
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            api = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.friendsAPI)"
            userId = details["id"] as! String
            self.mutableArray = []
            if !(profileId != nil) || (profileId == userId){
                
                let login: UIBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "list-fat-7"), style: .plain, target:  self, action: nil)
                login.tintColor = UIColor.white
                login.target = self.revealViewController()
                login.action = #selector(SWRevealViewController.revealToggle(_:))
                self.navigationItem.leftBarButtonItem = login
                
                let parameters = [
                    "user_id"    : userId
                ]
                self.getFriends(apiPath: api, parameters: parameters as [String : AnyObject]!)
            }
            else {
                let parameters = [
                    "user_id"    : profileId
                ]
                self.getFriends(apiPath: api, parameters: parameters as [String : AnyObject]! )
            }

        } else {
            print("Network not reachable")
        }
           }
    
    func getFriends(apiPath:String,parameters:[String : AnyObject]!) {
        
        requestManager.friendsList(path: apiPath, parameters: parameters as [String : AnyObject]!, onCompletion: {
            (json, err) ->Void in
            
            if let err = err {
                print(err)
                self.errorMessageLabel.isHidden = false
                return
            }
            else {
                self.errorMessageLabel.isHidden = true
                if json == [JSON.null] {
                   self.validator.showGSMessage(message: "No record(s) are available!", fromController: self.view, typeOfStyle: .warning)
                }
                else {
                    if self.searchController.isActive {
                        self.searchFriendsList = json[0]["data"].arrayValue
                        print("ViewController :\(self.friendsList)")
                        
                    }
                    else {
                        //self.friendsList = json[0]["friends"].arrayValue
                        for arr in json[0]["friends"].arrayValue{
                            self.mutableArray.add(arr.dictionaryObject!)
                        }
                        self.tableView.reloadData()
                    }
                }
            }
            
        })
        
    }
    

    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.searchController.isActive {
            return self.searchFriendsList.count
        }
        else {
            return self.mutableArray.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendCell:CustomFriendCell  = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! CustomFriendCell
        if self.searchController.isActive {
            
            friendCell.friendImageView.sd_setImage(with: NSURL(string:  searchFriendsList[indexPath.row]["prof_image"].stringValue) as URL!, placeholderImage: nil)
            friendCell.friendName.text = "\( searchFriendsList[indexPath.row]["name"].stringValue)"
            friendCell.friendUsername.text = "\( searchFriendsList[indexPath.row]["user_name"].stringValue)"

        }
        else {
            friendCell.friendImageView.sd_setImage(with: NSURL(string:  ((self.mutableArray.value(forKey: "prof_image") as! NSArray).object(at: indexPath.row) as? String)!) as URL!, placeholderImage: nil)
            friendCell.friendName.text = (self.mutableArray.value(forKey: "name") as! NSArray).object(at: indexPath.row) as? String
            friendCell.friendUsername.text = (self.mutableArray.value(forKey: "user_name") as! NSArray).object(at: indexPath.row) as? String
        }
        
        return friendCell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
         if self.searchController.isActive {
             secondViewController.profileId = searchFriendsList[indexPath.row]["id"].stringValue
        }
         else {
             secondViewController.profileId = (self.mutableArray.value(forKey: "follow_firend_id") as! NSArray).object(at: indexPath.row) as? String
        }
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.searchFriendsList.removeAll(keepingCapacity: false)
        //requestManager.resetSearch()
        let parameters = [
            "sname" : searchController.searchBar.text!,
            "user_id"    : userId
        ]
        self.getFriends(apiPath: "http://192.169.201.70/~hoosright/hoosrightapp/friend_search.php", parameters: parameters as [String : AnyObject]!)
        
    }
    
    deinit {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                            name: ReachabilityChangedNotification,
                                                            object: reachability)
    }

}

class CustomFriendCell: UITableViewCell {
    
    @IBOutlet weak var friendImageView: CustomImageView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendUsername: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

    }
}

/*
extension FriendsVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        requestManager.resetSearch()
        updateSearchResults()
        requestManager.searchFriends("\(ConstantsAPI.HoosRightServer)friend_search.php?user_id=1&search_key=\(validatedText)")
        
    }
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        requestManager.resetSearch()
        updateSearchResults()
        requestManager.searchFriends("\(ConstantsAPI.HoosRightServer)friend_search.php?user_id=1&search_key=\(validatedText)")
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        requestManager.resetSearch()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        requestManager.resetSearch()
    }
}
*/
