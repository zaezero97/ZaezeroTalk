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
    
    
    func insert(_ value: [String: Any], forPath path: String){
        ref.child(path).setValue(value)
    }
    func registerFriendsOberver(of uid: String , completion: @escaping (DataSnapshot) -> Void){
        
        ref.child("Friends/\(uid)").observe(DataEventType.value, with: {
            (snapshot) in
            
            completion(snapshot)
            print(snapshot)
            print(snapshot.value)
        })
    }
    func fetchUserInfoByUid(uid: String ,with completion : @escaping (DataSnapshot) -> Void) {
        ref.child("Users/\(uid)").observeSingleEvent(of: .value, with: completion)
    }
    
    func fetchUserInfoByEmail(email : String ,completion : @escaping (DataSnapshot) -> Void){
        let query = ref.child("Users").queryOrdered(byChild: "email").queryEqual(toValue: email)
        query.observeSingleEvent(of: .value,with: completion)
    }
    func registerUserInfoOberver(forUid uid: String){
        ref.child("Users/\(uid)").observe(.value, with: {
            snapshot in
            let fetchedUserInfo = snapshot.value as? NSDictionary
            let userName = fetchedUserInfo?["name"] as? String ?? ""
            let friendCount = fetchedUserInfo?["friendCount"] as? Int ?? 0
            let email = fetchedUserInfo?["email"] as? String ?? ""
            ConnectedUser.shared.Info = UserModel(email: email, name: userName, friendCount: friendCount)
        })
    }
}
