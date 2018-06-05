//
//  ShaddowImageView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 11.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import QuartzCore

extension UIImageView {
    
    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = PINK_NANNY_LOGO.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.layer.shadowRadius = 5
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

class ShadowImageView : UIImageView {
    var backLayer = CALayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.width / 2
        
        self.dropShadow()
    }
    
    func setLayer() {
        backLayer.shadowColor = PINK_NANNY_LOGO.cgColor
        backLayer.shadowRadius = 8
        backLayer.shadowOffset = CGSize(width: self.frame.width, height: self.frame.height)
        backLayer.shadowOpacity = 0.8
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
