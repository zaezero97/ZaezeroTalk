//
//  ProfileCell.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/09.
//

import UIKit

class ProfileCell: UITableViewCell {

    @IBOutlet weak var stateMessageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
