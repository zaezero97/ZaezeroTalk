//
//  Message.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/12.
//

import UIKit

enum MessageType: String{
    case Text
    case Image
}
struct Message: Codable{
    let sender: String
    let time: Int
    let readUsers: [String: Any]
    let type: String
    let content: String
}
