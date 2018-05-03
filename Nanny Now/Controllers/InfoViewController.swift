//
//  InfoViewController.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 14.09.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit
import RevealingSplashView

class InfoViewController: UIViewController {
    
    @IBOutlet weak var mainLbl: UILabel!
    @IBOutlet weak var subLbl: UILabel!
    
    @IBOutlet weak var logoTextImage: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var logoMaskImage: UIImageView!
    @IBOutlet weak var overlayView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        revealingSplashAnimation(self.view, type: SplashAnimationType.woobleAndZoomOut)
        
        addParallaxEffectOnView(logoImage, 10)
        addParallaxEffectOnView(logoTextImage, 14)
        addParallaxEffectOnView(logoMaskImage, 42)
        addParallaxEffectOnView(self.mainLbl, 14)
        addParallaxEffectOnView(self.subLbl, 10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        print(self.isViewLoaded)
        
        animateLabel(delay: 0.3, enter: true)
        animateView(delay: 0.2, enter: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        print("viewDidAppear")
        hapticButton(.heavy)
        // animateLabel(delay: 2.0, enter: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        animateLabel(delay: 0.1, enter: false)
        animateView(delay: 0.0, enter: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
    }
    
    @IBAction func goToStart(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}

// Animation Functions in InfoViewController
extension InfoViewController {
    
    func animateView(delay: Double, enter: Bool) {
        if enter {
            UIView.animate(withDuration: 0.45, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.logoTextImage.alpha = 1.0
                self.logoImage.alpha = 1.0
                self.logoMaskImage.alpha = 1.0
                self.overlayView.alpha = 0.0
            })
        } else {
            UIView.animate(withDuration: 0.45, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.logoTextImage.alpha = 0.0
                self.logoImage.alpha = 0.0
                self.logoMaskImage.alpha = 0.0
                self.overlayView.alpha = 0.85
            })
        }
    }
    
    func animateLabel(delay: Double, enter: Bool) {
        if enter {
            UIView.animate(withDuration: 0.45, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.mainLbl.alpha = 1
                self.mainLbl.frame = self.mainLbl.frame.offsetBy(dx: 0, dy: -30)
            })
            UIView.animate(withDuration: 0.45, delay: delay * 1.2, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.subLbl.alpha = 1
                self.subLbl.frame = self.subLbl.frame.offsetBy(dx: 0, dy: -30)
            })
        } else {
            UIView.animate(withDuration: 0.35, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.mainLbl.alpha = 0.0
                self.mainLbl.frame = self.mainLbl.frame.offsetBy(dx: 0, dy: 30)
                self.subLbl.alpha = 0.0
                self.subLbl.frame = self.subLbl.frame.offsetBy(dx: 0, dy: 30)
            })
        }
    }
    
}
