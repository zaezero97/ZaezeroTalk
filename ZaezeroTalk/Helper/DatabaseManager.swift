//
//  DatabaseManager.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/08.
//

import Foundation
import Firebase

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
    func fetchUid(email: String,compltion: @escaping (String?) -> Void) {
        ref.child("Users").queryOrdered(byChild: "userInfo/email").queryEqual(toValue: email).observeSingleEvent(of: .value) { snapshot in
            let child = snapshot.value as! [String: Any]
            compltion(child.keys.first)
        }
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
                print(data)
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
        ref.child("Users").queryOrdered(byChild: "userInfo/email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: {
            snapshot in
            guard snapshot.exists() else {
                completion(nil)
                return
            }
            let child = snapshot.value as! [String: Any]
            let userInfoDictionary = child[child.keys.first!] as! [String: Any]
            
            do{
                let data = try JSONSerialization.data(withJSONObject: userInfoDictionary["userInfo"]!, options: .prettyPrinted)
                let result = try JSONDecoder().decode(UserInfo.self, from: data)
                completion(result)
                print(result)
            } catch {
                print("-> Error : \(error.localizedDescription)")
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
            let stateMessage = userInfo?["stateMessage"] as? String ?? ""
            ConnectedUser.shared.user.userInfo = UserInfo(email: email, name: name, stateMessage: stateMessage)
        })
    }
    
}

// MARK: - Room
extension DatabaseManager {
    func registerRoomListObserver(uid: String, completion: @escaping ([(id: String, info: ChatingRoom)]?) -> Void) {
        
        ref.child("Rooms").queryOrdered(byChild: "uids").queryStarting(atValue: "%${\(uid)}%").queryEnding(atValue: uid+"\u{F8FF}").observe(.value, with: {
            snapshot in
            var chatingRooms = [(id: String ,info: ChatingRoom)]()
            do{
                for child in snapshot.children {
                    let child = child as! DataSnapshot
                    let data = try JSONSerialization.data(withJSONObject: child.value!, options: .prettyPrinted)
                    let result = try JSONDecoder().decode(ChatingRoom.self, from: data)
                    chatingRooms.append((child.key,result))
                }
                completion(chatingRooms)
            } catch {
                print("-> Error registerRoomListObserver: \(error.localizedDescription)")
                completion(nil)
            }
            
        })
    }
    
    func sendMessage(sendMessage: [String: Any], room: (id: String ,info: ChatingRoom)) {
        let messageAutoId = ref.childByAutoId().key!
        updateChildValues([messageAutoId: sendMessage], forPath: "Rooms/\(room.id)/messages")
    }
    func registerRoomObserver(id: String,completion: @escaping (ChatingRoom?) -> Void) {
        ref.child("Rooms/\(id)").observe(.value) { snapshot in
            guard snapshot.exists() else { return }
            do{
                let data = try JSONSerialization.data(withJSONObject: snapshot.value!, options: .prettyPrinted)
                let result = try JSONDecoder().decode(ChatingRoom.self, from: data)
                completion(result)
            } catch {
                print("-> Error registerRoomObserver: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    func createRoom(message: [String: Any],participantUids: [String],participantNames: [String], name: String?, completion: @escaping (String) -> Void) {
        let autoId = ref.childByAutoId().key!
        var participants = [String: Any]()
        let msgAutoId = ref.childByAutoId().key!
        let roomInfo: [String: Any] = [
            "messages": [msgAutoId: message],
            //"participants": participants,
            "uids": participantUids.toFBString(),
            "userNames": participantNames.toFBString(),
            "name": name ?? "",
            "lastMessage": message["content"]!
        ]
        
        ref.child("Rooms/\(autoId)").setValue(roomInfo,withCompletionBlock:
                                                {_,_ in
            completion(autoId)
        })
        
        participantUids.forEach {
            participants[$0] = "false"
        }
        participants[ConnectedUser.shared.uid] = "true"
        
        ref.child("RoomUsers/\(autoId)").setValue(participants) { error, _ in
            if error != nil {
                print("error ->",error.debugDescription)
            }
        }
    }
    
    func registerAddedMessageObserver(roomId: String, completion: @escaping (Message?) -> Void){
        ref.child("Rooms/\(roomId)/messages").observe(.childAdded) { snapshot in
            if !snapshot.exists() {
                completion(nil)
                return
            }
            
            do{
                let data = try JSONSerialization.data(withJSONObject: snapshot.value!, options: .prettyPrinted)
                let result = try JSONDecoder().decode(Message.self, from: data)
                completion(result)
            } catch {
                print("-> Error registerRoomObserver: \(error.localizedDescription)")
                completion(nil)
                return
            }
        }
        
    }
    
}


