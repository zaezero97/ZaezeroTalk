//
//  AddFriendViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/10.
//

import UIKit

class AddFriendViewController: UIViewController {

    @IBOutlet weak var customNavigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    var myEmail = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        customNavigationItem.title = "Email로 추가"
        
    
    }
}
