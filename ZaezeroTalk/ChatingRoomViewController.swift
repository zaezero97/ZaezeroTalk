//
//  ChatingRoomViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/12.
//

import UIKit
import Firebase


class ChatingRoomViewController: UIViewController {
    @IBOutlet weak var inputTextViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var inputTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            sendButton.isEnabled = false
            sendButton.tintColor = .darkGray
        }
    }//버튼 초기 비활성화 상태 지정
    @IBOutlet weak var inputTextView: UITextView! {
        didSet {
            inputTextView.delegate = self
            inputTextView.layer.cornerRadius = inputTextView.bounds.height / 2
        }
    }
    @IBOutlet weak var chatingTableView: UITableView! {
        didSet {
            chatingTableView.delegate = self
            chatingTableView.dataSource = self
            chatingTableView.estimatedRowHeight = 10
            chatingTableView.rowHeight = UITableView.automaticDimension
            chatingTableView.separatorStyle = .none
            chatingTableView.register(UINib(nibName: "UserExitMessageCell", bundle: nil), forCellReuseIdentifier: "UserExitMessageCell")
            chatingTableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forCellReuseIdentifier: "myMessageCell")
            chatingTableView.register(UINib(nibName: "OtherPersonMessageCell", bundle: nil), forCellReuseIdentifier: "otherPersonMessageCell")
        }
    }
    
    var participantUids = [String]() // 나를 포함
    var participantNames = [String]()
    
    var curRoomId: String?
    var curRoomInfo: ChatingRoom?
    
    var messages = [Message]() {
        didSet {
            print(messages)
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        fetchCurrentRoom()
        
        if let curRoomInfo = curRoomInfo , let curRoomId = curRoomId{
            DatabaseManager.shared.enterRoom(uid: ConnectedUser.shared.uid, roomId: curRoomId)
            DatabaseManager.shared.readMessage(messages: curRoomInfo.messages, roomId: curRoomId)
            if curRoomInfo.name.isEmpty {
                var names = participantNames
                names.removeAll { name in
                    name == ConnectedUser.shared.user.userInfo.name
                }
                customNavigationItem.title = names.joined(separator: ",")
            }
            DatabaseManager.shared.registerMessageObserver(roomId: curRoomId) {
                fetchedMessages in
                guard let fetchedMessages = fetchedMessages else {
                    return
                }
                self.messages = fetchedMessages
                self.chatingTableView.reloadData()
                self.chatingTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
            }
        } else {
            var names = participantNames
            names.removeAll { name in
                name == ConnectedUser.shared.user.userInfo.name
            }
            customNavigationItem.title = names.joined(separator: ",")
        }
        
        // 방에 입장 시 방이 존재하면 방의 정보를 가져오고 방의 상태 변경을 감지하는 옵저버를 등록한다,
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DatabaseManager.shared.removeMessageObserver()
        //DatabaseManager.shared.leaveRoom(uid: ConnectedUser.shared.uid, roomId: chatingRoom!.id)
    }
    
    @IBAction func clickMenuButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SideMenuViewController", bundle: nil)
        let sideMenuNavigationVC = storyboard.instantiateViewController(withIdentifier: "CustomSideMenuNavigationController") as! CustomSideMenuNavigationController
        let sideMenuVC = sideMenuNavigationVC.viewControllers.first as! SideMenuViewController
        sideMenuVC.delegate = self
        present(sideMenuNavigationVC, animated: true, completion: nil)
    }
    
    @IBAction func clickBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickSendButton(_ sender: Any) {
        let message : [String: Any] = [
            "sender": ConnectedUser.shared.uid,
            "time": ServerValue.timestamp(),
            "type": "Text",
            "content": inputTextView.text!
        ]
        
        if let curRoomId = curRoomId {
            DatabaseManager.shared.sendMessage(sendMessage: message, roomId: curRoomId)
        } else {
            DatabaseManager.shared.createRoom(message: message, participantUids: participantUids, participantNames: participantNames, name: nil , completion: {
                roomId,roomInfo in
                self.curRoomId = roomId
                self.curRoomInfo = roomInfo
                DatabaseManager.shared.registerMessageObserver(roomId: roomId) {
                    fetchedMessages in
                    guard let fetchedMessages = fetchedMessages else {
                        return
                    }
                    self.messages = fetchedMessages
                    self.chatingTableView.reloadData()
                    self.chatingTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
                    
                }
            })
        }// 방이 존재하면 메시지를 보내고 존재하지 않으면 새로 방을 만들고 room의 상태변화를 감지하는 옵저버를 등록한다.
        
    }
}

