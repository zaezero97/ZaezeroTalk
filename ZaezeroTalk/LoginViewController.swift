//
//  LoginViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/07.
//

import UIKit
import FirebaseRemoteConfig

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var pwdErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var emailErrorLabelHeight : NSLayoutConstraint!
    var pwdErrorLabelHeight : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.addTarget(self, action: #selector(editTextField), for: .editingChanged)
        pwdTextField.addTarget(self, action: #selector(editTextField), for: .editingChanged)
        
        emailErrorLabelHeight  = emailErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        pwdErrorLabelHeight = pwdErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        emailErrorLabelHeight.isActive = true
        pwdErrorLabelHeight.isActive = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let color = remoteConfig["app_color"].stringValue{
            loginButton.backgroundColor = UIColor(hex: color)
            signUpButton.backgroundColor = UIColor(hex: color)
        }
    }
}
// MARK: - textField func
extension LoginViewController{
    @objc func editTextField(sender : UITextField){
        if sender == emailTextField{
            if isValidEmail(email: sender.text)
            {
                emailErrorLabelHeight.isActive = true
            }else{
                emailErrorLabelHeight.isActive = false
            }
        }else{
            if isValidPassword(password: sender.text){
                pwdErrorLabelHeight.isActive = true
            }else{
                pwdErrorLabelHeight.isActive = false
            }
        }
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }
    
    func isValidEmail(email:String?)->Bool{
        guard email != nil else { return false}
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let pred = NSPredicate(format: "SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    func isValidPassword(password:String?)->Bool{
        if let hasPassword = password {
            if hasPassword.count < 4 {
                return false
            }
        }
        return true
    }
}
