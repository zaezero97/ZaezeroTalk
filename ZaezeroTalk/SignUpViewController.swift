//
//  SignUpViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/08.
//

import UIKit
import FirebaseAuth

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
    
    private var labelHeightConstraints = [UILabel : NSLayoutConstraint]()
    private var isAllValid = false
    private let pwdMinLength = 6
    override func viewDidLoad() {
        super.viewDidLoad()
        labelHeightConstraints[emailErrorLabel] = emailErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        labelHeightConstraints[nameErrorLabel] = nameErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        labelHeightConstraints[pwdErrorLabel] = pwdErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        labelHeightConstraints[pwdCheckErrorLabel] = pwdCheckErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        
        labelHeightConstraints[emailErrorLabel]?.isActive = true
        labelHeightConstraints[nameErrorLabel]?.isActive = true
        labelHeightConstraints[pwdErrorLabel]?.isActive = true
        labelHeightConstraints[pwdCheckErrorLabel]?.isActive = true
        
        confirmButton.layer.cornerRadius = confirmButton.bounds.height / 2
        
        emailTextField.delegate = self
        pwdTextField.delegate = self
        nameTextField.delegate = self
        pwdCheckTextField.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) // 외부 뷰 클릭 시 키보드 내리기
    }
    @IBAction func touchConfirmButton(_ sender: Any) {
        isAllValid = true
        if isValidEmail(email: emailTextField.text){
            labelHeightConstraints[emailErrorLabel]?.isActive = true
        }else{
            labelHeightConstraints[emailErrorLabel]?.isActive = false
            isAllValid = false
        }
        if isValidName(name: nameTextField.text){
            labelHeightConstraints[nameErrorLabel]?.isActive = true
        }else{
            labelHeightConstraints[nameErrorLabel]?.isActive = false
            isAllValid = false
        }
        if isValidPassword(password: pwdTextField.text){
            labelHeightConstraints[pwdErrorLabel]?.isActive = true
        }else{
            labelHeightConstraints[pwdErrorLabel]?.isActive = false
            isAllValid = false
        }
        if isEqualPassword(with: pwdCheckTextField.text){
            labelHeightConstraints[pwdCheckErrorLabel]?.isActive = true
        }else{
            labelHeightConstraints[pwdCheckErrorLabel]?.isActive = false
            isAllValid = false
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        if isAllValid{
            Auth.auth().createUser(withEmail: emailTextField.text!, password: pwdTextField.text!) {
                (result,error) in
                print(result?.user.uid)
                self.dismiss(animated: true, completion: nil)
            }
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
            if hasPassword.count < pwdMinLength {
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

// MARK: - TextField delegate : return 키를 누를 시에 키보드 내리기
extension SignUpViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // textField의 현재상태를 포기한다 즉 올라와 있는 상태를 포기 한다.
        return true
    }
}
