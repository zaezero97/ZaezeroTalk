//
//  UserInfo.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/12.
//

import Foundation

struct UserInfo: Codable {
    let email: String
    var name: String
    var stateMessage: String?
    var profileImageUrl: String?
    
    func toDictionary() -> [String: Any] {
        var dic = ["email": email, "name": name]
        if let stateMessage = stateMessage {
            dic["stateMessage"] = stateMessage
        }
        if let profileImageUrl = profileImageUrl {
            dic["profileImageUrl"] = profileImageUrl
        }
        return dic
    }
}
