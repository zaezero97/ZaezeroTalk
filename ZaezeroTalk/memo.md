#  <#Title#>


uid  = {
    email : value
    frind_count : 0
    name : value
}

->

uid ={
     UserInfo ={
    email : value
    name : value
    },
    Friends = {
        friendCount : value,
        uid : {
        email : value
        name : value
        }
    } 
}


chating room 

autoid = {
    participants = {
        
}
}


현재
채팅방에 입장하면
먼저 데이터를 가져와야겠지
근데 만약 새로운 방이면 데이터가 없다
근데 데이터로 옵저버를 등록해야하는데
어떻게해야할까


                DatabaseManager.shared.fetchUserByUid(uid: result.user.uid, completion: {
                    user in
                    
                    let userInfo = user?["userInfo"] as? [String: Any]
                    let friends = user?["friends"] as? [String: Any]
                    
                    let email = userInfo?["email"] as? String ?? ""
                    let name = userInfo?["name"] as? String ?? ""
                    var friend_arr = [Friend]()
                    if let friends = friends {
                        for key in friends.keys {
                            let friendInfo = friends[key] as? [String: Any]
                            let friendEmail = friendInfo?["email"] as? String ?? ""
                            let friendName = friendInfo?["name"] as? String ?? ""
                            friend_arr.append(Friend(uid: key, email: friendEmail, name: friendName))
                        }
                    }
                    ConnectedUser.shared.user = User(uid: result.user.uid, userInfo: UserInfo(email: email, name: name), friends: friend_arr)
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                        let storyboard = UIStoryboard(name: "TabbarViewController", bundle: nil)
                        let TabbarVC = storyboard.instantiateViewController(withIdentifier: "TabbarViewController")
                        TabbarVC.modalPresentationStyle = .fullScreen
                        self.present(TabbarVC, animated: true,completion: {
                            DatabaseManager.shared.registerUserInfoObserver(forUid: result.user.uid) // 로그인 성공시 유저의 정보가 변경될 때 마다 비동기적으로 가져올 수 있는 옵저버 등록
                            DatabaseManager.shared.registerFriendsOfUserObserver(forUid: result.user.uid)
                        })
                    }
                })



        DatabaseManager.shared.fetchUserInfoWithUidByEmail(email: searchEmail,completion: {
            userInfo,uid in
            guard let userInfo = userInfo else {
                self.searchByEmailResultView.isHidden = true
                self.searchByEmailResultLabel.isHidden = false
                return
            }
            
            let name = userInfo["name"] as? String ?? ""
            self.searchedUserInfo = userInfo
            self.searchedUserUid = uid
            self.searchByEmailResultView.nameLabel.text = name
            self.searchByEmailResultView.addFriendButton.isEnabled = false
            self.searchByEmailResultLabel.isHidden = true
            self.searchByEmailResultView.isHidden = false
            
            DatabaseManager.shared.findFriend(by: self.searchedUserUid!, completion: {
                (isExisted) in
                DispatchQueue.main.async {
                    if isExisted {
                        self.searchByEmailResultView.addFriendButton.isEnabled = false
                    } else {
                        self.searchByEmailResultView.addFriendButton.isEnabled = true
                    }
                }
                
            })
            
        })



            let underlayer = CALayer()
            underlayer.frame = CGRect(x: 0, y: stateMessageTextField.bounds.height + 5, width: stateMessageTextField.bounds.width, height: 1)
            underlayer.backgroundColor = UIColor.red.cgColor
            underlayer.cornerRadius = 1
