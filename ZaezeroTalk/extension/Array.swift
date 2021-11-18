//
//  Array.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/18.
//

import Foundation

extension Array where Element == String{
    func toFBString() -> String{
        return self.joined(separator: "@spr@")
    }
}
