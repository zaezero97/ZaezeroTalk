//
//  ImageCacheManager.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/12/02.
//

import Foundation
import UIKit

class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    
    private init() {
        
    }
}
