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
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        }
    }
    @IBOutlet weak var toolBar: UIToolbar! {
        didSet {
            if selectedUserUid != ConnectedUser.shared.uid {
                var toolbarItems = toolBar.items
                toolbarItems?.removeLast()
                toolbarItems?.removeLast()
                toolBar.items = toolbarItems
            } // 자기 자신이 아닌 다른 친구의 프로필 일 경우 프로필 편집 버튼 없애기
        }
    }
    @IBOutlet weak var customNavigationBar: UINavigationBar! {
        didSet {
            customNavigationBar.standardAppearance.shadowColor = .white
        }
    }
    
    
    var selectedUserUid: String?
    var selectedUserInfo: UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfile(uid: selectedUserUid, userInfo: selectedUserInfo)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    @IBAction func clickXButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickChatButton(_ sender: Any) {
        guard let selectedUserInfo = selectedUserInfo else { return }
        guard let selectedUserUid = selectedUserUid else { return }
        guard selectedUserUid != ConnectedUser.shared.uid else { return } // 자기 자신과의 채팅 막아놓는 코드
        let storyboard = UIStoryboard(name: "ChatingRoomViewController", bundle: nil)
        let chatingRoomVC = storyboard.instantiateViewController(withIdentifier: "ChatingRoomViewController") as! ChatingRoomViewController
        
        chatingRoomVC.participantUids.append(contentsOf: [ConnectedUser.shared.uid,selectedUserUid])
        
        chatingRoomVC.modalPresentationStyle = .fullScreen
        
        let rootVC = view.window?.rootViewController
        view.window?.rootViewController?.dismiss(animated: false, completion: {
            rootVC!.present(chatingRoomVC, animated: true, completion: nil)
        })
        
    }
    
    @IBAction func clickEditProfileButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ProfileEditViewController", bundle: nil)
        let profileEditVC = storyboard.instantiateViewController(withIdentifier: "ProfileEditViewController") as! ProfileEditViewController
        profileEditVC.doneCallback = {
            uid,userInfo in
            print("test")
            print(userInfo)
            self.setProfile(uid: uid, userInfo: userInfo)
            ConnectedUser.shared.user.userInfo = userInfo
            DatabaseManager.shared.notiProfileChangeToFriends()
        }
        profileEditVC.modalTransitionStyle = .crossDissolve
        profileEditVC.modalPresentationStyle = .fullScreen
        present(profileEditVC, animated: true, completion: nil)
    }
    
}


// MARK: - 프로필 화면이 보여질 때 상태메시지와 프로필 이미지를 설정하는 함수
extension ProfileViewController {
    func setProfile(uid: String?, userInfo: UserInfo?){
        
        guard let _ = uid else { return }
        
        profileNameLabel.text = userInfo?.name ?? ""
        stateMessageLabel.text = userInfo?.stateMessage ?? ""
        
        if let profileImage = ImageCacheManager.shared.object(forKey: NSString(string: userInfo?.profileImageUrl ?? "")) {
            profileImageView.image = profileImage
        } else if let urlString = userInfo?.profileImageUrl , let url = URL(string: urlString) , let data = try? Data(contentsOf: url) {
            profileImageView.image = UIImage(data: data)
        } else {
            profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }

    }
}
