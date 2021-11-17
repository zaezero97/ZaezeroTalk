//
//  EditStateMessageViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/17.
//

import UIKit

class EditStateMessageViewController: UIViewController {
    
    @IBOutlet weak var customNavigationBar: UINavigationBar! {
        didSet {
            customNavigationBar.setBackgroundImage(UIImage(), for: .default)
            customNavigationBar.shadowImage = UIImage()
        }
    }
    var doneCallback : ((String?) -> Void)?
    @IBOutlet weak var maxLengthLabel: UILabel!
    @IBOutlet weak var stateMessageTextView: UITextView! {
        didSet {
            stateMessageTextView.delegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func clickCancleButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func clickDoneButton(_ sender: Any) {
        
        if let doneCallback = doneCallback {
            doneCallback(stateMessageTextView.text)
            dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func clickClearButton(_ sender: Any) {
        stateMessageTextView.text = ""
        maxLengthLabel.text = "0/60"
    }
}

// MARK: - TextView Delegate
extension EditStateMessageViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let char = text.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        guard textView.text!.count < 60 else { return false }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        maxLengthLabel.text = String(textView.text?.count ?? 0) + "/60"
        
    }
    
}


