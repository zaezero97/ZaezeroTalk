//
//  ChatingRoomViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/12.
//

import UIKit
import Firebase

class ChatingRoomViewController: UIViewController {
    @IBOutlet weak var customNavigationItem: UINavigationItem! {
        didSet {
            var title = ""
            participants.forEach { participant in
                title += participant.info.name + ","
            }
            title.removeLast()
            customNavigationItem.title = title
            // 채팅방 이름 설정
        }
    }
    //버튼 초기 비활성화 상태 지정
    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            sendButton.isEnabled = false
            sendButton.tintColor = .darkGray
        }
    }
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
            
            chatingTableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forCellReuseIdentifier: "MyMessageCell")
            chatingTableView.register(UINib(nibName: "OtherPersonMessageCell", bundle: nil), forCellReuseIdentifier: "OtherPersonMessageCell")
        }
    }
    
    var participants = [(uid: String, info: UserInfo)]() // 나를 제외한 참가자들
    var chatingRoom: (id: String, info: ChatingRoom)? {
        didSet {
            messages = Array(chatingRoom!.info.messages!.values)
        }
    }
    var messages: [Message]? {
        didSet {
            print(messages)
            self.chatingTableView.reloadData()
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        if let curRoom = fetchCurrentRoom() {
            chatingRoom = curRoom
            DatabaseManager.shared.registerRoomObserver(id: curRoom.id) { room in
                guard let room = room else {
                    return
                }
                self.chatingRoom = (id: curRoom.id,info: room)
            }
        }
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
            DatabaseManager.shared.createRoom(message: message, participantUids: participants.map({
                $0.uid
            }), name: customNavigationItem.title! , completion: {
                id in
                DatabaseManager.shared.registerRoomObserver(id: id) { room in
                    guard let room = room else {
                        return
                    }
                    self.chatingTableView.reloadData()
                    self.chatingRoom = (id: id,info: room)
                }
            })
        }
    }
}

// MARK: - TableView DataSource
extension ChatingRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let chatingRoom = chatingRoom else { return UITableViewCell() }
        
        if messages![indexPath.row].sender == ConnectedUser.shared.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            cell.contentTextView.text = messages![indexPath.row].content
            cell.timeLabel.text = messages![indexPath.row].time?.toDayTime
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherPersonMessageCell", for: indexPath) as! OtherPersonMessageCell
            cell.contentTextView.text = messages![indexPath.row].content
            cell.timeLabel.text = messages![indexPath.row].time?.toDayTime
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - TableView Delegate
extension ChatingRoomViewController: UITableViewDelegate {
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
    }
}

// MARK: - 채팅방 존재 여부 확인 함수
extension ChatingRoomViewController {
    func fetchCurrentRoom() -> (id: String,info: ChatingRoom)? {
        guard let roomList = ConnectedUser.shared.chatingRoomList else { return nil}
        // 현재 사용자가 참여하고 있는 방 리스트
        
        let curRoom = roomList.first { (id, info) in
            let set1 = Set(info.participants.keys)
            var set2 = Set(participants.map({
                $0.uid
            }))
            set2.insert(ConnectedUser.shared.uid)
            let result = set1.intersection(set2)
            if result.count == participants.count + 1
            {
                return true
            } else {
                return false
            }
        }
        
        return curRoom
    }
}


