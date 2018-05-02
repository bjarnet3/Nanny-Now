//
//  HeaderTableViewCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 19.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateTitle(_ title: String) {
        self.headerTitle.text = title
    }
    
}
