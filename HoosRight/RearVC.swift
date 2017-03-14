//
//  RearVC.swift
//  HossRight
//
//  Created by ios on 07/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit
import SDWebImage

class RearVC: UITableViewController {

    let rearList = ["TIMELINE", "MY FRIENDS", "FAVORITE POSTS", "FEATURED POSTS", "LOGOUT"]
    let userNameKeyConstant = "keyWord"
    

    @IBOutlet weak var profileImage: CustomImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateProfileDetails()

    }

    
    func updateProfileDetails()  {
        let details:Dictionary = UserDefaults.standard.dictionary(forKey: "UserLoginDetails")!
        profileImage.sd_setImage(with: NSURL(string: details["prof_image"] as! String) as URL!, placeholderImage: nil)
        nameLabel.text = details["user_name"] as! String?
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rearList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellIdentifier:String = self.rearList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = rearList[row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightSemibold)
        cell.textLabel?.textColor = ConstantsAPI.backgroundColor
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let defaults = UserDefaults.standard
            defaults.set("TIMELINE", forKey: userNameKeyConstant)
            defaults.synchronize()
            
            self.revealViewController().revealToggle(animated: true)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
            self.revealViewController().setFront(controller, animated: true)
            
            break
            
        case 1:
            print("friend......")
            break
            
        case 2:
            let defaults = UserDefaults.standard
            defaults.set("FAVORITE POSTS", forKey: userNameKeyConstant)
            defaults.synchronize()
            self.revealViewController().revealToggle(animated: true)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
            self.revealViewController().setFront(controller, animated: true)
            break
            
        case 3:
            let defaults = UserDefaults.standard
            defaults.set("FEATURED POSTS", forKey: userNameKeyConstant)
            defaults.synchronize()
            self.revealViewController().revealToggle(animated: true)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
            self.revealViewController().setFront(controller, animated: true)
            break
            
        case 4:
            
            self.showAlert(title: "Hoosright!", message: "Do you want to Logout", fromController: self)
            break
            
        default:
            print("default")
            break
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    
    @IBAction func myPost(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        defaults.set("MY POST", forKey: userNameKeyConstant)
        defaults.synchronize()
        self.revealViewController().revealToggle(animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
        self.revealViewController().setFront(controller, animated: true)
    }
    
    
    func showAlert(title:String,message:String,fromController controller: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            UserDefaults.standard.removeObject(forKey: "UserLoginDetails")
            UserDefaults.standard.synchronize()
            print("Clear Cored Data & FaceBook Logout")
            
            print("Saved Parameters::....\(UserDefaults.standard.dictionary(forKey: "UserLoginDetails"))")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "firstVC")
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
            
        }
        alertController.addAction(OKAction)
        controller.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
}





class CustomImageView: UIImageView {
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        
        self.layoutIfNeeded()
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.lightGray.cgColor
        //UIColor(red:0.87, green:0.31, blue:0.25, alpha:1.0).cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height / 2.0
        self.clipsToBounds = true
    }

}




class CustomLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        
        self.layoutIfNeeded()
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height / 2.0
        self.clipsToBounds = true
    }
    
    
    
}



class CustomTitleLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        
        self.layoutIfNeeded()
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
    
    
    
}

