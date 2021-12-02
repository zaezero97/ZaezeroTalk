//
//  PhotoDetailViewController.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/12/02.
//

import UIKit
import PhotosUI
import NVActivityIndicatorView
import SnapKit

class PhotoDetailViewController: UIViewController {
    
    lazy var indicator : NVActivityIndicatorView = {
        let frame = CGRect(x:0, y:0, width: 100, height: 100)
        let indicatiorView = NVActivityIndicatorView(frame: frame, type: .ballClipRotatePulse, color: .purple, padding: 0)
        view.addSubview(indicatiorView)
        indicatiorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return indicatiorView
    }()
    
    @IBOutlet weak var photoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func clickDownloadButton(_ sender: Any) {
        saveImage()
    }
    @IBAction func clickCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


extension PhotoDetailViewController {
    func saveImage() {
        indicator.startAnimating()
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                guard status == .authorized, let image = self.photoImageView.image else { return }
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }, completionHandler: {_,_ in
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                    }
                })
            }
        }
        
    }
}
