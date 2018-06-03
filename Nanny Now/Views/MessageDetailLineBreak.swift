//
//  MessageDetailLineBreak.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 03.06.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class MessageDetailLineBreak: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView(date: Date) {
        self.dateLabel.text = dateTimeToString(date)
    }

}
