//
//  FrostyView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 15.12.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit

class FrostyView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func layoutSubviews() {
        setEffect()
    }
}

extension FrostyView {
    func setEffect(blurEffect: UIBlurEffectStyle = .extraLight) {
        for view in subviews {
            if view is UIVisualEffectView {
                view.removeFromSuperview()
            }
        }
        
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: blurEffect))
        frost.frame = bounds
        frost.autoresizingMask = .flexibleWidth
        
        self.layer.borderWidth = 0.4
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        insertSubview(frost, at: 0)
    }
}
