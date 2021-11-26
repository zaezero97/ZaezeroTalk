//
//  'ViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/24.
//

import UIKit
import Firebase

protocol Exitdelegate: AnyObject{
    func roomExit(roomDismiss: @escaping (Error?, DatabaseReference) -> Void)
}
class SideMenuViewController: UIViewController {
    weak var delegate: Exitdelegate?
    let exitMessage = "채팅방을 나가면 대화내용이 모두 삭제되고 채팅목록에서도 사라집니다."
    @IBOutlet weak var drawerTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// 채팅방 나가기
    /// - Parameter sender: ToolBar Button
    @IBAction func clickExitButton(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: exitMessage, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "나기기", style: .cancel, handler: { action in
            self.delegate?.roomExit(roomDismiss: { _, _ in
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            })
        }))
        present(alert, animated: true, completion: nil)
    }
}
