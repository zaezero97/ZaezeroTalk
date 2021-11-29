//
//  String.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/18.
//

import Foundation
import UIKit

extension String {
    func toFBArray() -> [String]{
        return self.components(separatedBy: "@spr@")
    }
   
}
