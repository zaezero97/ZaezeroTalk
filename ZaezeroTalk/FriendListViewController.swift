//
//  FriendViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/09.
//

import UIKit
import Firebase
class FriendListViewController: UIViewController {

    var Friends = [UserModel]()
    var userInfo : UserModel?
    override func viewDidLoad() {
        super.viewDidLoad()
            
        if let currentUser = Auth.auth().currentUser  {
            let userInfo = DatabaseManager.shared.fetchCurrentUserInfo(uid: currentUser.uid, with: {
                (snapshot) in
                let fetchedUserInfo = snapshot.value as? NSDictionary
                let userName = fetchedUserInfo?["name"] as? String ?? ""
                let friendCount = fetchedUserInfo?["friendCount"] as? Int ?? 0
                let email = fetchedUserInfo?["email"] as? String ?? ""
                
                self.userInfo = UserModel(email: email, name: userName, friendCount: friendCount)
            })
            
            DatabaseManager.shared.registerFriendsOberver(of: currentUser.uid, completion: {
                (snapshot) in
                for child in snapshot.children {
                    let friend = child as! DataSnapshot
                    let friendInfo = friend.value as? NSDictionary
                    let friendName = friendInfo?["name"] as? String ?? ""
                    let friendEmail = friendInfo?["email"] as? String ?? ""
                    
                    self.Friends.append(UserModel(email: friendEmail, name: friendName))
                }
            })
        }
        
        
    }
}

