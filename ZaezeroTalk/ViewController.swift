//
//  ViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/05.
//

import UIKit
import SnapKit
import Firebase
import FirebaseRemoteConfig

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.setDefaults(fromPlist: "remoteConfigDefault")
        remoteConfig.fetch(withExpirationDuration: 3600) { (status,error) in
            if status == .success{
                print("Config fetched!")
                remoteConfig.activate { (change, error) in
                    print(change)
                    print(remoteConfig["app_color"].stringValue)
                }
            }else{
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            
        }
    }
}

