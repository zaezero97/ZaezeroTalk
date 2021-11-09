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
    
    func insertUser(user : User){
        ref.child("Users").child(user.uid).setValue(["name": user.displayName,"email": user.email,"friend_count": 0])
    }
    func registerFriendsOberver(of uid: String , completion: @escaping (DataSnapshot) -> Void){
        
        ref.child("Friends/\(uid)").observe(DataEventType.value, with: {
            (snapshot) in
            
            completion(snapshot)
            print(snapshot)
            print(snapshot.value)
        })
    }
    func fetchCurrentUserInfo(uid: String ,with completion : @escaping (DataSnapshot) -> Void) {
        
        ref.child("Users/\(uid)").observeSingleEvent(of: .value, with: completion)
    }
}
