//
//  ProfileEditViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/17.
//

import UIKit
import PhotosUI
import NVActivityIndicatorView

class ProfileEditViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            if let profileImageUrl = ConnectedUser.shared.user.userInfo.profileImageUrl, !profileImageUrl.isEmpty {
                let url = URL(string: profileImageUrl)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async { self.profileImageView.image = UIImage(data: data!) }
                }
            } else {
                profileImageView.image = UIImage(systemName: "person.crop.rectangle.fill")
            }
            let gesture = UITapGestureRecognizer(target: self, action: #selector(clickProfileImageView(imageView:)))
            profileImageView.addGestureRecognizer(gesture)
            profileImageView.isUserInteractionEnabled = true
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        }
    }
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.text = ConnectedUser.shared.user.userInfo.name
        }
    }
    @IBOutlet weak var stateMessageButton: UIButton! {
        didSet {
            if let oldStateMessage = oldStateMessage, oldStateMessage.count != 0 {
                //stateMessageButton.titleLabel?.text = oldStateMessage
                stateMessageButton.setTitle(oldStateMessage, for: .normal)
            } else {
                //stateMessageButton.titleLabel?.text = "상태 메시지를 입력해 주세요."
                stateMessageButton.setTitle("상태 메시지를 입력해 주세요.", for: .normal)
            }
            
        }
    }
    
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
    
    let oldStateMessage = ConnectedUser.shared.user.userInfo.stateMessage
    var newStateMessage: String?
    var fetchedImage:  PHFetchResult<PHAsset>?
    var doneCallback: ((String,UserInfo) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func clickEditStateMessageButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "EditStateMessageViewController", bundle: nil)
        let editStateMessageVC = storyboard.instantiateViewController(withIdentifier: "EditStateMessageViewController") as! EditStateMessageViewController
        editStateMessageVC.modalPresentationStyle = .overFullScreen
        editStateMessageVC.doneCallback = {
            statemessage in
            self.newStateMessage = statemessage
            if let newStateMessage = self.newStateMessage , newStateMessage.count > 0{
                self.stateMessageButton.setTitle(newStateMessage, for: .normal)
            }
        }
        present(editStateMessageVC, animated: false, completion: nil)
    }
    
    @IBAction func clickCancleButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickDoneButton(_ sender: Any) {
        
        indicator.startAnimating()
        var modifyUserInfo = ConnectedUser.shared.user.userInfo
        if fetchedImage != nil {
            DatabaseManager.shared.uploadImage(image: profileImageView.image!, uid: ConnectedUser.shared.uid, completion: {
                url in
                modifyUserInfo.profileImageUrl = url
                if let newStateMessage = self.newStateMessage, newStateMessage.count > 0 {
                    if self.oldStateMessage != newStateMessage {
                        DatabaseManager.shared.updateChildValues(["stateMessage": newStateMessage],forPath: "Users/\(ConnectedUser.shared.uid)/userInfo") {
                            _, _ in
                            modifyUserInfo.stateMessage = newStateMessage
                            self.doneCallback(ConnectedUser.shared.uid,modifyUserInfo)
                            self.indicator.stopAnimating()
                            self.dismiss(animated: false, completion: nil)
                        }
                    }
                } else {
                    self.doneCallback(ConnectedUser.shared.uid,modifyUserInfo)
                    self.indicator.stopAnimating()
                    self.dismiss(animated: false, completion: nil)
                }
            })
        } else {
            if let newStateMessage = newStateMessage, newStateMessage.count > 0 {
                if oldStateMessage != newStateMessage {
                    DatabaseManager.shared.updateChildValues(["stateMessage": newStateMessage],forPath: "Users/\(ConnectedUser.shared.uid)/userInfo") {
                        _, _ in
                        modifyUserInfo.stateMessage = newStateMessage
                        self.doneCallback(ConnectedUser.shared.uid,modifyUserInfo)
                        self.indicator.stopAnimating()
                        self.dismiss(animated: false, completion: nil)
                    }
                }
            } else {
                self.indicator.stopAnimating()
                self.dismiss(animated: false, completion: nil)
            }
        }
        
        
    }
}

// MARK: - Image View TapGesture Action Func , Gallery Func
extension ProfileEditViewController{
    @objc func clickProfileImageView(imageView: UIImageView){
        checkPermission()
    }
    
    func checkPermission(){
        if PHPhotoLibrary.authorizationStatus() == .authorized || PHPhotoLibrary.authorizationStatus() == .limited{ // authorized -> 사용자가 명시적으로 권한 부여 , limited -> 사용자가 이 앱에 제한된 권한을 승인 (선택한 몇개 만 사용 하겠다)
            DispatchQueue.main.async {
                self.showGallery()
            }
        }else if PHPhotoLibrary.authorizationStatus() == .denied{ //승인 거절 했을 경우
            DispatchQueue.main.async {
                self.showAuthorizationDeniedAlert()
            }
        }else if PHPhotoLibrary.authorizationStatus() == .notDetermined{ // 사용자가 앱의 인증상태를 설정하지 않은 경우 ex) 앱을 설치하고 처음 실행
            PHPhotoLibrary.requestAuthorization { status in
                self.checkPermission()
            }
        }
    }
    func showGallery(){
        let library = PHPhotoLibrary.shared() //singleton pattern
        var configuration = PHPickerConfiguration(photoLibrary: library)
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    func showAuthorizationDeniedAlert(){
        let alert = UIAlertController(title: "포토라이브러리의 접근 권환을 활성화 해주세요.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "설정으로 가기", style: .default, handler: { action in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url, options: [:],completionHandler: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - PHPickerViewControllerDelegate
extension ProfileEditViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let identifiers = results.map{ $0.assetIdentifier ?? ""}
        fetchedImage = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        profileImageView.loadImage(asset: fetchedImage?[0])
        self.dismiss(animated: true, completion: nil)
    }
}
