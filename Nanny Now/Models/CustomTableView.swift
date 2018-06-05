//
//  CustomTableView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 30.12.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit

class CustomTableView: UITableView {
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.93).cgColor
        self.layer.shadowOpacity = 0.93
        self.layer.shadowRadius = 26.5
        self.layer.shadowOffset = CGSize(width: 1.2, height: 1.2)
        
        self.layer.cornerRadius = 22.0
        self.layer.borderWidth = 0.29
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    
}
