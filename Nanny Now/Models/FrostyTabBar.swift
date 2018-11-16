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
        // setTitleTextAttributes()
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
    
    // https://stackoverflow.com/questions/26069334/changing-tab-bar-font-in-swift
    func setTitleTextAttributes() {
        for item in items! {
            item.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Avenir-Book", size: 15.0)!], for: .normal)
            item.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Avenir-Book", size: 16.0)!], for: .selected)
        }
        /*
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Avenir-Book", size: 15.0)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Avenir-Book", size: 16.0)!], for: .selected)
        */
    }
}
