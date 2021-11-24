//
//  ChatingRoomMenuViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/24.
//

import UIKit

class RoomDrawerMenuViewController: UIViewController {

    @IBOutlet weak var drawerMenuTableView: UITableView! {
        didSet {
            drawerMenuTableView.dataSource = self
            drawerMenuTableView.delegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func clickExitButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - TableView DataSource
extension RoomDrawerMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

// MARK: - TableView Delegate
extension RoomDrawerMenuViewController: UITableViewDelegate {
    
}
