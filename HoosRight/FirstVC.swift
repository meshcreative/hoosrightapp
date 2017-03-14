//
//  FirstVC.swift
//  HossRight
//
//  Created by ios on 03/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit

class FirstVC: UIViewController {


    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        loginBtn.backgroundColor = UIColor.white
        loginBtn.layer.cornerRadius = 20
        loginBtn.layer.borderWidth = 2
        loginBtn.layer.borderColor = UIColor.clear.cgColor
        
        registerBtn.backgroundColor = .clear
        registerBtn.layer.cornerRadius = 20
        registerBtn.layer.borderWidth = 2
        registerBtn.layer.borderColor = UIColor.white.cgColor
    }
}



extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
