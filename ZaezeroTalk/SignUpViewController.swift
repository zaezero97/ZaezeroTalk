//
//  SignUpViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/08.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var pwdCheckTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var pwdErrorLabel: UILabel!
    @IBOutlet weak var pwdCheckErrorLabel: UILabel!
    
    var heightConstraints = [UILabel : NSLayoutConstraint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        heightConstraints[emailErrorLabel] = emailErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        heightConstraints[nameErrorLabel] = nameErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        heightConstraints[pwdErrorLabel] = pwdErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        heightConstraints[pwdCheckErrorLabel] = pwdCheckErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        
        heightConstraints[emailErrorLabel]?.isActive = true
        heightConstraints[nameErrorLabel]?.isActive = true
        heightConstraints[pwdErrorLabel]?.isActive = true
        heightConstraints[pwdCheckErrorLabel]?.isActive = true
        
        confirmButton.layer.cornerRadius = confirmButton.bounds.height / 2
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    @IBAction func touchConfirmButton(_ sender: Any) {
        if isValidEmail(email: emailTextField.text){
            heightConstraints[emailErrorLabel]?.isActive = true
        }else{
            heightConstraints[emailErrorLabel]?.isActive = false
        }
        if isValidName(name: nameTextField.text){
            heightConstraints[nameErrorLabel]?.isActive = true
        }else{
            heightConstraints[nameErrorLabel]?.isActive = false
        }
        if isValidPassword(password: pwdTextField.text){
            heightConstraints[pwdErrorLabel]?.isActive = true
        }else{
            heightConstraints[pwdErrorLabel]?.isActive = false
        }
        if isEqualPassword(with: pwdCheckTextField.text){
            heightConstraints[pwdCheckErrorLabel]?.isActive = true
        }else{
            heightConstraints[pwdCheckErrorLabel]?.isActive = false
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - valid text func
extension SignUpViewController{
    func isValidEmail(email: String?) -> Bool{
        guard email != nil else { return false}
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let pred = NSPredicate(format: "SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    func isValidPassword(password: String?) -> Bool{
        if let hasPassword = password {
            if hasPassword.count < 4 {
                return false
            }
        }
        return true
    }
    func isValidName(name: String?) -> Bool{
        if let hasName = name {
            if hasName.count < 3{
                return false
            }
        }
        return true
    }
    func isEqualPassword(with checkPassword: String?) -> Bool{
        if let password = pwdTextField.text, let checkPassword = checkPassword{
            if password == checkPassword{
                return true
            }
        }
        return false
    }
}

