//
//  EditProfileVC.swift
//  HoosRight
//
//  Created by ios on 15/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit
import SDWebImage
import SkyFloatingLabelTextField

class EditProfileVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var profileTable: UITableView!
    @IBOutlet weak var profileImage: CustomImageView!
    let details:Dictionary = UserDefaults.standard.dictionary(forKey: "UserLoginDetails")!
    var userProfileImage:String!
    var list = [String]()
    var listItems = [ListItem]()
    override func viewDidLoad() {
        super.viewDidLoad()
        print(details)
       list = ["\(details["name"] as! String)", "\(details["user_name"] as! String)", "\(details["website"] as! String)", "\(details["bio"] as! String)", "\(details["address"] as! String)", "\(details["email_id"] as! String)"]
        userProfileImage = details["prof_image"] as! String
        self.navigationItem.title = "Edit Profile"
        profileImage.sd_setImage(with: NSURL(string:userProfileImage) as URL!, placeholderImage: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(addTapped))
        profileTable.register(editCell.self, forCellReuseIdentifier: "procell")
         listItems += [ListItem(text: "Name"), ListItem(text: "Username"), ListItem(text: "Website"), ListItem(text: "Bio"), ListItem(text: "Address"),ListItem(text: "Email")]
        self.hideKeyboardWhenTappedAround()

    }

    func addTapped(sender: UIBarButtonItem) {
    
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return listItems.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let noteCell:editCell  = tableView.dequeueReusableCell(withIdentifier: "procell", for: indexPath) as! editCell
        let item = listItems[indexPath.row]
        noteCell.listItems = item
        noteCell.label.text = list[indexPath.row]
        noteCell.selectionStyle = UITableViewCellSelectionStyle.none
        return noteCell
       }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
        
    }
}


class editCell: UITableViewCell, UITextFieldDelegate {
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label:SkyFloatingLabelTextField
    
    var listItems:ListItem? {
        didSet {
            label.placeholder = listItems!.text
           
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // 1
        label = SkyFloatingLabelTextField(frame: CGRect.null)
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 16)
        label.lineHeight = 1.0 // bottom line height in points
        label.selectedLineHeight = 2.0
        label.selectedTitleColor = ConstantsAPI.backgroundColor

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // 2
        label.delegate = self
        label.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        label.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        label.textAlignment = .center
        // 3
        addSubview(label)
        
    }
    
    let leftMarginForLabel: CGFloat = 15.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: leftMarginForLabel, y: 0, width: bounds.size.width - leftMarginForLabel, height: bounds.size.height)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if listItems != nil {
            listItems?.text = textField.text!
        }
        return true
    }
}


class ListItem: NSObject {
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
}

