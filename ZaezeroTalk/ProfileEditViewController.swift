//
//  ProfileEditViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/17.
//

import UIKit

class ProfileEditViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.text = ConnectedUser.shared.user.userInfo.name
        }
    }
    @IBOutlet weak var stateMessageButton: UIButton! {
        didSet {
            if oldStateMessage.count != 0 {
                //stateMessageButton.titleLabel?.text = oldStateMessage
                stateMessageButton.setTitle(oldStateMessage, for: .normal)
            } else {
                //stateMessageButton.titleLabel?.text = "상태 메시지를 입력해 주세요."
                stateMessageButton.setTitle("상태 메시지를 입력해 주세요.", for: .normal)
            }
            
        }
    }
    let oldStateMessage = ConnectedUser.shared.user.userInfo.stateMessage
    var newStateMessage: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func clickEditStateMessageButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "EditStateMessageViewController", bundle: nil)
        let editStateMessageVC = storyboard.instantiateViewController(withIdentifier: "EditStateMessageViewController") as! EditStateMessageViewController
        editStateMessageVC.modalPresentationStyle = .overFullScreen
        editStateMessageVC.doneCallback = {
            statemessage in
            self.newStateMessage = statemessage
            if let newStateMessage = self.newStateMessage , newStateMessage.count > 0{
                self.stateMessageButton.setTitle(newStateMessage, for: .normal)
            }
        }
        present(editStateMessageVC, animated: false, completion: nil)
    }
    
    @IBAction func clickCancleButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickDoneButton(_ sender: Any) {
        
        guard let newStateMessage = newStateMessage, newStateMessage.count > 0 else { return } // 변경할 상태메시지를 입력하지 않았을 경우
        
        if oldStateMessage != newStateMessage {
            DatabaseManager.shared.updateChildValues(["stateMessage": newStateMessage],forPath: "Users/\(ConnectedUser.shared.uid)/userInfo") {
                _, _ in
                self.dismiss(animated: false, completion: nil)
            }
        }
        
        dismiss(animated: false, completion: nil)
    }
    
}
