//
//  NannyImageView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 14.09.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit

class NannyImageView: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.width / 2
    }
}

class UserImageView: NannyImageView {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.borderWidth = 0.5
        self.layer.borderColor = ORANGE_SOLID.cgColor
    }
}
