//
//  SetGroupChatingRoomInfoViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/29.
//

import UIKit

class SetGroupChatingRoomInfoViewController: UIViewController {

    @IBOutlet weak var roomNameTextField: UITextField! {
        didSet {
            roomNameTextField.placeholder = selectedFriends.map({ _,info in
                info.name
            }).joined(separator: ",")
        }
    }
    
    var selectedFriends = [(uid: String,info: UserInfo)]()
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backButtonTitle = ""
        navigationItem.title = "그룹채팅방 정보 설정"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(clickConfirmButton))
    }
}

extension SetGroupChatingRoomInfoViewController {
    
    /// 확인 버튼 클릭 이벤트
    /// - Parameter sender: 확인 바 버튼
    @objc func clickConfirmButton(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "ChatingRoomViewController", bundle: nil)
        let chatingRoomVC = storyboard.instantiateViewController(withIdentifier: "ChatingRoomViewController") as! ChatingRoomViewController
        
        chatingRoomVC.participantUids = selectedFriends.map({ uid,_ in
            uid
        })
        chatingRoomVC.participantUids.append(ConnectedUser.shared.uid)
        
        chatingRoomVC.roomName = roomNameTextField.text
        chatingRoomVC.modalPresentationStyle = .fullScreen
        weak var presentingVC = presentingViewController
        dismiss(animated: true, completion: {
            presentingVC?.present(chatingRoomVC, animated: true, completion: nil)
        })
    }
}
