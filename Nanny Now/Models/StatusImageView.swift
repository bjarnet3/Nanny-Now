//
//  StatusView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 01.06.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class StatusImageView: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = ORANGE_SOLID.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
        
        image?.size.applying(CGAffineTransform.init(scaleX: 0.9, y: 0.9))
    }
    
}
