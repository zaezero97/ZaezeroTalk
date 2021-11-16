//
//  ChatingRoomListViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/12.
//

import UIKit
import FirebaseDatabase

class ChatingRoomListViewController: UIViewController {

    
    
    @IBOutlet weak var chatingRoomListTableView: UITableView! {
        didSet {
            chatingRoomListTableView.delegate = self
            chatingRoomListTableView.dataSource = self
            chatingRoomListTableView.register(UINib(nibName: "ChatingRoomCell", bundle: nil), forCellReuseIdentifier: "ChatingRoomCell")
        }
    }
    @IBOutlet weak var customNavigationItem: UINavigationItem! {
        didSet {
            customNavigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        }
    }
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.text = "채팅"
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

// MARK: - TableView Datasource
extension ChatingRoomListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConnectedUser.shared.chatingRoomList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let chatingRoomList = ConnectedUser.shared.chatingRoomList else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatingRoomCell", for: indexPath) as! ChatingRoomCell
        let roomInfo = chatingRoomList[indexPath.row].info
        cell.headCountLabel.text = String(roomInfo.participants.count)
        cell.lastMeesageLabel.text = roomInfo.messages?.values.first?.content ?? ""
        cell.roomImageView.image = UIImage(systemName: "person.2.wave.2")
        cell.timeLabel.text = roomInfo.messages?.values.first?.time?.toDayTime
        cell.nameLabel.text = roomInfo.name
        return cell
    }
    
}
// MARK: - TableView Delegate
extension ChatingRoomListViewController: UITableViewDelegate {
    
}
