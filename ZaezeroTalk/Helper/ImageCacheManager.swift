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
    
    static func cachingImage(url: String) {
        DispatchQueue.main.async {
            let cachedKey = NSString(string: url)
            if ImageCacheManager.shared.object(forKey: cachedKey) != nil {
                return
            }
            guard let url = URL(string: url) else { return }
            URLSession.shared.dataTask(with: url) { (data, result, error) in
                guard error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        /// 캐싱
                        ImageCacheManager.shared.setObject(image, forKey: cachedKey)
                        
                    }
                }
            }.resume()
        }
        
    }
}
