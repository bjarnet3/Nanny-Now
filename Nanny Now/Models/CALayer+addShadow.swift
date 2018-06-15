//
//  Layer.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 05.06.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

extension CALayer {
    private func addShadowWithRoundedCorners() {
        if let contents = self.contents {
            masksToBounds = false
            
            sublayers?.filter{ $0.frame.equalTo(self.bounds) }
                .forEach{ $0.roundCorners(radius: self.cornerRadius) }
            
            self.contents = nil
            
            if let sublayer = sublayers?.first,
                sublayer.name == "Constants.contentLayerName" {
                sublayer.removeFromSuperlayer()
            }
            
            let contentLayer = CALayer()
            contentLayer.name = "Constants.contentLayerName"
            contentLayer.contents = contents
            contentLayer.frame = bounds
            contentLayer.cornerRadius = cornerRadius
            contentLayer.masksToBounds = true
            insertSublayer(contentLayer, at: 0)
        }
    }
    
    func addShadow(offset: CGSize? = nil, opacity: Float = 0.25, radius: CGFloat = 3, color: UIColor = .black) {
        self.shadowOffset = offset ?? CGSize(width: 1, height: 1)
        self.shadowOpacity = opacity
        self.shadowRadius = radius
        self.shadowColor = color.cgColor
        self.masksToBounds = false
        if cornerRadius != 0 {
            addShadowWithRoundedCorners()
        }
    }
    
    func roundCorners(radius: CGFloat) {
        self.cornerRadius = radius
        if shadowOpacity != 0 {
            addShadowWithRoundedCorners()
        }
    }
}
