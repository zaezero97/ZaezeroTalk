//
//  UserModel.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/09.
//

import Foundation


struct UserModel {
    var email: String
    var name: String
    //var profilePhoto: URL
    
    init(email: String, name: String) {
        self.email = email
        self.name = name
    }
    
}
