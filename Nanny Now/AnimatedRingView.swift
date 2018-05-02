//
//  AnimatedRingView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 14.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

/* https://stackoverflow.com/questions/47489943/animating-circular-progress-view-timer-in-swift */
class AnimatedRingView: UIView {
    private static let animationDuration = CFTimeInterval(2)
    private let π = CGFloat.pi
    private let startAngle = 1.5 * CGFloat.pi
    private let strokeWidth = CGFloat(8)
    var proportion = CGFloat(0.5) {
        didSet {
            setNeedsLayout()
        }
    }
    
    private lazy var circleLayer: CAShapeLayer = {
        let circleLayer = CAShapeLayer()
        circleLayer.strokeColor = UIColor.gray.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = self.strokeWidth
        self.layer.addSublayer(circleLayer)
        return circleLayer
    }()
    
    private lazy var ringlayer: CAShapeLayer = {
        let ringlayer = CAShapeLayer()
        ringlayer.fillColor = UIColor.clear.cgColor
        ringlayer.strokeColor = self.tintColor.cgColor
        ringlayer.lineCap = kCALineCapRound
        ringlayer.lineWidth = self.strokeWidth
        self.layer.addSublayer(ringlayer)
        return ringlayer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = (min(frame.size.width, frame.size.height) - strokeWidth - 2)/2
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: startAngle + 2 * π, clockwise: true)
        circleLayer.path = circlePath.cgPath
        ringlayer.path = circlePath.cgPath
        ringlayer.strokeEnd = proportion
    }
    
    func animateRing(From startProportion: CGFloat, To endProportion: CGFloat, Duration duration: CFTimeInterval = animationDuration) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = startProportion
        animation.toValue = endProportion
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        ringlayer.strokeEnd = endProportion
        ringlayer.strokeStart = startProportion
        ringlayer.add(animation, forKey: "animateRing")
    }
    // Instructions,, very easy and basic CircleView
    /*
     let animatedView = AnimatedRingView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
     
     animatedView.animateRing(From: 0, To: 1)
     
     or
     
     @IBAction func setAnimationOn(_ sender: Any) {
     animatedView.animateRing(From: 0, To: 1)
     }
     */
}
