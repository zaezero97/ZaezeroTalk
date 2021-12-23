//
//  LoginViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/07.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.addTarget(self, action: #selector(checkValidText), for: .editingChanged)
            emailTextField.delegate = self
        }
    }
    
    @IBOutlet weak var pwdTextField: UITextField! {
        didSet {
            pwdTextField.addTarget(self, action: #selector(checkValidText), for: .editingChanged)
            pwdTextField.delegate = self
        }
    }
    @IBOutlet weak var pwdErrorLabel: UILabel! {
        didSet {
            pwdErrorLabelHeight = pwdErrorLabel.heightAnchor.constraint(equalToConstant: 0)
            pwdErrorLabelHeight.isActive = true
        }
    }
    @IBOutlet weak var emailErrorLabel: UILabel! {
        didSet {
            emailErrorLabelHeight  = emailErrorLabel.heightAnchor.constraint(equalToConstant: 0)
            emailErrorLabelHeight.isActive = true
        }
    }
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.backgroundColor = .black
        }
    }
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            loginButton.backgroundColor = .black
        }
    }
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var emailErrorLabelHeight : NSLayoutConstraint!
    var pwdErrorLabelHeight : NSLayoutConstraint!
    
    /// 로딩 activity indicator 뷰
    lazy var indicator: NVActivityIndicatorView = {
        let indicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 75, height: 75),
                                                type: .ballRotateChase,
                                                color: .black,
                                                padding: 0)
        self.view.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try! Auth.auth().signOut() //test 코드 실제에선 자동 로그인으로 구현할 생각
        
     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /// 로그인 버튼 클릭 이벤트
    /// - Parameter sender: 로그인 버튼
    @IBAction func clicklLoginButton(_ sender: Any) {
        guard let email = emailTextField.text , let password = pwdTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) {
            (result, error) in
            self.indicator.startAnimating()
            if error != nil { //로그인 실패
                self.indicator.stopAnimating()
                let alert = UIAlertController(title: "로그인 에러!!!", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else { // 로그인 성공
                guard let result = result else { return }
                ///  로그인한 유저의 정보를 가져오고 가져온 정보를 ConnectedUser 싱글톤 객체에 저장하고 화면 전환
                DatabaseManager.shared.fetchUser(uid: result.user.uid, completion: {
                    user in
                    ConnectedUser.shared.user = user
                    ConnectedUser.shared.uid = result.user.uid
                    
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                        let storyboard = UIStoryboard(name: "TabbarViewController", bundle: nil)
                        let TabbarVC = storyboard.instantiateViewController(withIdentifier: "TabbarViewController")
                        TabbarVC.modalPresentationStyle = .fullScreen
                        self.present(TabbarVC, animated: true,completion: {
                        })
                    }
                })
            }
        }
    }
    
    /// 회원 가입 버튼 클릭 이벤트
    /// - Parameter sender: sign up 버튼
    @IBAction func clickSignUp(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SignUpViewController", bundle: nil)
        let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController")
        present(signUpVC, animated: true, completion: nil)
    }
    
    ///  외부 뷰 클릭 시 키보드 내리기
    /// - Parameters:
    ///   - touches:
    ///   - event:
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - textField func
extension LoginViewController{
    ///  TextField 유효 입력 테스트 메소드
    /// - Parameter sender: emailTextField or pwdTextField
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
    
    /// 유효한 이메일 입력 검증 메소드
    /// - Parameter email: emailTextField 의 입력된 Text
    /// - Returns: 유효 True 무효 False
    func isValidEmail(email:String?) -> Bool{
        guard email != nil else { return false }
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let pred = NSPredicate(format: "SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    
    /// 유효한 비밀번호 입력 검증 메소드
    /// - Parameter password: pwdTextField의 입력된 Text
    /// - Returns:유효 True 무효 False
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
    /// TextField Return 키 입력 Delegate 메소드
    /// - Parameter textField: Return 키를 입력한 TextField
    /// - Returns: true
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // textField의 현재상태를 포기한다 즉 올라와 있는 상태를 포기 한다.
        return true
    }
}

