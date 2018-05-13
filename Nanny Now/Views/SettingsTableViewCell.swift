//
//  SettingsTableViewCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 25.11.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var settingsImage: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    func setupView(settings: Settings) {
        self.settingsImage.image = UIImage(named: settings.imageName)
        self.titleLbl.text = settings.title
        self.descriptionLbl.text = settings.info
    }
}
