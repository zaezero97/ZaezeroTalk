//
//  'ViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/24.
//

import UIKit
import Firebase

protocol Exitdelegate: AnyObject{
    func roomExit(roomDismiss: @escaping (Error?, DatabaseReference) -> Void)
}

class SideMenuViewController: UIViewController {
    weak var delegate: Exitdelegate?
    let exitMessage = "채팅방을 나가면 대화내용이 모두 삭제되고 채팅목록에서도 사라집니다."
    var participants = [(uid: String, info: UserInfo)]()
    
    
    
    @IBOutlet weak var drawerTableView: UITableView! {
        didSet {
            drawerTableView.delegate = self
            drawerTableView.dataSource = self
            drawerTableView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// 채팅방 나가기
    /// - Parameter sender: ToolBar Button
    @IBAction func clickExitButton(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: exitMessage, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "나기기", style: .cancel, handler: { action in
            self.delegate?.roomExit(roomDismiss: { _, _ in
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            })
        }))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Table View Data Source
extension SideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "대화 상대"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        
        cell.nameLabel.text = participants[indexPath.row].info.name
        cell.profileImageView.image = ConnectedUser.shared.profileImages[participants[indexPath.row].uid]
        cell.stateMessageLabel.text = ""
        
        cell.selfImageView.isHidden = participants[indexPath.row].uid != ConnectedUser.shared.uid
        return cell
    }
}

// MARK: - Table View Delegate
extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "ProfileViewController", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileVC.selectedUserUid = participants[indexPath.row].uid
        profileVC.selectedUserInfo = participants[indexPath.row].info
        
        profileVC.modalPresentationStyle = .fullScreen
        self.present(profileVC, animated: true, completion: nil)
    }
}
