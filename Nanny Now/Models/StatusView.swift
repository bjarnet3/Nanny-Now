//
//  StatusView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 01.06.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class StatusView: UIView {
    var imageView = UIImageView(frame: .zero)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = self.layer.frame.height / 2
        self.layer.borderColor = PINK_TABBAR_SELECTED.cgColor
        self.layer.borderWidth = 1.2
        
        self.layer.addShadow()
    }
    
    func setImage(image: UIImage) {
        self.imageView = UIImageView(frame: bounds)
        self.imageView.image = image
        self.imageView.layer.cornerRadius = self.imageView.frame.height / 2
        self.imageView.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderWidth = 1.0
        self.imageView.layer.borderColor = UIColor.gray.cgColor
        
        self.addSubview(self.imageView)
        setNeedsDisplay()
    }

}
