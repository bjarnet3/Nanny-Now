//
//  CornerView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 04.06.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class CustomView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.roundCorners(radius: 17.5)
        self.layer.addShadow()
    }
}

class CustomViewShaddow: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.roundCorners(radius: 22.5)
        self.layer.addShadow()
    }
}
