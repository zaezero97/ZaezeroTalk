//
//  DatabaseManager.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/08.
//

import Foundation
import Firebase
import FirebaseDatabase

class DatabaseManager{
    static let shared = DatabaseManager()
    let ref = Database.database().reference()
    var roomObserver: UInt?
    private init(){
        
    }
    
    func setValue(_ value: [String: Any], forPath path: String){
        ref.child(path).setValue(value)
    }
    
    func updateChildValues(_ value: [String: Any], forPath path: String){
        ref.child(path).updateChildValues(value)
    }
    func updateChildValues(_ value: [String: Any], forPath path: String, completion: @escaping (Error?,DatabaseReference)-> Void){
        ref.child(path).updateChildValues(value,withCompletionBlock: completion)
    }
    func fetchUid(email: String,compltion: @escaping (String) -> Void) {
        ref.child("Users")
    }
    func fetchUser(email : String ,completion : @escaping (User?) -> Void){
        ref.child("Users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { snapshot in
            do{
            let data = try JSONSerialization.data(withJSONObject: snapshot.value!, options: .prettyPrinted)
            let result = try JSONDecoder().decode(User.self, from: data)
                completion(result)
            } catch {
                print("-> Error : \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func fetchUser(uid: String, completion : @escaping (User?) -> Void) {
        ref.child("Users/\(uid)").observeSingleEvent(of: .value, with: {
            snapshot in
            do{
            let data = try JSONSerialization.data(withJSONObject: snapshot.value!, options: .prettyPrinted)
            let result = try JSONDecoder().decode(User.self, from: data)
                completion(result)
            } catch {
                print("-> Error : \(error.localizedDescription)")
                completion(nil)
            }
        })
    }
    
    func fetchUserInfo(uid: String, completion : @escaping (UserInfo?) -> Void){
        ref.child("Users/\(uid)/userInfo").observeSingleEvent(of: .value, with: {
            snapshot in
            do{
            let data = try JSONSerialization.data(withJSONObject: snapshot.value!, options: .prettyPrinted)
            let result = try JSONDecoder().decode(UserInfo.self, from: data)
                completion(result)
            } catch {
                print("-> Error : \(error.localizedDescription)")
                completion(nil)
            }
        })
    }
    func fetchUserInfo(email: String, completion : @escaping (UserInfo?) -> Void){
        ref.child("Users/userInfo").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: {
            snapshot in
            do{
            let data = try JSONSerialization.data(withJSONObject: snapshot.value!, options: .prettyPrinted)
            let result = try JSONDecoder().decode(UserInfo.self, from: data)
                completion(result)
            } catch {
                print("-> Error : \(error.localizedDescription)")
                completion(nil)
            }
        })
    }
    func registerUserObserver(by uid: String) {
        ref.child("Users/\(uid)").observe(.value) {
            snapshot in
            do{
            let data = try JSONSerialization.data(withJSONObject: snapshot.value!, options: .prettyPrinted)
            let result = try JSONDecoder().decode(User.self, from: data)
                ConnectedUser.shared.uid = snapshot.key
                ConnectedUser.shared.user = result
            } catch {
                print("-> Error : \(error.localizedDescription)")
            }
        }
    }
    func registerUserInfoObserver(forUid uid: String){
        ref.child("Users/\(uid)/userInfo").observe(.value, with: {
            snapshot in
            let userInfo = snapshot.value as? [String: Any]
            let email = userInfo?["email"] as? String ?? ""
            let name = userInfo?["name"] as? String ?? ""
            ConnectedUser.shared.user.userInfo = UserInfo(email: email, name: name)
        })
    }
//    func registerFriendsOfUserObserver(forUid uid: String){
//        ref.child("Users/\(uid)/friends").observe(.value, with: {
//            snapshot in
//            let fetchedFriends = snapshot.value as? [String: Any]
//
//            guard let fetchedFriends = fetchedFriends else { return }
//            let keys = fetchedFriends.keys
//            var friend_arr = [Friend]()
//            if snapshot.exists() {
//                for key in keys {
//                    let friendInfo = fetchedFriends[key] as! [String: Any]
//                    let friendName = friendInfo["name"] as! String
//                    let email = friendInfo["email"] as! String
//                    friend_arr.append(Friend(uid: key, email: email, name: friendName))
//                }
//                ConnectedUser.shared.user.friends = friend_arr
//            }
//
//        })
//    }
   
    
//    func createRoomWithObserver(participantUids: [String], message msg: String, name: String, observerCompletion : @escaping (ChatingRoom) -> Void) {
//        let autoId = ref.childByAutoId().key!
//        let msgAutoId = ref.childByAutoId().key!
//        var participants = [String: Any]()
//        participants[ConnectedUser.shared.user.uid] = true
//        participantUids.forEach { uid in
//            participants[uid] = false
//        }
//        let message: [String: Any] = [
//            "sender": ConnectedUser.shared.user.uid,
//            "time": ServerValue.timestamp(),
//            "readUsers": [ConnectedUser.shared.user.uid : 1],
//            "type": MessageType.Text.rawValue,
//            "content": msg
//        ]
//        let room: [String: Any] = [
//            "participants": participants,
//            "name": name,
//            "messages": [msgAutoId: message]
//        ]
//        ref.child("Rooms").child(autoId).setValue(room,withCompletionBlock:{
//            (error,ref) in
//            self.registerRoomObserver(id: autoId, completion: observerCompletion)
//        })
//    }
//
//    func fetchRoom(participantUids: [String], completion: @escaping (ChatingRoom?) -> Void) {
//        ref.child("Rooms").queryOrdered(byChild: "participants/\(ConnectedUser.shared.user.uid)").queryEqual(toValue: true).observeSingleEvent(of: .value, with: {
//            snapshot in
//            guard snapshot.exists() else { return }
//            for child in snapshot.children {
//                let child = child as! DataSnapshot
//                let room = child.value as! [String: Any]
//                let name = room["name"] as! String
//                let participants = room["participants"] as! [String: Any]
//                let meesagesDic = room["messages"] as! [String: Any]
//                var messages = [Message]()
//
//                meesagesDic.values.forEach { value in
//                    let message = value as! [String: Any]
//                    let sender = message["sender"] as! String
//                    let time = message["time"] as! [AnyHashable: Any]
//                    let readUsers = message["readUsers"] as! [String: Any]
//                    let type = message["type"] as! String
//                    let content = message["content"] as! String
//                    messages.append(Message(sender: sender, time: time, readUsers: readUsers, type: type, content: content))
//                }
//
//                let fetchedRoom = ChatingRoom(participants: participants, name: name, messages: messages,id: snapshot.key)
//                completion(fetchedRoom)
//            }
//
//
//        })
//    }
//
//    func registerRoomObserver(id roomId: String,completion: @escaping (ChatingRoom) -> Void)
//    {
//
//        roomObserver = ref.child("Rooms/\(roomId)").observe(.value) { snapshot in
//            let room = snapshot.value as! [String: Any]
//            let participants = room["participants"] as! [String: Any]
//            let name = room["name"] as! String
//            var messages = [Message]()
//            let messagesDic = room["messages"] as! [String: Any]
//
//            messagesDic.values.forEach { value in
//                let message = value as! [String: Any]
//                let sender = message["sender"] as! String
//                let time = message["time"] as! [AnyHashable: Any]
//                let readUsers = message["readUsers"] as! [String: Any]
//                let type = message["type"] as! String
//                let content = message["content"] as! String
//                messages.append(Message(sender: sender, time: time, readUsers: readUsers, type: type, content: content))
//            }
//            completion(ChatingRoom(participants: participants, name: name, messages: messages, id: roomId))
//        }
//    }
//
//    func sendMessage(sendMessage: Message, room: ChatingRoom){
//        var messageDic = [String: Any]()
//        messageDic["sender"] = sendMessage.sender
//        messageDic["content"] = sendMessage.content
//        messageDic["readUsers"] = sendMessage.readUsers
//        messageDic["time"] = sendMessage.time
//        messageDic["type"] = sendMessage.type
//        let messageAutoId = ref.childByAutoId().key!
//        updateChildValues([messageAutoId: messageDic], forPath: "Rooms/\(room.id)/messages")
//
//    }
//
//    func removeRoomObserser(){
//        guard let roomObserver = roomObserver else {
//            return
//        }
//        ref.removeObserver(withHandle: roomObserver)
//    }
}
