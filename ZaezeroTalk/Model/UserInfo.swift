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
    var stateMessage: String? {
        didSet {
            print("stateMessage Change !!!",stateMessage)
        }
    }
    func toDictionary() -> [String: Any] {
        return ["email": email, "name": name]
    }
}
