//
//  ChatingRoom.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/12.
//

import Foundation

struct ChatingRoom {
    let participants: [String: Bool]
    let id: String
    let name: String
    let messages = [Message]()
}