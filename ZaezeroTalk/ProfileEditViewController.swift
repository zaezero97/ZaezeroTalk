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
            if let stateMessage = oldStateMessage {
                stateMessageButton.titleLabel?.text = stateMessage
            } else {
                stateMessageButton.titleLabel?.text = "상태 메시지를 입력해 주세요."
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
        editStateMessageVC.modalPresentationStyle = .overCurrentContext
        editStateMessageVC.doneCallback = {
            statemessage in
            self.newStateMessage = statemessage
            if let newStateMessage = statemessage {
                self.stateMessageButton.titleLabel!.text = newStateMessage
            } else {
                self.stateMessageButton.titleLabel!.text = "상태 메시지를 입력해 주세요."
            }
        }
        present(editStateMessageVC, animated: false, completion: nil)
    }
    
    @IBAction func clickCancleButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickDoneButton(_ sender: Any) {
        if let oldStateMessage = oldStateMessage {
            if let newStateMessage = newStateMessage {
                if oldStateMessage != newStateMessage {
                    DatabaseManager.shared.updateChildValues(["stateMessage": newStateMessage],forPath: "Users/\(ConnectedUser.shared.uid)/userInfo") {
                        _, _ in
                        self.dismiss(animated: false, completion: nil)
                    }
                }
            }
        } else {
            if let newStateMessage = newStateMessage {
                DatabaseManager.shared.updateChildValues(["stateMessage": newStateMessage],forPath: "Users/\(ConnectedUser.shared.uid)/userInfo") {
                    _, _ in
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
        dismiss(animated: false, completion: nil)
    }
    
}
