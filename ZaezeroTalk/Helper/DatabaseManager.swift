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
    let ref = Database.database().reference()
    private init(){
        
    }
    
    func setValue(_ value: [String: Any], forPath path: String){
        ref.child(path).setValue(value)
    }
    
    func updateChildValues(_ value: [String: Any], forPath path: String){
        ref.child(path).updateChildValues(value)
    }
    func updateChildValues(_ value: [String: Any], forPath path: String, completion: @escaping (Error?,DatabaseReference)-> Void){
        ref.child(path).updateChildValues(value,withCompletionBlock: completion)
    }
    func fetchUserInfoWithUidByEmail(email : String ,completion : @escaping ([String: Any]?,String) -> Void){
        ref.child("Users").observeSingleEvent(of: .value,with: {
            snapshot in
            for child in snapshot.children
            {
                let child = child as! DataSnapshot
                let user = child.value as? [String: Any]
                let userInfo = user?["UserInfo"] as? [String: Any]
                if email == userInfo?["email"] as? String ?? "" {
                    completion(userInfo,child.key)
                    return
                }
            }
            completion(nil,"")
        })
    }
    
    func fetchUserByUid(uid: String, completion : @escaping ([String: Any]?) -> Void) {
        ref.child("Users/\(uid)").observeSingleEvent(of: .value, with: {
            snapshot in
            let user = snapshot.value as? [String: Any]
            completion(user)
        })
    }
    func fetchUserInfoByUid(uid: String, completion : @escaping ([String: Any]?) -> Void){
        ref.child("Users/\(uid)/UserInfo").observeSingleEvent(of: .value, with: {
            snapshot in
            let userInfo = snapshot.value as? [String: Any]
            completion(userInfo)
        })
    }
    func registerUserInfoObserver(forUid uid: String){
        ref.child("Users/\(uid)/UserInfo").observe(.value, with: {
            snapshot in
            let userInfo = snapshot.value as? [String: Any]
            let email = userInfo?["email"] as? String ?? ""
            let name = userInfo?["name"] as? String ?? ""
            ConnectedUser.shared.user.userInfo = UserInfo(email: email, name: name)
        })
    }
    func registerFriendsOfUserObserver(forUid uid: String){
        ref.child("Users/\(uid)/Friends").observe(.value, with: {
            snapshot in
            let fetchedFriends = snapshot.value as? [String: Any]
            
            guard let fetchedFriends = fetchedFriends else { return }
            let keys = fetchedFriends.keys
            var friend_arr = [Friend]()
            if snapshot.exists() {
                for key in keys {
                    let friendInfo = fetchedFriends[key] as! [String: Any]
                    let friendName = friendInfo["name"] as! String
                    let email = friendInfo["email"] as! String
                    friend_arr.append(Friend(uid: key, email: email, name: friendName))
                }
                ConnectedUser.shared.user.friends = friend_arr
            }
            
        })
    }
    func findFriend(by FriendUid: String, completion: @escaping (Bool) -> Void) {
       
        ref.child("Users/\(ConnectedUser.shared.user.uid)/Friends/\(FriendUid)").observeSingleEvent(of: .value, with: {
            (snapshot) in
            print(snapshot.value)
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
}
