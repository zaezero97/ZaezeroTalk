//
//  UserModel.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/09.
//

import Foundation


struct User: Codable{
    var userInfo: UserInfo
    var friends : [String: UserInfo]?
}
