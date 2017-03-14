//
//  LoginVC.swift
//  HossRight
//
//  Created by ios on 03/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON


class LoginVC: UIViewController,UITextFieldDelegate,NVActivityIndicatorViewable {

    @IBOutlet weak var usernameTxt: CustomTextFields!
    @IBOutlet weak var passwordTxt: CustomTextFields!
    let userLoginConstant = "UserLoginDetails"
    
    let validator = Validation()
    let requestManger = RestApiManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField
        {
        case usernameTxt:
            passwordTxt.becomeFirstResponder()
            break
        default:
            self.login(self)
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ")   {
            return false
        }
        return true
    }

    @IBAction func cancelAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "firstVC")
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true, completion: nil)
    }

    @IBAction func forgottenPassword(_ sender: Any) {
        let alert=UIAlertController(title: "Hoosright!", message: "Enter a valid Email Id", preferredStyle: UIAlertControllerStyle.alert);
        
        
        var field:UITextField?;
        alert.addTextField(configurationHandler:{(input:UITextField)in
            input.placeholder="Email Address....";
            input.keyboardType = UIKeyboardType.emailAddress
            input.clearButtonMode=UITextFieldViewMode.whileEditing;
            field=input;
        });
        
        
        func yesHandler(actionTarget: UIAlertAction){
            print(field!.text!);
            let frpassword = field!.text!
            if self.validator.isValidEmail(testStr: frpassword) {
                self.getPassword(email: frpassword)
            }
            else {
               self.validator.showAlert(title: "Hoosright!", message: "Enter a vaild email address", fromController: self)
            }
        }
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: yesHandler));
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil));
        present(alert, animated: true, completion: nil);
    }
    
    
    func getPassword(email:String)  {
        let parameters = [
            "email"    : email
        ]
        let apiPath:String = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.Password_Reset)"
       requestManger.postRandomPosts(path: apiPath, Parameters: parameters as [String : AnyObject]!, onCompletion: {
            json ->Void in
            let index = json[0]["status"]
            switch index {
            case 1,0  :
                self.validator.showAlert(title: "Hoosright!", message: json[0]["msg"].stringValue, fromController: self)
            case JSON.null  :
                self.validator.showAlert(title: "Hoosright!", message: "Something went wrong", fromController: self)
            default :
                self.validator.showAlert(title: "Hoosright!", message: "Something went wrong", fromController: self)
                break
            }
            
        })
        
        
        
    }

    
    
    
    @IBAction func login(_ sender: Any) {
        var username = self.usernameTxt.text!
        var password = self.passwordTxt.text!
        
        if (username.characters.count) < 5 {
            self.validator.showAlert(title: "Hoosright!", message: "Enter valid username", fromController: self)
            
        }else if (password.characters.count) < 6 {
            self.validator.showAlert(title: "Hoosright!", message: "Enter valid password", fromController: self)
            
        }else {
            
        startAnimating(ConstantsAPI.size, message: "Loading...",type: .ballClipRotate)
            
            let apiPath:String = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.login)"
            let parameters = [
                "uname"    : username,
                "pwd" : password
            ]
            
            requestManger.postRandomPosts(path: apiPath, Parameters: parameters as [String : AnyObject]!, onCompletion: {
                json ->Void in
                let index = json[0]["status"]
                switch index {
                case 0  :
                    self.validator.showAlert(title: "Hoosright!", message: json[0]["msg"].stringValue, fromController: self)
                case 1  :
                    print(json[0]["user_details"])
                    var userDetails = [String: String]()
                    for (key,subJson):(String, JSON) in json[0]["user_details"] {
                        userDetails.updateValue(subJson.stringValue, forKey: key)
                    }
                    let defaults = UserDefaults.standard
                    defaults.setValue(userDetails, forKey: self.userLoginConstant)
                    defaults.synchronize()
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
                    self.present(controller, animated: true, completion: nil)
                    
                default :
                    self.validator.showAlert(title: "Hoosright!", message: "Internet connection appears to be offline", fromController: self)
                }
                 self.stopAnimating()
            })
        }
    }
    
    
    @IBAction func loginViaFB(_ sender: Any) {
        
    }

    
}

class CustomTextFields: UITextField {
    
    override func draw(_ rect: CGRect) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: 6.0)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        self.borderStyle = UITextBorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
    
}

class fbButton: UIButton {
    
    override func draw(_ rect: CGRect) {
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red:0.17, green:0.46, blue:0.87, alpha:1.0).cgColor
    }
    
}


