//
//  CustomTableView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 30.12.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit

class CustomTable: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.93).cgColor
        self.layer.shadowOpacity = 0.65
        self.layer.shadowRadius = 10.0
        self.layer.shadowOffset = CGSize(width: 1.1, height: 1.1)
        
        self.layer.cornerRadius = 22.0
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
}

class CustomTableView: UITableView {
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.93).cgColor
        self.layer.shadowOpacity = 0.65
        self.layer.shadowRadius = 10.0
        self.layer.shadowOffset = CGSize(width: 1.1, height: 1.1)
        
        self.layer.cornerRadius = 22.0
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
}
