//
//  FrostyTabBar.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 15.12.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit

class FrostyTabBar: UITabBar {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setEffect()
    }
}

extension FrostyTabBar {
    func setEffect(blurEffect: UIBlurEffectStyle = .light) {
        for view in subviews {
            if view is UIVisualEffectView {
                print(view.description)
                view.removeFromSuperview()
            }
        }
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: blurEffect))
        frost.frame = bounds
        frost.autoresizingMask = .flexibleWidth
        
        insertSubview(frost, at: 0)
    }
}
