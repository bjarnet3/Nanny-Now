//
//  NannyImageView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 14.09.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit

class UserImageView: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = ORANGE_SOLID.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.width / 2
    }
}

class NannyImageView: UserImageView {
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.borderWidth = 0.6
        self.layer.borderColor = PINK_NANNY_LOGO.cgColor
    }
    
}

/// Inspiration: https://stackoverflow.com/a/25475536/129202
class ViewWithRoundedcornersAndShadow: UIView {
    private var theShadowLayer: CAShapeLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.theShadowLayer == nil {
            let rounding = CGFloat.init(22.0)
            
            let shadowLayer = CAShapeLayer.init()
            self.theShadowLayer = shadowLayer
            shadowLayer.path = UIBezierPath.init(roundedRect: bounds, cornerRadius: rounding).cgPath
            shadowLayer.fillColor = UIColor.clear.cgColor
            
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowRadius = CGFloat.init(3.0)
            shadowLayer.shadowOpacity = Float.init(0.2)
            shadowLayer.shadowOffset = CGSize.init(width: 0.0, height: 4.0)
            
            self.layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}

