//
//  Message.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/12.
//

import UIKit


struct Message: Codable{
    let sender: String?
    let time: Int?
    let type: String?
    let content: String?
    var readUsers: [String: String]?
    
    func toDictionary() -> [String: Any]{
        var dictionary = [String: Any]()
        
        dictionary["sender"] = sender ?? ""
        dictionary["time"] = time ?? ""
        dictionary["type"] = type ?? ""
        dictionary["content"] = content ?? ""
        dictionary["readUsers"] = readUsers ?? [String: String]()
        
        return dictionary
    }
}
