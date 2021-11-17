//
//  ProfileViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/11.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var stateMessageLabel: UILabel!
    
    @IBOutlet weak var profileNameLabel: UILabel! {
        didSet {
            if let selectedFriend = selectedFriend {
                profileNameLabel.text = selectedFriend.info.name
            } else {
                profileNameLabel.text = ConnectedUser.shared.user.userInfo.name
            }
        }
    }
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
    
    
    var selectedFriend: (uid: String,info: UserInfo)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedFriend != nil {
            var toolbarItems = toolBar.items
            toolbarItems?.removeLast()
            toolbarItems?.removeLast()
            toolBar.items = toolbarItems
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let stateMessage = ConnectedUser.shared.user.userInfo.stateMessage {
            stateMessageLabel.text = stateMessage
        } else {
            stateMessageLabel.text = ""
        }
    }
    
    @IBAction func clickXButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickChatButton(_ sender: Any) {
        guard let selectedFriend = selectedFriend else { return }
        let storyboard = UIStoryboard(name: "ChatingRoomViewController", bundle: nil)
        let ChatingRoomVC = storyboard.instantiateViewController(withIdentifier: "ChatingRoomViewController") as! ChatingRoomViewController
        ChatingRoomVC.participants.append(selectedFriend)
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



