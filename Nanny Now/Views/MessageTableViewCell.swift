//
//  MessageAllCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 04.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData(for message: Message) {
        self.profileImage.loadImageUsingCacheWith(urlString:message._imageURL)
        self.messageLabel.text = message._message
    }

    
    
}
