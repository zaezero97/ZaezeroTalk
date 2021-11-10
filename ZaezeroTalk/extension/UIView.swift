//
//  UIView.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/10.
//

import UIKit
extension UIView {
    static func loadViewFromNib(nib: String) -> UIView {
        let nib = UINib(nibName: nib, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}
