//
//  ChatingRoom.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/12.
//

import Foundation

struct ChatingRoom: Codable{
    //var participants: [String: String]
    var userNames: String
    var uids: String
    var name: String
    var messages: [String: Message]?
    var lastMessage: String
    var lastMessageTime: Int
}
