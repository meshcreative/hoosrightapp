//
//  RegisterVC.swift
//  HossRight
//
//  Created by ios on 03/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import SkyFloatingLabelTextField

class RegisterVC: UIViewController,UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,NVActivityIndicatorViewable {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailAddressTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var usernameTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var nameText: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordText: SkyFloatingLabelTextField!
    @IBOutlet weak var confirmpassText: SkyFloatingLabelTextField!

    var emailAddress:String!
    let validator = Validation()
    let requestManger = RestApiManager()
    let imagePicker = UIImagePickerController()
    var selectedImage:UIImage?
    
    
    override func viewWillAppear(_ animated: Bool) {
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        emailAddressTxt.text = emailAddress
        self.title = "Register"
        self.navigationController?.setNavigationBarHidden(false, animated: true)


    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField
        {
        case emailAddressTxt:
            textField.becomeFirstResponder()
            break
        case usernameTxt:
            textField.becomeFirstResponder()
            break
        case nameText:
            textField.becomeFirstResponder()
            break
        case passwordText:
            textField.becomeFirstResponder()
            break
        case confirmpassText:
            scrollView.setContentOffset(CGPoint.zero, animated: true)
            textField.resignFirstResponder()
            break
        default:
            scrollView.setContentOffset(CGPoint.zero, animated: true)
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let pointInTable:CGPoint = textField.superview!.convert(textField.frame.origin, to:scrollView)
        var contentOffset:CGPoint = scrollView.contentOffset
        contentOffset.y  = pointInTable.y
        if let accessoryView = textField.inputAccessoryView {
            contentOffset.y -= accessoryView.frame.size.height
        }
        scrollView.contentOffset = contentOffset
        return true;
    }
    
    
    @IBAction func tapProfileImage(_ sender: Any) {
        print("hello..........")
    let actionSheetController: UIAlertController = UIAlertController(title: "Action Sheet", message: "Hoosright! Choose an option!", preferredStyle: .actionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            actionSheetController.dismiss(animated: true, completion: nil)
            print("Dismiss")
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Take Picture", style: .default) { action -> Void in
            //Code for launching the camera goes here
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                self.validator.showAlert(title: "Hoosright!", message: "Device dont have camera", fromController: self)
            }
            
        }
        actionSheetController.addAction(takePictureAction)
        //Create and add a second option action
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Choose From Camera Roll", style: .default) { action -> Void in
            //Code for picking from camera roll goes here
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present( self.imagePicker, animated: true, completion: nil)
        }
        actionSheetController.addAction(choosePictureAction)
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = image
            profileImageView.image = selectedImage
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func RagistationValidation()->Bool
    {
        if emailAddressTxt.text!.isEmpty
        {
            self.validator.showAlert(title: "Hoosright!", message: "Enter a email address", fromController: self)
            
            return false
        }
        else if usernameTxt.text!.isEmpty
        {
            self.validator.showAlert(title: "Hoosright!", message: "Enter a vaild username", fromController: self)
            return false
        }
        else if nameText.text!.isEmpty
        {
            self.validator.showAlert(title: "Hoosright!", message: "Enter a vaild name", fromController: self)
            return false
        }
        else if passwordText.text!.isEmpty
        {
            
            self.validator.showAlert(title: "Hoosright!", message: "Please enter  password.", fromController: self)
            return false
        }
        else if confirmpassText.text!.isEmpty
        {
            
            self.validator.showAlert(title: "Hoosright!", message: "Please enter confirm password.", fromController: self)
            return false
        }
        else if (selectedImage == nil)
        {
            
            self.validator.showAlert(title: "Hoosright!", message: "Please add profile image", fromController: self)
            return false
        }
        else
        {
            
            
            if !self.validator.isValidEmail(testStr: emailAddressTxt.text!)
            {
                self.validator.showAlert(title: "Hoosright!", message: "Enter a vaild email address", fromController: self)
                return false
            }
                
            else if !self.validator.isPwdLenth(password: passwordText.text!, confirmPassword: confirmpassText.text!)
            {
                self.validator.showAlert(title: "Hoosright!", message: "Your password must have atleast 6 digit.", fromController: self)
                return false
            }
                
            else if !self.validator.isPasswordSame(password: passwordText.text!, confirmPassword: confirmpassText.text!)
            {
                self.validator.showAlert(title: "Hoosright!", message: "Your password dosen't match.", fromController: self)
                return false
            }
            else
            {
                return true
            }
            
        }
        
    }


    @IBAction func submit(_ sender: Any) {
         if self.RagistationValidation() {
        startAnimating(ConstantsAPI.size, message: "Loading...",type: .ballClipRotate)
            requestManger.uploadSingelImage(image: selectedImage!, onCompletion: {
                json, error ->Void in
                if let JSON = json?.result.value {
                    print("Success::\(JSON)")
                    let username = self.usernameTxt.text!
                    let email = self.emailAddressTxt.text!
                    let password = self.passwordText.text!
                    let name = self.nameText.text!
                    let parameters = [
                        "uname"    : username,
                        "email" : email,
                        "pwd" : password,
                        "img_path" : "\(ConstantsAPI.HoosRightServer)\(JSON)",
                        "name" : name
                    ]
                    print("Parameter:::\(parameters)")
                    let apiPath:String = "\(ConstantsAPI.HoosRightServer)\(ConstantsAPI.Register)"
                    self.requestManger.postRandomPosts(path: apiPath, Parameters: parameters as [String : AnyObject]!, onCompletion: {
                        json ->Void in
                        let index = json[0]["status"]
                        switch index {
                        case 0  :
                            self.validator.showAlert(title: "Hoosright!", message: json[0]["msg"].stringValue, fromController: self)
                        case 1  :
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let controller = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
                            self.present(controller, animated: true, completion: nil)
                        default :
                            self.validator.showAlert(title: "Hoosright!", message: "Something went wrong", fromController: self)
                            break
                        }
                        
                    })
                }
                    
                    
                else {
                    print("Rajesh!!!\(error)")
                    
                }
                
                self.stopAnimating()
                
            })

            
        }
         else {
            
        }
        
    }

}
