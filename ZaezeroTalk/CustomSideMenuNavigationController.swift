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
        var set = SideMenuSettings()
       
        set.statusBarEndAlpha = 0
        set.presentationStyle = .menuSlideIn
        set.presentationStyle.presentingEndAlpha = 0.3
        self.settings = set
        menuWidth = self.view.frame.width * 0.7
    }
}
