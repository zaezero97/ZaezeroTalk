//
//  ProfileViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/11.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileNameLabel: UILabel! {
        didSet {
            if let selectedFriend = selectedFriend {
                profileNameLabel.text = selectedFriend.name
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
   
    
    var selectedFriend: Friend?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func clickXButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func clickChatButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ChatingRoomViewController", bundle: nil)
        let ChatingRoomVC = storyboard.instantiateViewController(withIdentifier: "ChatingRoomViewController") as! ChatingRoomViewController
        
        ChatingRoomVC.modalPresentationStyle = .fullScreen
        present(ChatingRoomVC, animated: true, completion: nil)
    }
    @IBAction func clickEditProfileButton(_ sender: Any) {
    }
}

// MARK: - Bar Button action func
extension ProfileViewController {
}
