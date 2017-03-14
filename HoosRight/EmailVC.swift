//
//  EmailVC.swift
//  HossRight
//
//  Created by ios on 03/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class EmailVC: UIViewController, UITextFieldDelegate  {
    

    @IBOutlet weak var emailAddressTxt: SkyFloatingLabelTextField!
    let validator = Validation()
    
    
    override func viewWillAppear(_ animated: Bool) {
   self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField
        {
        case emailAddressTxt:
            self.submit(self)
            textField.becomeFirstResponder()
            break
        default:
            self.submit(self)
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

    @IBAction func loginViaFB(_ sender: Any) {
        
    }
    
    
    @IBAction func submit(_ sender: Any) {
        
        let emailAddress = self.emailAddressTxt!.text!
        let validLogin = self.validator.isValidEmail(testStr: emailAddress)
        if validLogin {
           self.performSegue(withIdentifier: "register", sender: self)
        } else {
            self.validator.showAlert(title: "Hoosright!", message: "Enter a vaild email address", fromController: self)
        }
    }
    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "register"{
            let vc = segue.destination as! RegisterVC
            vc.emailAddress = self.emailAddressTxt.text! as String
            
        }
    }
}
