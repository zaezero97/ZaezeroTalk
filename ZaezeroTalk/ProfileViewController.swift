//
//  ProfileViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/11.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var stateMessageLabel: UILabel!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            
        }
    }
    @IBOutlet weak var toolBar: UIToolbar! {
        didSet {
        }
    }
    @IBOutlet weak var customNavigationBar: UINavigationBar! {
        didSet {
            customNavigationBar.standardAppearance.shadowColor = .white
        }
    }
    
    
    var selectedFriendUid: String?
    var fetchedUserInfo: UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedFriendUid != ConnectedUser.shared.uid {
            var toolbarItems = toolBar.items
            toolbarItems?.removeLast()
            toolbarItems?.removeLast()
            toolBar.items = toolbarItems
        }
        
        DatabaseManager.shared.fetchUserInfo(uid: selectedFriendUid!, completion: {
            userInfo in
            guard let userInfo = userInfo else {
                return
            }
            self.fetchedUserInfo = userInfo
            
            if self.selectedFriendUid != ConnectedUser.shared.uid {
                self.profileNameLabel.text = userInfo.name
            } else {
                self.profileNameLabel.text = ConnectedUser.shared.user.userInfo.name
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.selectedFriendUid != ConnectedUser.shared.uid {
            stateMessageLabel.text = fetchedUserInfo?.stateMessage ?? ""
        } else {
            stateMessageLabel.text = ConnectedUser.shared.user.userInfo.stateMessage
        }
    }
    
    @IBAction func clickXButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickChatButton(_ sender: Any) {
        guard let fetchedUserInfo = fetchedUserInfo else { return }
        guard let selectedFriendUid = selectedFriendUid else { return }
        guard selectedFriendUid != ConnectedUser.shared.uid else { return } // 자기 자신과의 채팅 막아놓는 코드
        let storyboard = UIStoryboard(name: "ChatingRoomViewController", bundle: nil)
        let ChatingRoomVC = storyboard.instantiateViewController(withIdentifier: "ChatingRoomViewController") as! ChatingRoomViewController
        
        ChatingRoomVC.participantUids.append(contentsOf: [ConnectedUser.shared.uid,selectedFriendUid])
        ChatingRoomVC.participantNames.append(contentsOf: [ConnectedUser.shared.user.userInfo.name,fetchedUserInfo.name])
        
        ChatingRoomVC.modalPresentationStyle = .fullScreen
        present(ChatingRoomVC, animated: true, completion: nil)
    }
    
    @IBAction func clickEditProfileButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ProfileEditViewController", bundle: nil)
        let profileEditVC = storyboard.instantiateViewController(withIdentifier: "ProfileEditViewController") as! ProfileEditViewController
        profileEditVC.modalTransitionStyle = .crossDissolve
        profileEditVC.modalPresentationStyle = .fullScreen
        present(profileEditVC, animated: true, completion: nil)
    }
    
}

// MARK: - Bar Button action func
extension ProfileViewController {
}



