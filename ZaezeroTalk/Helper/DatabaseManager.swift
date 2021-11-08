//
//  DatabaseManager.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/08.
//

import Foundation
import FirebaseDatabase

final class DataManager{
    static let shared = DataManager()
    private let ref = Database.database().reference()
    private init(){
        
    }
}
