//
//  ExtendFunctionality.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 20.06.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import RevealingSplashView

/// Splash Animations of type SplashAnimationType with default value of nil
public func revealingSplashAnimation(_ view: UIView, type: SplashAnimationType? = nil, completion: SplashAnimatableCompletion? = nil) {
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "logo_1024_cornered")!,iconInitialSize: CGSize(width: 120, height: 120), backgroundColor: UIColor(red:255, green:255, blue:255, alpha:1.0))
    
    // SplashAnimationType, if nil "Twitter" first anmimation
    if type != nil {
        revealingSplashView.animationType = type!
    }
    
    // This is just a test...
    revealingSplashView.duration = 1.9
    
    //Adds the revealing splash view as a sub view
    view.addSubview(revealingSplashView)
    
    //Starts animation
    revealingSplashView.startAnimation(completion)
}

public func revealingSplashAnimation(_ view: UIView, type: SplashAnimationType? = nil, duration: Double, delay: Double, completion: SplashAnimatableCompletion? = nil) {
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "logo_1024_cornered")!,iconInitialSize: CGSize(width: 120, height: 120), backgroundColor: UIColor(red:255, green:255, blue:255, alpha:1.0))
    
    // SplashAnimationType, if nil "Twitter" first anmimation
    if type != nil {
        revealingSplashView.animationType = type!
    }
    
    // This is just a test...
    revealingSplashView.duration = duration
    revealingSplashView.delay = delay
    
    //Adds the revealing splash view as a sub view
    view.addSubview(revealingSplashView)
    
    //Starts animation
    revealingSplashView.startAnimation(completion)
}
