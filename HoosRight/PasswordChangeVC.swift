//
//  PasswordChangeVC.swift
//  HoosRight
//
//  Created by ios on 15/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import NVActivityIndicatorView

class PasswordChangeVC: UIViewController,UITextFieldDelegate,NVActivityIndicatorViewable {

    @IBOutlet weak var currentPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var newPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var confrimPassword: SkyFloatingLabelTextField!
    let validator = Validation()
    let requestManger = RestApiManager()
    let details:Dictionary = UserDefaults.standard.dictionary(forKey: "UserLoginDetails")!
    var userName:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName = details["user_name"] as! String
        self.navigationItem.title = "Change Password"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(addTapped))
        self.hideKeyboardWhenTappedAround()

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.returnKeyType = UIReturnKeyType.done
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ")   {
            return false
        }
        return true
    }
    
    func addTapped(sender: UIBarButtonItem) {
        
        let currentPass = self.currentPassword.text!
        let newPass = self.newPassword.text!
        let confrimPass = self.confrimPassword.text!
        
        if (currentPass.isEmpty || newPass.isEmpty || confrimPass.isEmpty) {
            self.validator.showAlert(title: "Hoosright!", message: "Required fields are empty!", fromController: self)
            return
            }
        if (currentPass.characters.count < 5 || newPass.characters.count < 5 || confrimPass.characters.count < 5) {
            self.validator.showAlert(title: "Hoosright!", message: "password should atlest 5 characters", fromController: self)
            return
        }
        if (newPass != confrimPass){
            self.validator.showAlert(title: "Hoosright!", message: "Your password dosen't match.", fromController: self)
            return
        }
        startAnimating(ConstantsAPI.size, message: "Updating...",type: .ballClipRotate)
        let apiPath:String = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.changePasswordAPI)"
        let parameters = [
            "user_name"    : userName,
            "cur_pass" : currentPass,
            "pass" : newPass
        ]
        print(parameters,apiPath)
        requestManger.postRandomPosts(path: apiPath, Parameters: parameters as [String : AnyObject]!, onCompletion: {
            json ->Void in
            let index = json[0]["status"]
            switch index {
            case 0,1  :
                self.validator.showAlert(title: "Hoosright!", message: json[0]["msg"].stringValue, fromController: self)
            default :
                self.validator.showAlert(title: "Hoosright!", message: "Internet connection appears to be offline", fromController: self)
            }
            self.stopAnimating()
        })

    }

}
