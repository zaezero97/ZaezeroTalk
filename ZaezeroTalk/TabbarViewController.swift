//
//  TabbarViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/08.
//

import UIKit
import Firebase
class TabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
        DatabaseManager.shared.registerRoomListObserver(uid: ConnectedUser.shared.uid, completion: {
            rooms in
            guard let rooms = rooms else {
                return
            }
            ConnectedUser.shared.chatingRoomList = rooms
        })
    }
}
