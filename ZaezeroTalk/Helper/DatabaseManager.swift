//
//  DatabaseManager.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/08.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
class DatabaseManager{
    static let shared = DatabaseManager()
    private let ref = Database.database().reference()
    private init(){
        
    }
    func saveUserInfo(info: Any?){
        let UserInfo = info as? NSDictionary
        let userName = UserInfo?["name"] as? String ?? ""
        let email = UserInfo?["email"] as? String ?? ""
        ConnectedUser.shared.Info = UserModel(email: email, name: userName)
    }
    func insert(_ value: [String: Any], forPath path: String){
        ref.child(path).setValue(value)
    }
    
    func fetchUserInfoByEmail(email : String ,completion : @escaping (DataSnapshot) -> Void){
        let query = ref.child("Users").queryOrdered(byChild: "email").queryEqual(toValue: email)
        query.observeSingleEvent(of: .value,with: completion)
    }
    func fetchUserInfoByUid(uid: String, completion : @escaping () -> Void){
        ref.child("Users/\(uid)/UserInfo").observeSingleEvent(of: .value, with: {
            snapshot in
            let fetchedUserInfo = snapshot.value as? NSDictionary
            let userName = fetchedUserInfo?["name"] as? String ?? ""
            let email = fetchedUserInfo?["email"] as? String ?? ""
            ConnectedUser.shared.Info = UserModel(email: email, name: userName)
            completion()
        })
    }
    func registerUserInfoObserver(forUid uid: String){
        ref.child("Users/\(uid)/UserInfo").observe(.value, with: {
            snapshot in
            let fetchedUserInfo = snapshot.value as? NSDictionary
            let userName = fetchedUserInfo?["name"] as? String ?? ""
            let email = fetchedUserInfo?["email"] as? String ?? ""
            ConnectedUser.shared.Info = UserModel(email: email, name: userName)
        })
    }
    func registerFriendsOfUserObserver(forUid uid: String){
        ref.child("Users/\(uid)/Friends").observe(.value, with: {
            snapshot in
            let fetchedFriends = snapshot.value as? NSDictionary
            let friendCount = fetchedFriends?["friendCount"] as? Int ?? 0
            ConnectedUser.shared.friendCount = friendCount
            print(fetchedFriends)
            if let keys = fetchedFriends?.allKeys {
                if keys.count > 1 {
                    for key in keys {
                        let friendInfo = fetchedFriends?[key] as? NSDictionary
                        let friendName = friendInfo?["name"] as? String ?? ""
                        let email = friendInfo?["email"] as? String ?? ""
                        ConnectedUser.shared.friends?.append(UserModel(email: email, name: friendName))
                    }
                }
            }
            
        })
    }
}
