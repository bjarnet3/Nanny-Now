//
//  ExtendFunctionality.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 20.06.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import MapKit
import MapKitGoogleStyler
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

public func setMapView(for mapStyleForView: MapStyleForView, mapView: MKMapView) {
    mapView.removeOverlays(mapView.overlays)
    
    switch mapStyleForView {
    case .blueAndGrayMap:
        setMapBackgroundOverlay(mapName: .blueAndGrayMap, mapView: mapView)
    case .blackAndRegularMap:
        setMapBackgroundOverlay(mapName: .blackAndRegularMap, mapView: mapView)
    case .dayMap:
        setMapBackgroundOverlay(mapName: .dayMap, mapView: mapView)
    case .pinkBlackMap:
        setMapBackgroundOverlay(mapName: .pinkBlackMap, mapView: mapView)
    case .pinkStinkMap:
        setMapBackgroundOverlay(mapName: .pinkStinkMap, mapView: mapView)
    case .pinkWhiteMap:
        setMapBackgroundOverlay(mapName: .pinkWhiteMap, mapView: mapView)
    case .veryLightMap:
        setMapBackgroundOverlay(mapName: .veryLightMap, mapView: mapView)
    case .whiteAndBlackMap:
        setMapBackgroundOverlay(mapName: .whiteAndBlackMap, mapView: mapView)
    case .blackAndBlueGrayMap:
        setMapBackgroundOverlay(mapName: .blackAndBlueGrayMap, mapView: mapView)
    case .lightBlueGrayMap:
        setMapBackgroundOverlay(mapName: .lightBlueGrayMap, mapView: mapView)
    }
    print("Map Title  \(mapStyleForView.rawValue)")
}

public func setMapBackgroundOverlay(mapName: MapStyleForView, mapView: MKMapView) {
    // We first need to have the path of the overlay configuration JSON
    guard let overlayFileURLString = Bundle.main.path(forResource: mapName.rawValue, ofType: "json") else {
        return
    }
    let overlayFileURL = URL(fileURLWithPath: overlayFileURLString)
    
    // After that, you can create the tile overlay using MapKitGoogleStyler
    guard let tileOverlay = try? MapKitGoogleStyler.buildOverlay(with: overlayFileURL) else {
        return
    }
    
    // And finally add it to your MKMapView
    mapView.add(tileOverlay)
}

// Overlay / MapOverlay
// -------------------
public func setupOverLay(mapView: MKMapView) {
    addCirleMaskWithFrostOn(mapView)
}

public func addCirleMaskWithFrostOn(_ subView: UIView) {
    // Create the view
    let blurEffect = UIBlurEffect(style: .regular)
    let maskView = UIVisualEffectView(effect: blurEffect)
    
    maskView.frame = subView.bounds
    // maskView.frame.insetBy(dx: 1.10, dy: 1.10)
    
    // Set the radius to 1/3 of the screen width
    let radius : CGFloat = subView.bounds.width / 2.6 //  subView.bounds.width/2.6
    // Create a path with the rectangle in it.
    let path = UIBezierPath(rect: subView.bounds)
    // Put a circle path in the middle
    path.addArc(withCenter: subView.center, radius: radius, startAngle: 0.0, endAngle: CGFloat(2*CGFloat.pi), clockwise: true)
    
    // Create the shapeLayer
    let shapeLayer = CAShapeLayer()
    // set arc to shapeLayer
    shapeLayer.path = path.cgPath
    shapeLayer.fillRule = kCAFillRuleEvenOdd
    
    // Create the boarderLayer
    let boarderLayer = CAShapeLayer()
    boarderLayer.path = UIBezierPath(arcCenter: subView.center, radius: radius, startAngle: 0.0, endAngle: CGFloat(2*CGFloat.pi), clockwise: true).cgPath
    boarderLayer.lineWidth = 3.0
    boarderLayer.strokeColor = UIColor.white.cgColor
    boarderLayer.fillColor = nil
    
    // add shapeLayer to maskView
    maskView.layer.mask = shapeLayer
    
    // set properties
    maskView.clipsToBounds = false
    maskView.layer.borderColor = UIColor.gray.cgColor
    maskView.backgroundColor = nil
    // maskView.layer.masksToBounds = true
    maskView.layer.addSublayer(boarderLayer)
    // add mask to mapView
    addParallaxEffectOnView(maskView, 12)
    subView.addSubview(maskView)
}

