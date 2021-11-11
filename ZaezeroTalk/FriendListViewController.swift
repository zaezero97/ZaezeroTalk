//
//  FriendViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/09.
//

import UIKit
import Firebase
class FriendListViewController: UIViewController {

    
    @IBOutlet weak var customNavigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var friendListTableView: UITableView!
    var Friends = [UserModel]()
    var userInfo: UserModel?
    lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "친구"
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendListTableView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
        
        friendListTableView.dataSource = self
        friendListTableView.delegate = self
        customNavigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        
        
        if let currentUser = Auth.auth().currentUser  {
            let userInfo = DatabaseManager.shared.fetchUserInfoByUid(uid: currentUser.uid, with: {
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
    @IBAction func clickAddFriendButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AddFriendViewController", bundle: nil)
        let addFriendVC = storyboard.instantiateViewController(withIdentifier: "AddFriendViewController") as! AddFriendViewController
        
        addFriendVC.myEmail = userInfo?.email ?? ""
        addFriendVC.modalPresentationStyle = .fullScreen
        present(addFriendVC, animated: true, completion: nil)
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

extension FriendListViewController{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            customNavigationBar.standardAppearance.shadowColor = .gray
        }else{
            customNavigationBar.standardAppearance.shadowColor = .white
        }
    }
}

