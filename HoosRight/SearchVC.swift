//
//  SearchVC.swift
//  HoosRight
//
//  Created by ios on 17/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage


class SearchVC: UITableViewController {

    var searchResults = [JSON]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var validatedText: String {
        return searchController.searchBar.text!.replacingOccurrences(of: " ", with: "").lowercased()
    }
    
    var pageString: String {
        if pageNumber == 0 {
            return "0"
        } else {
            return "\(pageNumber)&"
        }
    }
    
    var pageNumber = 0
    let validator = Validation()
    var searchController = UISearchController(searchResultsController: nil)
    let requestManager = RestApiManager()
    var api:String!
    var userId:String!
    let prefs = UserDefaults.standard
    let details:Dictionary = UserDefaults.standard.dictionary(forKey: "UserLoginDetails")!
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = details["id"] as! String
        self.navigationItem.title = "Search Post"
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Enter tag..."
        searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
                NotificationCenter.default.addObserver(self, selector: #selector(SearchVC.updateSearchResults), name: NSNotification.Name(rawValue: "searchResultsUpdated"), object: nil)
       self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateSearchResults() {
        searchResults = requestManager.postResults
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResults.count

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: serachTabelCell = tableView.dequeueReusableCell(withIdentifier: "serachCell", for: indexPath) as! serachTabelCell
        
        cell.postName.text = searchResults[indexPath.row]["post_name"].stringValue
        cell.firstImageView.sd_setImage(with: NSURL(string:searchResults[indexPath.row]["first_prof_image"].stringValue) as URL!, placeholderImage: nil)
//        if indexPath.row == searchResults.count - 1 {
//            if requestManager.hasMore {
//               getNextPage()
//            }
//        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "searchSegu", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "searchSegu" {
            let destinationVC : DetailVC = segue.destination as! DetailVC
            let indexPath = sender as! NSIndexPath
            destinationVC.details = JSON(["post_details":self.searchResults[indexPath.row]])

        }

    }
    
    
    
//    func getNextPage() {
//        pageNumber += 1
//        api = "\(ConstantsAPI.HoosRightServer)search.php?user_id=\(userId!)&search_key=\(validatedText)"
//        print("Next Page ::\(api)")
//        //requestManager.search("\(ConstantsAPI.HoosRightServer)search.php?user_id=1&search_key=\(validatedText)")
//        requestManager.getRandomPosts(path:api, onCompletion: {
//            (json) ->Void in
//            if json == [JSON.null] {
//                self.validator.showGSMessage(message: "No record(s) are available!", fromController: self.view, typeOfStyle: .warning)
//            }
//            else {
//                self.searchResults = self.requestManager.postResults
//            }
//            
//        })
//    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}




extension SearchVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        requestManager.resetSearch()
        updateSearchResults()
        requestManager.search("\(ConstantsAPI.HoosRightServer)search.php?user_id=\(userId!)&search_key=\(validatedText)")
    
    }
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        print("starting.............")
        requestManager.resetSearch()
        updateSearchResults()
        requestManager.search("\(ConstantsAPI.HoosRightServer)search.php?user_id=\(userId!)&search_key=\(validatedText)")
    }
    

    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
         requestManager.resetSearch()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        requestManager.resetSearch()
    }
}


class serachTabelCell: UITableViewCell {
    
    @IBOutlet weak var firstImageView: CustomImageView!
    @IBOutlet weak var postName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
}


