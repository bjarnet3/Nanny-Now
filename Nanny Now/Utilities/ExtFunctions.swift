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
