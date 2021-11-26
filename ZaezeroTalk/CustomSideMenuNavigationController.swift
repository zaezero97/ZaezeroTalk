//
//  SideMenuViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/24.
//

import UIKit
import SideMenu

class CustomSideMenuNavigationController: SideMenuNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        presentationStyle = .menuSlideIn
        menuWidth = self.view.frame.width * 0.7
    }
}
