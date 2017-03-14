//
//  SettingsVC.swift
//  Hoosright!
//
//  Created by ios on 01/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit
import SwiftyJSON
import MessageUI


class SettingsVC: UITableViewController,EPPickerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var privateSwitch: UISwitch!
    var userDetail:Dictionary = UserDefaults.standard.dictionary(forKey: "UserLoginDetails")!
    var privateAccount:String!
    var facebookId:String!
    var userId:String!
    let requestManager = RestApiManager()
    let validator = Validation()


    override func viewDidLoad() {
        super.viewDidLoad()
        userId = userDetail["id"] as! String
        privateAccount = userDetail["privateAccount"] as! String
        facebookId = userDetail["facebook_id"] as! String
        print(facebookId)
        switch privateAccount {
        case "0":
            privateSwitch .setOn(false, animated: true)
        default:
            privateSwitch .setOn(true, animated: true)

        }
         self.clearsSelectionOnViewWillAppear = true
         self.navigationItem.title = "SETTINGS"
        leftBarButton.target = self.revealViewController()
        leftBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 3
        case 2:
            return 2
        case 3:
            return 2
        case 4:
            return 1
        default:
            return 0
        }
        
    }

     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            
            switch indexPath.row {
            case 0:
                if facebookId == "" {
            self.validator.showAlert(title: "Hoosright!", message: "You are not connected with Facebook", fromController: self)
                }
                else {
                    
                }
                
            case 1:
                let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:false, subtitleCellType: SubtitleCellValue.phoneNumber)
                let navigationController = UINavigationController(rootViewController: contactPickerScene)
                navigationController.navigationBar.barTintColor = UIColor(red:0.87, green:0.31, blue:0.25, alpha:1.0)
                navigationController.navigationBar.isTranslucent = false
                navigationController.navigationBar.tintColor = UIColor.white
                navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
                self.present(navigationController, animated: true, completion: nil)

            case 2:
                print("index path2::\(indexPath.row)")
            default:
                print("index pathD::\(indexPath.row)")
            }
            
        case 1:
            switch indexPath.row {
            case 0:
                print("index path0::\(indexPath.row)")
            case 1:
                print("index path1::\(indexPath.row)")
            case 2:
                print("index path2::\(indexPath.row)")
            default:
                print("index pathD::\(indexPath.row)")
            }
        case 2:
            switch indexPath.row {
            case 0:
                print("index path0::\(indexPath.row)")
            case 1:
                print("index path1::\(indexPath.row)")
            default:
                print("index pathD::\(indexPath.row)")
            }
        case 3:
            switch indexPath.row {
            case 0:
                print("mail compose")
                if !MFMailComposeViewController.canSendMail() {
                    print("Mail services are not available")
                    return
                }
                else {
                    self.composeMail()
                }
            case 1:
                print("index path1::\(indexPath.row)")
            default:
                print("index pathD::\(indexPath.row)")
            }
        case 4:
            switch indexPath.row {
            case 0:
                self.showAlert(title: "Hoosright!", message: "Do you want to Logout", fromController: self)
                break
            default:
                print("index pathD::\(indexPath.row)")
            }
        default:
            print("index path::\(indexPath.section)")
        }
          tableView.deselectRow(at: indexPath, animated: true)
    }


    
    func composeMail()  {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["Info@hoosrightapp.com"])
        composeVC.setSubject("Report")
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
    

    @IBAction func switchAction(_ sender: Any) {
        let state:String!
        if privateSwitch.isOn {
           print("The Switch is On")
            state = "1"
        } else {
            print("The Switch is Off")
            state = "0"
        }
        
        let apiPath:String = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.privateAPI)"
        let parameters = [
            "user_id"    : userId,
            "valuePA" : state,
            "type" : "PrivateAccount"
        ]
        requestManager.postRandomPosts(path: apiPath, Parameters: parameters as [String : AnyObject]!, onCompletion: {
            json ->Void in
            print(json[0])
            let index = json[0]["staus"]
            switch index {
            case 0  :
                self.validator.showAlert(title: "Hoosright!", message: json[0]["msg"].stringValue, fromController: self)
            case 1  :
                 self.validator.showAlert(title: "Hoosright!", message: json[0]["msg"].stringValue, fromController: self)
                  self.userDetail["privateAccount"] = state
                  let defaults = UserDefaults.standard
                  defaults.setValue(self.userDetail, forKey: "UserLoginDetails")
                  defaults.synchronize()
                
            default :
                self.validator.showAlert(title: "Hoosright!", message: "Internet connection appears to be offline", fromController: self)
            }
  
        })

        
    }

}
