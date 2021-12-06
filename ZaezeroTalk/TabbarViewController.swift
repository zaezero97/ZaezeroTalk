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
        
        /// RoomList Observer 등록
        DatabaseManager.shared.registerRoomListObserver(addCompletion: {
            roomId,room in
            guard let room = room else { return }
            ConnectedUser.shared.chatingRoomList.removeAll(where: {
                id, _ in
                id == roomId
            })
            ConnectedUser.shared.chatingRoomList.append((id: roomId, info: room))
        },removeCompletion: {
            roomId in
            ConnectedUser.shared.chatingRoomList.removeAll { id,room in
                if (id == roomId) {
                    return true
                } else {
                    return false
                }
            }
        })
        
        /// TabbarController를 rootViewController로 지정
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
        sceneDelegate.window?.rootViewController = self
    }
}

