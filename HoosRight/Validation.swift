//
//  Validation.swift
//  HossRight
//
//  Created by ios on 06/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import Foundation
import GSMessages


class Validation: NSObject {




    func showAlert(title:String,message:String,fromController controller: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        controller.present(alertController, animated: true, completion: nil)
        
    }

    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isPwdLenth(password: String , confirmPassword : String) -> Bool {
        
        if password.characters.count >= 6 && confirmPassword.characters.count >= 6{
            return true
        }
        else{
            return false
        }
    }
    
    
    func isPasswordSame(password: String , confirmPassword : String) -> Bool {
        if password == confirmPassword{
            return true
        }
        else{
            return false
        }
    }

    
    
    func showGSMessage (message:String,fromController controller: UIView,typeOfStyle type:GSMessageType) {
        DispatchQueue.main.async(){
            controller.showMessage(message, type: type, options:[
                .animation(.slide),
                .animationDuration(0.5),
                .autoHide(true),
                .autoHideDelay(3.0),
                .height(33.0),
                .hideOnTap(true),
                .position(.top),
                .textAlignment(.center),
                .textColor(UIColor.white),
                .textNumberOfLines(1),
                .textPadding(30.0)
                ])
         GSMessage.errorBackgroundColor   = UIColor.black
        }
        
    }

}
