//
//  StatusView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 01.06.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class StatusView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = self.layer.frame.height / 2
        self.layer.borderColor = WHITE_SOLID.cgColor
        self.layer.borderWidth = 1.5
        
        self.layer.addShadow()
    }

}
