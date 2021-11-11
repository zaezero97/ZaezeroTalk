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
            profileNameLabel.text = ConnectedUser.shared.Info?.name ?? ""
        }
    }
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            
        }
    }
    @IBOutlet weak var toolBar: UIToolbar! {
        didSet {
            let chatButtonView = UIView.loadViewFromNib(nib: "ProfileToolBarItemView") as! ProfileToolBarItemView
            chatButtonView.imageView.image = UIImage(systemName: "bubble.right.fill")
            chatButtonView.label.text = "1:1 채팅"
            let chatButton = UIBarButtonItem(customView: chatButtonView)
            
            let editProfileView = UIView.loadViewFromNib(nib: "ProfileToolBarItemView") as! ProfileToolBarItemView
            editProfileView.imageView.image = UIImage(systemName: "pencil")
            editProfileView.label.text = "프로필 편집"
            let editProfileButton = UIBarButtonItem(customView: editProfileView)
            
            
            toolBar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),chatButton,UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),editProfileButton,UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)], animated: true)
        
        }
    }
    @IBOutlet weak var customNavigationBar: UINavigationBar! {
        didSet {
            customNavigationBar.standardAppearance.shadowColor = .white
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func clickXButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
