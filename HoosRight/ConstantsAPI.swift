//
//  ConstantsAPI.swift
//  HossRight
//
//  Created by ios on 06/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import Foundation

class ConstantsAPI: NSObject {
    
    static let sharedInstance = ConstantsAPI()
    static let size = CGSize(width: 30, height:30)
    static let backgroundColor = UIColor(red: CGFloat(237 / 255.0), green: CGFloat(85 / 255.0), blue: CGFloat(101 / 255.0), alpha: 1)
    static let HoosRightServer = "http://192.169.201.70/~hoosright/hoosrightapp/"
    static let Password_Reset = "send_password_reset_mail.php"
    static let login = "login.php"
    static let Register = "register.php"
    static let FBRegister = "facebook_register.php"
    static let ImageUpload = "imageUpload.php"
    static let postLike = "post_like.php"
    static let postUnlike = "post_unlike.php"
    static let notificationAPI = "get_notification.php"
    static let postdetailsAPI = "post_details_all.php"
    static let changePasswordAPI = "change_password.php"
    static let privateAPI = "change_settings.php"
    static let userProfileAPI = "user_profile.php"
    static let deletPostAPI = "post_delete.php"
    static let followFriendAPI = "follow_friend.php"
    static let UnfollowFriendAPI = "unfollow_friend.php"
    static let friendsAPI = "my_friends.php"
    static let friendsSearchAPI = "friend_search.php"
    
    
}

