//
//  UIImageView.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/18.
//

import Foundation
import UIKit
import Photos

extension UIImageView {
    func loadImage(asset:PHAsset?){
        guard let asset = asset else {
            return
        }
        let imageManager = PHImageManager()
        let scale = UIScreen.main.scale
        let imageSize = CGSize(width: 150 * scale, height: 150 * scale)
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options) { image, info in
            /*
             if (info?[PHImageResultIsDegradedKey] as? Bool) == true{
                self.photoImageView.image = image //저화질
            }else{
                //고화질
            } //option에서 deliveryMode 를 fastFormat으로 값을 설정하면 info dic에서 PHImageResultIsDegradedKey값이 1일줄 알았는데 0 이 나왔다.
             // 질문을 해보니 PHImageResultIsDegradedKey 값이 1 이라는 의미는 지금 주는 건 저화질의 이미지이고 고화질로 한번 더 주겠다 라는 의미 라고 한다.
             //따라서 fastFormat은 저화질로 한번만 주기 때문에 값이 0이다.
             */
            self.layer.cornerRadius = self.frame.width / 2
            self.layer.masksToBounds = true
            self.layer.borderWidth = 2
            self.image = image
        }
    }
}
