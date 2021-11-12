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
           
            toolBar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),chatButton,UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),editProfileButton,UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)], animated: true)
        
        }
    }
    @IBOutlet weak var customNavigationBar: UINavigationBar! {
        didSet {
            customNavigationBar.standardAppearance.shadowColor = .white
        }
    }
    lazy var chatButton: UIBarButtonItem = {
        let chatButtonView = UIView.loadViewFromNib(nib: "ProfileToolBarItemView") as! ProfileToolBarItemView
        chatButtonView.imageView.image = UIImage(systemName: "bubble.right.fill")
        chatButtonView.label.text = "1:1 채팅"
        let chatButton = UIBarButtonItem(customView: chatButtonView)
        chatButton.target = self
        chatButton.action = #selector(clickChatButton)
        
        return chatButton
    }()
    
    lazy var editProfileButton: UIBarButtonItem = {
        let editProfileView = UIView.loadViewFromNib(nib: "ProfileToolBarItemView") as! ProfileToolBarItemView
        editProfileView.imageView.image = UIImage(systemName: "pencil")
        editProfileView.label.text = "프로필 편집"
        let editProfileButton = UIBarButtonItem(customView: editProfileView)
        editProfileButton.target = self
        //editProfileButton.action = #selector(<#T##@objc method#>)
        
        return editProfileButton
    }()
    
    var selectedFriend: Friend?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func clickXButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Bar Button action func
extension ProfileViewController {
    @objc func clickChatButton(){
        let storyboard = UIStoryboard(name: "ChatingRoomViewController", bundle: nil)
        let ChatingRoomVC = storyboard.instantiateViewController(withIdentifier: "ChatingRoomViewController") as! ChatingRoomViewController
        
        present(ChatingRoomVC, animated: true, completion: nil)
    }
    @objc func clickEditProfileButton(){
        
    }
}
