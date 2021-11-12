//
//  Message.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/12.
//

import Foundation

enum MessageType {
    case Text
    case Image
}
struct Message {
    let sender: String
    let time: [AnyHashable: Any]
    let isread: Bool
    let type: MessageType
    let content: String
}
