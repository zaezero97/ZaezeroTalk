//
//  AddFriendViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/10.
//

import UIKit
import SnapKit
import Firebase

class AddFriendViewController: UIViewController {
    
    /// 검색된 유저 정보
    var searchedUserInfo: UserInfo?
    @IBOutlet weak var customNavigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem! {
        didSet {
            customNavigationItem.title = "Email로 추가"
        }
    }
    
    @IBOutlet weak var textFieldTableView: UITableView! {
        didSet {
            textFieldTableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "TextFieldCell")
            textFieldTableView.dataSource = self
        }
    }
    
    /// 검색 결과가 있을 시에 보여질 View
    lazy var searchByEmailResultView : SearchByEmailResultView = {
        let view = UIView.loadViewFromNib(nib: "SearchByEmailResultView") as! SearchByEmailResultView
        self.textFieldTableView.addSubview(view)
        view.snp.makeConstraints {
            make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
        }
        view.isHidden = true
        view.addFriendButton.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
        return view
    }()
    
    /// 검색결과 가 없을 때 보여질 Label
    lazy var searchByEmailResultLabel : UILabel = {
        let label = UILabel()
        label.text = "검색된 결과가 없습니다."
        label.font = .systemFont(ofSize: 25)
        self.textFieldTableView.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func clickXButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) // 외부 뷰 클릭 시 키보드 내리기
    }
}

// MARK: - Table View Datasource
extension AddFriendViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
        
        cell.textField.delegate = self
        return cell
    }
}

// MARK: - TextField Delegate 친구 검색 함수
extension AddFriendViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchEmail = textField.text , searchEmail.count > 0 else { return true }
        
        ///이메일로 User 정보를 가져온다.
        DatabaseManager.shared.fetchUserInfo(email: searchEmail) {
            userInfo in
            self.showSearchResultView(userInfo: userInfo)
        }
        textField.becomeFirstResponder()
        return true
    }
}

// MARK: - 친구 검색 결과창
extension AddFriendViewController {
    /// 검색 결과에 따라 화면 가운데에 View를 띄우는 메소드
    /// - Parameter userInfo: 검색된 유저정보(Optional)
    func showSearchResultView(userInfo: UserInfo?) {
        if let userInfo = userInfo {
            searchedUserInfo = userInfo
            searchByEmailResultView.nameLabel.text = userInfo.name
            searchByEmailResultLabel.isHidden = true
            searchByEmailResultView.isHidden = false
            if let friends = ConnectedUser.shared.user.friends {
                let isExisted = friends.values.contains(where: {
                    friend in
                    friend.email == searchedUserInfo!.email
                })
                searchByEmailResultView.addFriendButton.isEnabled = !isExisted
            } else {
                searchByEmailResultView.addFriendButton.isEnabled = true
            }
        } else {
            searchByEmailResultView.isHidden = true
            searchByEmailResultLabel.isHidden = false
        }
    }
}

// MARK: - 상단 네비게이션 바에 뷰가 닿을 때 경계선 보이게 하는 함수
//extension AddFriendViewController {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y > 0 {
//            customNavigationBar.standardAppearance.shadowColor = .gray
//        }else{
//            customNavigationBar.standardAppearance.shadowColor = .white
//        }
//    }
//}
// MARK: - email로 사람 검색 후 친구 추가 버튼 클릭 이벤트 함수
extension AddFriendViewController{
    @objc func addFriend(sender : UIButton){
        /// 검색된 유저정보의 이메일을 가지고 그 유저의 uid를 가져온 후 자신의 정보안에 친구 정보 저장
        if let searchedUserInfo = searchedUserInfo {
            DatabaseManager.shared.fetchUid(email: searchedUserInfo.email)
            {
                uid in
                guard let uid = uid else { return }
                DatabaseManager.shared.updateChildValues([uid: searchedUserInfo.toDictionary()], forPath: "Users/\(ConnectedUser.shared.uid)/friends") { (
                    error , reference) in
                    self.searchByEmailResultView.addFriendButton.isEnabled = false
                }
            }

        }
    }
}
