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
        let remoteConfig = RemoteConfig.remoteConfig()
        
        remoteConfig.setDefaults(fromPlist: "remoteConfigDefault")
        remoteConfig.fetch(withExpirationDuration: 3600) { (status,error) in // fetch하면 값을 서버에서 값을 가져오고 캐시한다. activate 하면 가장 최근에 가져온(캐시 된) 설정을 활성화(디폴트 config나 가져온 remoteconfig -> active config (로컬데이터로 변환하는 과정).
            // 지정한 시간동안은 서버에서 가져오는 것이 아닌 캐시된 값을꺼내는 것이므로 그동안은 변경된 값을 가져오지 못하는 것 같다.
            if status == .success{
                print("Config fetched!")
                remoteConfig.activate { (change, error) in //활성화 함수 함수를 호출하지 않으면 가져온 값이 적용이 되지 않는 거 같다.
                    print("Change : \(change)")
                }

            }else{
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            print(remoteConfig["app_color"].stringValue)
        }
       
    }
}

