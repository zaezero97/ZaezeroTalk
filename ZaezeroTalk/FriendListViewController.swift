//
//  FriendViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/09.
//

import UIKit
import Firebase
class FriendListViewController: UIViewController {

    @IBOutlet weak var friendListTableView: UITableView!
    var Friends = [UserModel]()
    var userInfo : UserModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendListTableView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
        
        
        friendListTableView.dataSource = self
        friendListTableView.delegate = self
        
        
        if let currentUser = Auth.auth().currentUser  {
            let userInfo = DatabaseManager.shared.fetchCurrentUserInfo(uid: currentUser.uid, with: {
                (snapshot) in
                let fetchedUserInfo = snapshot.value as? NSDictionary
                let userName = fetchedUserInfo?["name"] as? String ?? ""
                let friendCount = fetchedUserInfo?["friendCount"] as? Int ?? 0
                let email = fetchedUserInfo?["email"] as? String ?? ""
                self.userInfo = UserModel(email: email, name: userName, friendCount: friendCount)
                
                self.friendListTableView.reloadData()
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



// MARK: - TableView Datasoruce , Delegate
extension FriendListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        
        cell.nameLabel.text = userInfo?.name
       
        return cell
    }
    
    
}
extension FriendListViewController: UITableViewDelegate{
    
}