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
            chatingTableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forCellReuseIdentifier: "MyMessageCell")
            chatingTableView.register(UINib(nibName: "OtherPersonMessageCell", bundle: nil), forCellReuseIdentifier: "OtherPersonMessageCell")
        }
    }
    
    var participantUids = [String]() // 나를 포함
    var participantNames = [String]()
    
    var chatingRoom: (id: String, info: ChatingRoom)?
    
    var messages = [Message]() {
        didSet {
            print(messages)
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        if let curRoom = fetchCurrentRoom() {
            chatingRoom = curRoom
            DatabaseManager.shared.enterRoom(uid: ConnectedUser.shared.uid, roomId: curRoom.id)
            if curRoom.info.name.isEmpty {
                var names = participantNames
                names.removeAll { name in
                    name == ConnectedUser.shared.user.userInfo.name
                }
                customNavigationItem.title = names.joined(separator: ",")
            }
            DatabaseManager.shared.registerRoomObserver(id: curRoom.id) { room in
                guard let room = room else {
                    return
                }
                self.chatingRoom = (id: curRoom.id,info: room)
            }
            DatabaseManager.shared.registerAddedMessageObserver(roomId: curRoom.id, completion: {
                message in
                if let message = message {
                    self.messages.append(message)
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.chatingTableView.insertRows(at: [indexPath], with: .automatic)
                    self.chatingTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            })
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
        DatabaseManager.shared.exitRoomuid(uid: ConnectedUser.shared.uid, roomId: chatingRoom!.id)
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
        
        if let chatingRoom = chatingRoom {
            DatabaseManager.shared.sendMessage(sendMessage: message, room: chatingRoom)
        } else {
            DatabaseManager.shared.createRoom(message: message, participantUids: participantUids, participantNames: participantNames, name: nil , completion: {
                id in
                DatabaseManager.shared.registerRoomObserver(id: id) { room in
                    guard let room = room else {
                        return
                    }
                    self.chatingRoom = (id: id,info: room)
                }
                DatabaseManager.shared.registerAddedMessageObserver(roomId: id, completion: {
                    message in
                    if let message = message {
                        self.messages.append(message)
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.chatingTableView.insertRows(at: [indexPath], with: .automatic)
                        self.chatingTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                })
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
        guard chatingRoom != nil else { return UITableViewCell() }
        
        if messages[indexPath.row].sender == ConnectedUser.shared.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            cell.contentTextView.text = messages[indexPath.row].content
            cell.timeLabel.text = messages[indexPath.row].time?.toDayTime
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherPersonMessageCell", for: indexPath) as! OtherPersonMessageCell
            cell.contentTextView.text = messages[indexPath.row].content
            cell.timeLabel.text = messages[indexPath.row].time?.toDayTime
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
    func fetchCurrentRoom() -> (id: String,info: ChatingRoom)? {
        guard let roomList = ConnectedUser.shared.chatingRoomList else { return nil}
        // 현재 사용자가 참여하고 있는 방 리스트
        
        let curRoom = roomList.first { (id, info) in
            let set1 = Set(info.uids.toFBArray())
            var set2 = Set(participantUids)
            set2.insert(ConnectedUser.shared.uid)
            let result = set1.intersection(set2)
            if result.count == participantUids.count
            {
                return true
            } else {
                return false
            }
        }
        
        return curRoom
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
