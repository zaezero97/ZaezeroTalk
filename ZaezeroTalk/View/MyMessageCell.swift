//
//  MessageCell.swift
//  ZaezeroTalk
//
//  Created by 재영신 on 2021/11/15.
//

import UIKit

class MyMessageCell: UITableViewCell {

    @IBOutlet weak var readCountLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
