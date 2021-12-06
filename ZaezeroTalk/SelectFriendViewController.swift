//
//  MakeChatingRoomViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/26.
//

import UIKit

class SelectFriendViewController: UIViewController {
    
    @IBOutlet weak var confirmBarButton: UIBarButtonItem! {
        didSet {
            confirmBarButton.isEnabled = false
            let label = UILabel()
            label.textAlignment = .left
            label.font = .systemFont(ofSize: 18)
            label.text = " 확인"
            confirmBarButton.customView = label
        }
    }
    
    lazy var confirmBarButtonLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18)
        
        return label
    }()
    
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "이름 검색"
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsCancelButton = false
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    var searchedFriends = [(uid: String,info: UserInfo,isSelected: Bool)]()
    
    var friends: [(uid: String,info: UserInfo,isSelected: Bool)] = {
        var friends = [(uid: String,info: UserInfo,isSelected: Bool)]()
        if let friendsDictionary = ConnectedUser.shared.user.friends {
            friends = friendsDictionary.map { (key,value) in
                (key,value,false)
            }
        }
        return friends
    }()
    
    var friendImages = [String: UIImage]()
    var selectedCount = 0
    
    lazy var selectFriendVCType: String = {
        if self.presentingViewController is TabbarViewController {
            return "make"
        } else {
            return "invite"
        }
    }()
    
    @IBOutlet weak var searchedfriendListTableView: UITableView! {
        didSet {
            searchedfriendListTableView.dataSource = self
            searchedfriendListTableView.delegate = self
            searchedfriendListTableView.register(UINib(nibName: "checkBoxProfileCell", bundle: nil), forCellReuseIdentifier: "checkBoxProfileCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchedFriends = friends
        
        self.navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if selectFriendVCType == "make" {
            customNavigationItem.title = "대화상대 선택"
        } else if selectFriendVCType == "invite" {
            customNavigationItem.title = "대화상대 초대"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /// 확인 버튼 클릭 이벤트
    /// - Parameter sender: 확인 버튼
    @objc func clickConfirmButton(_ sender: Any) {
        print("selectFriendVCType!!! ->",selectFriendVCType)
        if selectFriendVCType == "make" {
            let storyboard = UIStoryboard(name: "SetGroupChatingRoomInfoViewController", bundle: nil)
            let setGroupChationRoomInfoVC = storyboard.instantiateViewController(withIdentifier: "SetGroupChatingRoomInfoViewController") as! SetGroupChatingRoomInfoViewController
            
            setGroupChationRoomInfoVC.selectedFriends = friends.filter({ _,_,isSelected in
                isSelected
            }).map({ uid,info,_ in
                (uid,info)
            })
            navigationController?.pushViewController(setGroupChationRoomInfoVC, animated: true)
        } else if selectFriendVCType == "invite" {
            let selectedFriends = friends.filter({ _,_,isSelected in
                isSelected
            }).map({ uid,info,_ in
                (uid,info)
            })
            
            DatabaseManager.shared.inviteUsers(users: selectedFriends) {
                inviteType in
                
                if inviteType == .create {
                    
                    let storyboard = UIStoryboard(name: "ChatingRoomViewController", bundle: nil)
                    let chatingRoomVC = storyboard.instantiateViewController(withIdentifier: "ChatingRoomViewController") as! ChatingRoomViewController
                    
                    chatingRoomVC.participantUids = selectedFriends.map({ uid,_ in
                        uid
                    })
                    let curRoom = ConnectedUser.shared.chatingRoomList.filter({$0.id == ConnectedUser.shared.roomId}).first
                    chatingRoomVC.participantUids.append(contentsOf: (curRoom?.info.uids.toFBArray())!)
                    chatingRoomVC.modalPresentationStyle = .fullScreen
                    
                    ConnectedUser.shared.roomId = nil
                    let rootVC = self.view.window?.rootViewController
                    self.view.window?.rootViewController?.dismiss(animated: false, completion: {
                        rootVC!.present(chatingRoomVC, animated: true, completion: nil)
                    })
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    /// Back 버튼 클릭 이벤트
    /// - Parameter sender: x 버튼
    @IBAction func clickCancleButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UISearchResultsUpdating
extension SelectFriendViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text , text.count > 0 else {
            searchedFriends = friends
            searchedfriendListTableView.reloadData()
            return
        }
        searchedFriends = friends.filter{ $0.info.name.localizedCaseInsensitiveContains(text)}
        searchedfriendListTableView.reloadData()
    }
}

// MARK: - Table View DataSource
extension SelectFriendViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkBoxProfileCell", for: indexPath) as! checkBoxProfileCell
        let friend = searchedFriends[indexPath.row]
        
        cell.nameLabel.text = friend.info.name
        if let profileImageUrl = friend.info.profileImageUrl {
            cell.profileImageView.setImageUrl(profileImageUrl)
        } else {
            cell.profileImageView.image = UIImage(systemName: "person.crop.rectangle.fill")
        }
        cell.checkBoxImageView.image = friend.isSelected ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        return cell
    }
}

// MARK: - Table View Delegate
extension SelectFriendViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchedFriends[indexPath.row].isSelected.toggle()
        let index = friends.firstIndex(where: {$0.uid == searchedFriends[indexPath.row].uid})
        friends[index!].isSelected.toggle()
        
        selectedCount += searchedFriends[indexPath.row].isSelected ? 1 : -1
        
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18)
        
        if selectedCount > 0 {
            confirmBarButton.isEnabled = true
            label.text = String(selectedCount) + " 확인"
            let attributedStr = NSMutableAttributedString(string: label.text!)
            attributedStr.addAttribute(.foregroundColor, value: UIColor.yellow, range: (label.text! as NSString).range(of: String(selectedCount)))
            label.attributedText = attributedStr
            let gesture = UITapGestureRecognizer(target: self, action: #selector(clickConfirmButton))
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(gesture)
        } else {
            label.text = "확인"
            confirmBarButton.isEnabled = false
        }
        confirmBarButton.customView = label
        tableView.reloadRows(at: [indexPath], with: .automatic)
        navigationItem.titleView?.addSubview(UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50)))
    }
}
