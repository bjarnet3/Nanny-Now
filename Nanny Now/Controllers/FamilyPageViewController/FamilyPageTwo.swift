//
//  FamilyPageTwo.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 24.09.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class FamilyPageTwo: UIViewController {

    @IBOutlet weak var advertiseView: FrostyCornerView!
    @IBOutlet weak var progressView: UIProgressView!

    var advertiseViewHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preAnimation()
        self.setProgress(progress: 0, animated: false, alpha: 0.0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        performAnimation()
    }
}

extension FamilyPageTwo {
    
    // Beginning
    // Pre-Animation / Back to scratch
    private func preAnimation() {
        self.advertiseView.alpha = 0.0
        self.advertiseView.transform = CGAffineTransform(scaleX: 0.77, y: 0.77)
        
        self.advertiseViewHidden = true
        self.view.endEditing(true)
    }
    
    // Mid-Animation
    // Infix-Animation
    private func infixAnimation() {
        self.advertiseView.alpha = 0.5
        self.advertiseView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        
    }
    
    // End Animation
    // Post-Animation
    private func postAnimation() {
        self.advertiseView.alpha = 1.0
        self.advertiseView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        self.advertiseViewHidden = false
    }
    
    private func performAnimation() {
        setProgress(progress: 0.0, animated: false, alpha: 1.0)
        if advertiseViewHidden {
            hapticButton(.light)
            // SHOW REMOTE
            // -----------
            UIView.animate(withDuration: 0.58, delay: 0.00, usingSpringWithDamping: 0.50, initialSpringVelocity: 0.34, options: .curveEaseOut, animations: {
                
                
                
            })
            UIView.animate(withDuration: 0.89, delay: 0.034, usingSpringWithDamping: 0.50, initialSpringVelocity: 0.34, options: .curveEaseOut, animations: {
                self.postAnimation()
            })
            setProgress(progress: 1.0, animated: true, alpha: 0.0)
        } else {
            hapticButton(.light)
            // HIDE REMOTE
            // -----------
            UIView.animate(withDuration: 0.50, delay: 0.00, usingSpringWithDamping: 0.52, initialSpringVelocity: 0.36, options: .curveEaseOut, animations: {
                self.preAnimation()
            })
            UIView.animate(withDuration: 0.65, delay: 0.024, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.36, options: .curveEaseOut, animations: {
                
            })
            self.advertiseViewHidden = true
            setProgress(progress: 0.0, animated: true, alpha: 0.0)
        }
    }
    
    private func setProgress(progress: Float = 1.0, animated: Bool = true, alpha: CGFloat = 1.0) {
        if let progressView = self.progressView {
            if animated {
                progressView.setProgress(progress, animated: animated)
                UIView.animate(withDuration: 0.60, delay: 0.75, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    progressView.alpha = alpha
                    
                })
            } else {
                progressView.setProgress(progress, animated: animated)
                progressView.alpha = alpha
                
            }
        }
    }
}
