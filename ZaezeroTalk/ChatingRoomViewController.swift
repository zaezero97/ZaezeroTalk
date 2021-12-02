//
//  ChatingRoomViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/12.
//

import UIKit
import Firebase
import PhotosUI


class ChatingRoomViewController: UIViewController {
    var optionFlag = false
    var keyboardFrame: CGRect!
    @IBOutlet weak var inputTextViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var inputTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            sendButton.isEnabled = false
            sendButton.tintColor = .darkGray
        }
    }//버튼 초기 비활성화 상태 지정
    @IBOutlet weak var inputTextView: UITextView! {
        didSet {
            inputTextView.delegate = self
            inputTextView.layer.cornerRadius = inputTextView.bounds.height / 2
        }
    }
    @IBOutlet weak var chatingTableView: UITableView! {
        didSet {
            
            chatingTableView.delegate = self
            chatingTableView.dataSource = self
            chatingTableView.estimatedRowHeight = 10
            chatingTableView.rowHeight = UITableView.automaticDimension
            chatingTableView.separatorStyle = .none
            chatingTableView.register(UINib(nibName: "UserExitMessageCell", bundle: nil), forCellReuseIdentifier: "UserExitMessageCell")
            chatingTableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forCellReuseIdentifier: "myMessageCell")
            chatingTableView.register(UINib(nibName: "OtherPersonMessageCell", bundle: nil), forCellReuseIdentifier: "otherPersonMessageCell")
            chatingTableView.register(UINib(nibName: "MyPhotoMessageCell", bundle: nil), forCellReuseIdentifier: "MyPhotoMessageCell")
            chatingTableView.register(UINib(nibName: "OtherPersonPhotoMessageCell", bundle: nil), forCellReuseIdentifier: "OtherPersonPhotoMessageCell")
        }
    }
    
    /// 첨부 버튼 클릭 시 보여 줄 TextView Input View
    lazy var customInputView: CustomInputView = {
        let inputView = Bundle.main.loadNibNamed("CustomInputView", owner: self, options: nil)?.first as! CustomInputView
        
        inputView.frame = keyboardFrame
        inputView.scrollView.frame = inputView.bounds
        inputView.scrollView.contentSize = CGSize(width: inputView.bounds.width * 2, height: inputView.bounds.height)
        
        let firstView = Bundle.main.loadNibNamed("CustomInputFirstView", owner: self, options: nil)?.first as! CustomInputFirstView
        let secondView = Bundle.main.loadNibNamed("CustomInputSecondView", owner: self, options: nil)?.first as! UIView
        
        firstView.frame = inputView.bounds
        secondView.frame = inputView.bounds
        secondView.frame.origin.x = inputView.bounds.width
        inputView.scrollView.addSubview(firstView)
        inputView.scrollView.addSubview(secondView)
        
        firstView.galleryButton.addTarget(self, action: #selector(clickGalleryButton), for: .touchUpInside)
        //firstView.cameraButton.addTarget(self, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        
        inputView.pageControll.currentPage = 0
        inputView.pageControll.numberOfPages = 2
        inputView.pageControll.pageIndicatorTintColor = .lightGray // 페이지를 암시하는 동그란 점의 색상
        inputView.pageControll.currentPageIndicatorTintColor = .black
        inputView.scrollView.showsHorizontalScrollIndicator = false
        inputView.scrollView.showsVerticalScrollIndicator = false
        inputView.scrollView.isScrollEnabled = true
        inputView.scrollView.isPagingEnabled = true
        inputView.scrollView.delegate = self // scroll범위에 따라 pageControl의 값을 바꾸어주기 위한 delegate
        inputView.bringSubviewToFront(inputView.pageControll)
        
        return inputView
    }()
    
    
    /// 필수 데이터
    var participantUids = [String]()
    var roomName: String?
    var participants = [String: UserInfo]() {
        didSet {
            setNavigationBarTitle()
        }
    } // key: uid, value: UserInfo
    lazy var roomType: String = {
        if participants.count > 2 {
            return "1:N"
        } else {
            return "1:1"
        }
    }()
    
    ///  key: uid, value: profileImage
    /// didSet: 참가자의 프로필 이미지가 변경되어 옵저버로 감지하고 값이 변경되면 테이블을 reload한다.
    var participantImages = [String: UIImage]() {
        didSet {
            chatingTableView.reloadData()
        }
    }
    
    var curRoomId: String?
    var curRoomInfo: ChatingRoom?
    var messages = [Message]() {
        didSet {
            print("Messages!!!! -> ",messages)
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //   inputTextView.inputView = customInputView
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        fetchCurrentRoom() ///동기
        fetchParticipantInfos() /// 비동기
        
        roomName = roomName ?? curRoomInfo?.name
        roomType = curRoomInfo?.type ?? ""
        
        setNavigationBarTitle()
        
        if let curRoomInfo = curRoomInfo , let curRoomId = curRoomId {
            DatabaseManager.shared.enterRoom(uid: ConnectedUser.shared.uid, roomId: curRoomId)
            DatabaseManager.shared.readMessage(messages: curRoomInfo.messages, roomId: curRoomId)
            DatabaseManager.shared.registerMessageObserver(roomId: curRoomId) {
                fetchedMessages in
                guard let fetchedMessages = fetchedMessages else {
                    return
                }
                self.messages = fetchedMessages
                self.chatingTableView.reloadData()
                self.chatingTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
            }
            
        }
        // 방에 입장 시 방이 존재하면 방의 정보를 가져오고 방의 상태 변경을 감지하는 옵저버를 등록한다,
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DatabaseManager.shared.removeMessageObserver()
        guard let curRoomId = curRoomId else {
            return
        }
        DatabaseManager.shared.leaveRoom(uid: ConnectedUser.shared.uid, roomId: curRoomId)
    }
    
    ///  메뉴 버튼 클릭 이벤트 - 사이드 메뉴
    /// - Parameter sender: 메뉴 바 버튼
    @IBAction func clickMenuButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SideMenuViewController", bundle: nil)
        let sideMenuNavigationVC = storyboard.instantiateViewController(withIdentifier: "CustomSideMenuNavigationController") as! CustomSideMenuNavigationController
        let sideMenuVC = sideMenuNavigationVC.viewControllers.first as! SideMenuViewController
        sideMenuVC.delegate = self
        sideMenuVC.participants = participants.map({ ($0.key,$0.value) })
        present(sideMenuNavigationVC, animated: true, completion: nil)
    }
    
    @IBAction func clickBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickSendButton(_ sender: Any) {
        send(type: "text", text: inputTextView.text!, image: nil)
        
    }
    @IBAction func clickSendOptionButton(_ sender: Any) {
        optionFlag.toggle()
        
        if inputTextView.isFirstResponder == false {
            inputTextView.becomeFirstResponder()
        } else {
            inputTextView.inputView = optionFlag ? customInputView : nil
            inputTextView.reloadInputViews()
        }
        
    }
}

