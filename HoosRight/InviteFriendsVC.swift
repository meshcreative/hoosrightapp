//
//  InviteFriendsVC.swift
//  HoosRight
//
//  Created by ios on 17/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit


class InviteFriendsVC: UIViewController {

    @IBOutlet weak var copyTextLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.copyTextLabel.copyingEnabled = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
