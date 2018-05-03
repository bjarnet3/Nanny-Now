//
//  MenuImageView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 05.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class MenuImageView: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = WHITE_SOLID.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.height / 2
        
    }
}
