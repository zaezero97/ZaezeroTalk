//
//  LoginViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/07.
//

import UIKit
import Firebase

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
        try! Auth.auth().signOut()
        
        emailTextField.addTarget(self, action: #selector(checkValidText), for: .editingChanged)
        pwdTextField.addTarget(self, action: #selector(checkValidText), for: .editingChanged)
        
        emailTextField.delegate = self
        pwdTextField.delegate = self
        
        emailErrorLabelHeight  = emailErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        pwdErrorLabelHeight = pwdErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        emailErrorLabelHeight.isActive = true
        pwdErrorLabelHeight.isActive = true
        
        if let color = remoteConfig["app_color"].stringValue{
            loginButton.backgroundColor = UIColor(hex: color)
            signUpButton.backgroundColor = UIColor(hex: color)
        }
    }

    @IBAction func clicklLoginButton(_ sender: Any) {
        guard let email = emailTextField.text , let password = pwdTextField.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            print(result?.user.email)
            print(error)
            let storyboard = UIStoryboard(name: "TabbarViewController", bundle: nil)
            let TabbarVC = storyboard.instantiateViewController(withIdentifier: "TabbarViewController")
            TabbarVC.modalPresentationStyle = .fullScreen
            self.present(TabbarVC, animated: true, completion: nil)
        }
    }
    @IBAction func clickSignUp(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SignUpViewController", bundle: nil)
        let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController")
        present(signUpVC, animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) // 외부 뷰 클릭 시 키보드 내리기
    }
}
// MARK: - textField func
extension LoginViewController{
    @objc func checkValidText(sender : UITextField){
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

// MARK: - TextField delegate : return 키를 누를 시에 키보드 내리기
extension LoginViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // textField의 현재상태를 포기한다 즉 올라와 있는 상태를 포기 한다.
        return true
    }
}