// MARK: - TableView DataSource
extension ChatingRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard curRoomId != nil else { return UITableViewCell() }
        
        if messages[indexPath.row].type == "exit" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserExitMessageCell", for: indexPath) as! UserExitMessageCell
            cell.userExitMessageLebel.text = messages[indexPath.row].content
            
            return cell
        }
        
        guard let readUsers = messages[indexPath.row].readUsers else { return UITableViewCell()}
        if messages[indexPath.row].sender == ConnectedUser.shared.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myMessageCell", for: indexPath) as! MyMessageCell
            cell.contentTextView.text = messages[indexPath.row].content
            cell.timeLabel.text = messages[indexPath.row].time?.toDayTime
            cell.readCountLabel.text = calReadUserCount(readUsers: readUsers) == 0 ? "" : String(calReadUserCount(readUsers: readUsers))
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "otherPersonMessageCell", for: indexPath) as! OtherPersonMessageCell
            cell.contentTextView.text = messages[indexPath.row].content
            cell.timeLabel.text = messages[indexPath.row].time?.toDayTime
            cell.readCountLabel.text = calReadUserCount(readUsers: readUsers) == 0 ? "" : String(calReadUserCount(readUsers: readUsers))
            cell.selectionStyle = .none
            return cell
        }
    }
}

// MARK: - TableView Delegate
extension ChatingRoomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
}

// MARK: - TextView Delegate
extension ChatingRoomViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            sendButton.tintColor = .yellow
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
            sendButton.tintColor = .darkGray
        }
        
        
        if textView.contentSize.height <= 50{
            inputTextViewHeightConstraint.constant = 50
        } else if textView.contentSize.height >= 100 {
            inputTextViewHeightConstraint.constant = 100
        } else {
            inputTextViewHeightConstraint.constant = textView.contentSize.height
        }
        
        
    }
}

// MARK: - 채팅방 존재 여부 확인 함수
extension ChatingRoomViewController {
    func fetchCurrentRoom() {
        guard let roomList = ConnectedUser.shared.chatingRoomList else { return }
        // 현재 사용자가 참여하고 있는 방 리스트
        
        print("fetchCurrentRoom !!! -> ",roomList)
        if let curRoomId = curRoomId {
            for room in roomList {
                if room.id == curRoomId {
                    return curRoomInfo = room.info
                }
            } // 채팅방 리스트를 통해 방에 입장했을경우
        } else {
            let curRoom = roomList.first { (id, info) in
                let sortedRoomInfoUids = info.uids.toFBArray().sorted()
                let sortedParticipantUids = participantUids.sorted()
                
                if sortedRoomInfoUids == sortedParticipantUids {
                    return true
                } else {
                    return false
                }
            } // 1대1 채팅으로 통해 방에 입장 했을 경우
            
            curRoomId = curRoom?.id
            curRoomInfo = curRoom?.info
        }
    }
}

// MARK: - keyboard func
extension ChatingRoomViewController {
    
    @objc func keyboardWillShow(noti : Notification){
        let notiInfo = noti.userInfo!
        let keyboardFrame = notiInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let animationDuration = notiInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        
        UIView.animate(withDuration: animationDuration) {
            self.inputTextViewBottomMargin.constant = keyboardFrame.size.height - self.view.safeAreaInsets.bottom
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardDidHide(noti : Notification){
        let notiInfo = noti.userInfo!
        let animationDuration = notiInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        
        UIView.animate(withDuration: animationDuration) {
            self.inputTextViewBottomMargin.constant = 5
            self.view.layoutIfNeeded()
        }
    }
}


// MARK: - read User Count 계산
extension ChatingRoomViewController {
    
    /// read User Count 계산
    /// - Returns: read Count
    /// - Parameter readUsers: 메시지 읽은 유저 Dictionary
    func calReadUserCount(readUsers: [String: String]) -> Int {
        guard let curRoomInfo = curRoomInfo else { return 0 }
        
        let readUsersSet = Set(readUsers.keys)
        let participantsSet = Set(curRoomInfo.uids.toFBArray())
        
        
        let result = participantsSet.subtracting(readUsersSet)
        print("result!!! ->",result)
        return result.count
    }
}

// MARK: - Side Menu Exit Delegate
extension ChatingRoomViewController: Exitdelegate {
    func roomExit(roomDismiss: @escaping (Error?, DatabaseReference) -> Void) {
        guard let curRoomId = self.curRoomId , let curRoomInfo = self.curRoomInfo else { return }
        DatabaseManager.shared.exitRoom(roomId: curRoomId, roomInfo: curRoomInfo,completion: roomDismiss)
    }
}
