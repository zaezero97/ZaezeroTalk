//
//  CurrentUser.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/10.
//

import Foundation

class ConnectedUser {
    static let shared = ConnectedUser()
    var user : User!
    private init() {
        
    }
}
