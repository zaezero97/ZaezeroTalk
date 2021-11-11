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

    @IBOutlet weak var customNavigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var textFieldTableView: UITableView!
    var myEmail = ""
    lazy var searchByEmailResultView : SearchByEmailResultView = {
        let view = UIView.loadViewFromNib(nib: "SearchByEmailResultView") as! SearchByEmailResultView
        self.textFieldTableView.addSubview(view)
        view.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
        }
        view.isHidden = true
        view.addFriendButton.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
        return view
    }()
    lazy var searchByEmailResultLabel : UILabel = {
        let label = UILabel()
        label.text = "검색된 결과가 없습니다."
        label.font = .systemFont(ofSize: 25)
        self.textFieldTableView.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        label.isHidden = true
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        customNavigationItem.title = "Email로 추가"
        textFieldTableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "TextFieldCell")
        
        textFieldTableView.dataSource = self
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

// MARK: - TextField Delegate
extension AddFriendViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchEmail = textField.text , searchEmail.count > 0 else { return true }
        
        DatabaseManager.shared.fetchUserInfoByEmail(email: searchEmail,completion: {
            snapshot in
            guard snapshot.exists() else {
                self.searchByEmailResultView.isHidden = true
                self.searchByEmailResultLabel.isHidden = false
                return
            }
            
            let fetchedUser = snapshot.value as? NSDictionary ?? NSDictionary()
            let fetchedUserUid = fetchedUser.allKeys.first as! String
            let fetchedUserInfo = fetchedUser[fetchedUserUid] as? NSDictionary ?? NSDictionary()
            let name = fetchedUserInfo["name"] as? String ?? ""
            self.searchByEmailResultView.nameLabel.text = name
            self.searchByEmailResultLabel.isHidden = true
            self.searchByEmailResultView.isHidden = false
        })
        
        textField.becomeFirstResponder()
        return true
    }
}

// MARK: - 상단 네비게이션 바에 뷰가 닿을 때 경계선 보이게 하는 함수
extension AddFriendViewController{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            customNavigationBar.standardAppearance.shadowColor = .gray
        }else{
            customNavigationBar.standardAppearance.shadowColor = .white
        }
    }
}
// MARK: - email로 사람 검색 후 친구 추가 버튼 클릭 이벤트 함수
extension AddFriendViewController{
    @objc func addFriend(sender : UIButton){
        
    }
}