// MARK: - TableView DataSource
extension ChatingRoomViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard curRoomId != nil else { return UITableViewCell() }
        let message = messages[indexPath.row]
        
        switch message.type {
        case "exit": return makeExitCell(tableView: tableView, indexPath:indexPath, message: message)
        case "image": return makePhotoMessageCell(tableView: tableView, indexPath:indexPath, message: message)
        default : return makeMessageCell(tableView: tableView, indexPath:indexPath, message: message)
        }
        
        
    }
    
}
    
    

// MARK: - TableView Delegate
extension ChatingRoomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        if message.type == "image" {
            let storyboard = UIStoryboard(name: "PhotoDetailViewController", bundle: nil)
            let photoDetailVC = storyboard.instantiateViewController(withIdentifier: "PhotoDetailViewController") as! PhotoDetailViewController
            photoDetailVC.modalTransitionStyle = .crossDissolve
            photoDetailVC.modalPresentationStyle = .fullScreen
            
            present(photoDetailVC, animated: true, completion: {
                photoDetailVC.photoImageView.setImageUrl(message.content!)
            })
        }
    }
}

// MARK: - TextView Delegate
extension ChatingRoomViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            sendButton.tintColor = .yellow
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
            sendButton.tintColor = .darkGray
        }
        
        if textView.contentSize.height <= 30{
            inputTextViewHeightConstraint.constant = 30
        } else if textView.contentSize.height >= 100 {
            inputTextViewHeightConstraint.constant = 100
        } else {
            inputTextViewHeightConstraint.constant = textView.contentSize.height
        }
    }
}

// MARK: - Make Table View Cell method
extension ChatingRoomViewController {
    func makeExitCell(tableView: UITableView,indexPath: IndexPath, message: Message) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserExitMessageCell", for: indexPath) as! UserExitMessageCell
        cell.userExitMessageLebel.text = messages[indexPath.row].content
        
