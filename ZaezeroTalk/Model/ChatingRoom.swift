//
//  ChatingRoom.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/12.
//

import Foundation

struct ChatingRoom: Codable{
    var participants: [String: Any]
    var name: String
    var messages: Message?
    
    enum CodingKeys: String,CodingKeys {
        case participants
        case name
        case messages = "messages"
    }
}
