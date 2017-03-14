//
//  PrivacyVC.swift
//  HoosRight
//
//  Created by ios on 15/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit

class PrivacyVC: UIViewController {
    
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Privacy Policy"
        webView.loadRequest(URLRequest(url: URL(string: "\(ConstantsAPI.HoosRightServer)privacy_policy.html")!))
    }



}