        return cell
    }
    
    func makeMessageCell(tableView: UITableView,indexPath: IndexPath, message: Message) -> UITableViewCell {
        guard let readUsers = message.readUsers else { return UITableViewCell() }
        if message.sender == ConnectedUser.shared.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myMessageCell", for: indexPath) as! MyMessageCell
            cell.contentTextView.text = message.content
            cell.timeLabel.text = message.time?.toDayTime
            cell.readCountLabel.text = calReadUserCount(readUsers: readUsers) == 0 ? "" : String(calReadUserCount(readUsers: readUsers))
            
            if let profileImage = participantImages[message.sender!] {
                cell.profileImageView.image = profileImage
            } else {
                cell.profileImageView.image = UIImage(systemName: "person.crop.rectangle.fill")
            }
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
            cell.nameLabel.text = participants[message.sender!]?.name ?? ""
            
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "otherPersonMessageCell", for: indexPath) as! OtherPersonMessageCell
            cell.contentTextView.text = message.content
            cell.timeLabel.text = message.time?.toDayTime
            cell.readCountLabel.text = calReadUserCount(readUsers: readUsers) == 0 ? "" : String(calReadUserCount(readUsers: readUsers))
            if let profileImage = participantImages[message.sender!] {
                cell.profileImageView.image = profileImage
            } else {
                cell.profileImageView.image = UIImage(systemName: "person.crop.rectangle.fill")
            }
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
            cell.nameLabel.text = participants[message.sender!]?.name ?? ""
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func makePhotoMessageCell(tableView: UITableView,indexPath: IndexPath, message: Message) -> UITableViewCell {
        guard let readUsers = message.readUsers else { return UITableViewCell() }
        if message.sender == ConnectedUser.shared.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyPhotoMessageCell", for: indexPath) as! MyPhotoMessageCell
            cell.messageImageView.image = UIImage(systemName: "rays")
            DispatchQueue.main.async {
                if let index: IndexPath = tableView.indexPath(for: cell) {
                    if index.row == indexPath.row {
                        cell.messageImageView.setImageUrl(message.content!)
                        cell.messageImageView.layer.cornerRadius = 10
                        cell.messageImageView.snp.makeConstraints { make in
                            make.height.equalTo(200)
                        }
                    }
                }
            }
            cell.timeLabel.text = message.time?.toDayTime
            cell.readCountLabel.text = calReadUserCount(readUsers: readUsers) == 0 ? "" : String(calReadUserCount(readUsers: readUsers))
            
            if let profileImage = participantImages[message.sender!] {
                cell.profileImageView.image = profileImage
            } else {
                cell.profileImageView.image = UIImage(systemName: "person.crop.rectangle.fill")
            }
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
            cell.nameLabel.text = participants[message.sender!]?.name ?? ""
            
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherPersonPhotoMessageCell", for: indexPath) as! OtherPersonPhotoMessageCell
            cell.messageImageView.image = UIImage(systemName: "rays")
            DispatchQueue.main.async {
                if let index: IndexPath = tableView.indexPath(for: cell) {
                    if index.row == indexPath.row {
                        cell.messageImageView.setImageUrl(message.content!)
                    }
                }
            }
            cell.timeLabel.text = message.time?.toDayTime
            cell.readCountLabel.text = calReadUserCount(readUsers: readUsers) == 0 ? "" : String(calReadUserCount(readUsers: readUsers))
            
            if let profileImage = participantImages[message.sender!] {
                cell.profileImageView.image = profileImage
            } else {
                cell.profileImageView.image = UIImage(systemName: "person.crop.rectangle.fill")
            }
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
            cell.nameLabel.text = participants[message.sender!]?.name ?? ""
            
            cell.selectionStyle = .none
            return cell
        }
        
    }
}


// MARK: - Fetch Data
extension ChatingRoomViewController {
    
    /// 방이 존재하면 방의 정보를 가져오는 함수
    func fetchCurrentRoom() {
        guard let roomList = ConnectedUser.shared.chatingRoomList else { return }
        // 현재 사용자가 참여하고 있는 방 리스트
        
        if let curRoomId = curRoomId {
            for room in roomList {
                if room.id == curRoomId {
                    return curRoomInfo = room.info
                }
            } // 채팅방 리스트를 통해 방에 입장했을경우
        } else {
            let curRoom = roomList.first { (id, info) in
                let sortedRoomInfoUids = info.uids.toFBArray().sorted()
                let sortedParticipantUids = participantUids.sorted()
                
                if sortedRoomInfoUids == sortedParticipantUids {
                    return true
                } else {
                    return false
                }
            } // 1대1 채팅으로 통해 방에 입장 했을 경우
            
            curRoomId = curRoom?.id
            curRoomInfo = curRoom?.info
        }
    }
    
    // 현재 참가자들의 정보를 가져오는 함수
    func fetchParticipantInfos() {
        for uid in participantUids {
            DatabaseManager.shared.registerUserInfoObserver(forUid: uid) {
                userInfo in
                self.participants[uid] = userInfo
                let profileImageUrl = userInfo.profileImageUrl
                if let profileImageUrl = profileImageUrl, !profileImageUrl.isEmpty {
                    let url = URL(string: profileImageUrl)
                    DispatchQueue.global().async {
                        let data = try? Data(contentsOf: url!)
                        DispatchQueue.main.async { self.participantImages[uid] = UIImage(data: data!) }
                    }
                }
            }
        }
    }
}

