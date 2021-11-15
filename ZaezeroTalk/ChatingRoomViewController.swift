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
                title += participant.name + ","
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
            JSONDecoder.de
        }
    }
    @IBOutlet weak var chatingTableView: UITableView! {
        didSet {
            chatingTableView.delegate = self
            chatingTableView.dataSource = self
            
            chatingTableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "MyMessageCell")
            chatingTableView.register(UINib(nibName: "OtherPersonMessageCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "OtherPersonMessageCell")
        }
    }
    
    var participants = [Friend]() // 나를 제외한 참가자들
    var chatingRoom: ChatingRoom?
    var readCount = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let participantUids = participants.map { participant in
            participant.uid
        }
        DatabaseManager.shared.fetchRoom(participantUids: participantUids, completion: {
            chatingRoom in
            if let chatingRoom = chatingRoom {
                DatabaseManager.shared.registerRoomObserver(id: chatingRoom.id, completion: {
                    room in
                    self.chatingRoom = room
                    self.chatingTableView.reloadData()
                    self.navigationItem.title = self.chatingRoom?.name
                })
            }
        })
    }
 
    
    @IBAction func clickBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickSendButton(_ sender: Any) {
        if let chatingRoom = chatingRoom {
            let message = Message(sender: ConnectedUser.shared.user.uid, time: ServerValue.timestamp(), readUsers: [ConnectedUser.shared.user.uid: 1], type: MessageType.Text.rawValue, content: inputTextView.text)
            DatabaseManager.shared.sendMessage(sendMessage: message, room: chatingRoom)
        } else {
            let participantUids = participants.map { participant in
                participant.uid
            }
            DatabaseManager.shared.createRoomWithObserver(participantUids: participantUids, message: inputTextView.text, name: customNavigationItem.title ?? "",observerCompletion: {
                room in
                self.chatingRoom = room
                self.chatingTableView.reloadData()
                self.navigationItem.title = self.chatingRoom?.name
            })
         
        }
    }
}

// MARK: - TableView DataSource
extension ChatingRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatingRoom?.messages.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let chatingRoom = chatingRoom else { return UITableViewCell() }
        
        if chatingRoom.messages[indexPath.row].sender == ConnectedUser.shared.user.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            cell.contentTextView.text = chatingRoom.messages[indexPath.row].content
            cell.timeLabel.text = chatingRoom.messages[indexPath.row].time.values.first as? String ?? ""
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherPersonMessageCell", for: indexPath) as! OtherPersonMessageCell
            cell.contentTextView.text = chatingRoom.messages[indexPath.row].content
            cell.timeLabel.text = chatingRoom.messages[indexPath.row].time.values.first as? String ?? ""
            return cell
        }
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




