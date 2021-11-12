//
//  ChatingRoomViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/12.
//

import UIKit

class ChatingRoomViewController: UIViewController {
    @IBOutlet weak var customNavigationItem: UINavigationItem! {
        didSet {
            // 채팅방 이름 설정
        }
    }
    @IBOutlet weak var inputTextView: UITextView! {
        didSet {
            inputTextView.delegate = self
        }
    }
    @IBOutlet weak var chatingTableView: UITableView! {
        didSet {
            chatingTableView.delegate = self
            chatingTableView.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - TableView DataSource
extension ChatingRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}

// MARK: - TableView Delegate
extension ChatingRoomViewController: UITableViewDelegate {
    
}

// MARK: - TextView Delegate
extension ChatingRoomViewController: UITextViewDelegate {
    
}
