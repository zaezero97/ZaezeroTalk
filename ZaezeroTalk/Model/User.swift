//
//  UserModel.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/09.
//

import Foundation


struct User{
    var uid: String
    var userInfo: UserInfo
    var friends = [Friend]()
}