// MARK: - keyboard func
extension ChatingRoomViewController {
    
    @objc func keyboardWillShow(noti : Notification){
        let notiInfo = noti.userInfo!
        keyboardFrame = notiInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let animationDuration = notiInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        UIView.animate(withDuration: animationDuration) {
            self.inputTextView.inputView = self.optionFlag ? self.customInputView : nil
            self.inputTextView.reloadInputViews()
            self.inputTextViewBottomMargin.constant = self.keyboardFrame.size.height + 20
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardDidHide(noti : Notification){
        let notiInfo = noti.userInfo!
        let animationDuration = notiInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        optionFlag = false
        
        UIView.animate(withDuration: animationDuration) {
            self.inputTextViewBottomMargin.constant = 20
            self.view.layoutIfNeeded()
        }
    }
}


// MARK: - read User Count 계산
extension ChatingRoomViewController {
    /// read User Count 계산
    /// - Returns: read Count
    /// - Parameter readUsers: 메시지 읽은 유저 Dictionary
    func calReadUserCount(readUsers: [String: String]) -> Int {
        guard let curRoomInfo = curRoomInfo else { return 0 }
        
        let readUsersSet = Set(readUsers.keys)
        let participantsSet = Set(curRoomInfo.uids.toFBArray())
        
        let result = participantsSet.subtracting(readUsersSet)
        return result.count
    }
}

// MARK: - Side Menu Exit Delegate
extension ChatingRoomViewController: Exitdelegate {
    
    ///  방 나가기 클릭시 실행 될 Exitdelegate 메소드
    /// - Parameter roomDismiss: 방나가기 로직이 실행된 후 실행 될 dismiss 로직
    func roomExit() {
        guard let curRoomId = self.curRoomId , let curRoomInfo = self.curRoomInfo else {
            print(self)
            self.presentingViewController!.dismiss(animated: false, completion: nil)
            return
        }
        DatabaseManager.shared.exitRoom(roomId: curRoomId, roomInfo: curRoomInfo) { _, _ in
            self.presentingViewController!.dismiss(animated: false, completion: nil)
        }
        self.curRoomId = nil
    }
    
}

// MARK: - Set Navigation bar title
extension ChatingRoomViewController {
    func setNavigationBarTitle() {
        if let roomName = roomName {
            customNavigationItem.title = roomName
        } else if roomType == "1:N" {
            customNavigationItem.title = "그룹채팅 " + String(participants.count)
        } else {
            customNavigationItem.title = participants.values.map({$0.name}).sorted().first(where: {$0 != ConnectedUser.shared.user.userInfo.name
            })
        }
    }
}

// MARK: - Input View Scroll delegate
extension ChatingRoomViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView != chatingTableView else { return }
        
        print("scrollView -> ",scrollView.description)
        customInputView.pageControll.currentPage = Int(floor(scrollView.contentOffset.x / customInputView.bounds.width))
    }
}

// MARK: - Custom Input First View action methods
extension ChatingRoomViewController {
    @objc func clickGalleryButton(imageView: UIImageView){
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
extension ChatingRoomViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let identifiers = results.map{ $0.assetIdentifier ?? ""}
        let fetchedImage = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)[0]
        fetchedImage.loadImage { image in
            self.send(type: "image", text: nil, image: image)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - Send Message (Image,Text)
extension ChatingRoomViewController {
    func send(type: String, text: String?, image: UIImage?) {
        
        var message : [String: Any] = [
            "sender": ConnectedUser.shared.uid,
            "time": ServerValue.timestamp(),
            "type": type
        ]
        
        if type == "text" {
            message["content"] = text
        } else if type == "image" {
            message["content"] = image
        }
        
        if let curRoomId = curRoomId {
            DatabaseManager.shared.sendMessage(sendMessage: message, roomId: curRoomId)
        } else {
            let type = participants.count > 2 ? "1:N" : "1:1"
            DatabaseManager.shared.createRoom(message: message, participantUids: participantUids, participantNames: participants.values.map{$0.name}, name: roomName,type: type ,completion: {
                roomId,roomInfo in
                self.curRoomId = roomId
                self.curRoomInfo = roomInfo
                DatabaseManager.shared.registerMessageObserver(roomId: roomId) {
                    fetchedMessages in
                    guard let fetchedMessages = fetchedMessages else {
                        return
                    }
                    
                    self.messages = fetchedMessages
                    self.chatingTableView.reloadData()
                    self.chatingTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
                }
            })
        }// 방이 존재하면 메시지를 보내고 존재하지 않으면 새로 방을 만들고 room의 상태변화를 감지하는 옵저버를 등록한다.
    }
}


