//
//  DatabaseManager.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/08.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
final class DatabaseManager{
    static let shared = DatabaseManager()
    private let ref = Database.database().reference()
    private init(){
        
    }
    
    func insertUser(user : User){
        ref.child("Users").child(user.uid).setValue(["name":user.displayName,"email":user.email])
    }
}
