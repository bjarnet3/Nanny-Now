//
//  MessageDetailVC.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 04.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MessageDetailVC: UIViewController {
    
    @IBOutlet weak var passThroughView: PassThroughView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        view.addSubview(passThroughView)
        
        transition(to: .standard)
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension MessageDetailVC {
    
    fileprivate func transition(to mapType: MKMapType) {
        switch mapType {
        case .standard:
            mapView.mapType = .standard
            passThroughView.theme = .light
        default:
            mapView.mapType = .hybrid
            passThroughView.theme = .dark
        }
    }
}

extension MessageDetailVC {
    
    @objc
    fileprivate func userWantsToSwitchMapType() {
        let mapType: MKMapType = (mapView.mapType == .standard) ? .hybrid : .standard
        transition(to: mapType)
    }
    
    @objc
    fileprivate func userWantsToToggleCapInsetLines() {
        passThroughView.showCapInsetLines = !passThroughView.showCapInsetLines
    }
    
    @objc
    fileprivate func userWantsToToggleShadow() {
        passThroughView.showShadow = !passThroughView.showShadow
    }
}

extension MessageDetailVC {
    
    @objc
    fileprivate func userDidPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        let _ = gestureRecognizer.translation(in: gestureRecognizer.view)
        
        switch gestureRecognizer.state {
        case .began:
            print("began")
        case .changed:
            print("changed")
            gestureRecognizer.setTranslation(CGPoint(), in: gestureRecognizer.view)
        case .ended, .cancelled:
            
            let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view).y
            if didUserFlickViewDown(basedOnVelocity: velocity) {
            } else if didUserFlickViewUp(basedOnVelocity: velocity) || didUserDragViewTooSmall() {
            }
            
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveLinear, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        default:
            break
        }
    }
    
    private func didUserFlickViewDown(basedOnVelocity velocity: CGFloat) -> Bool {
        return didUserFlickView(basedOnVelocity: velocity)
    }
    
    private func didUserFlickViewUp(basedOnVelocity velocity: CGFloat) -> Bool {
        return didUserFlickView(basedOnVelocity: abs(velocity))
    }
    
    private func didUserFlickView(basedOnVelocity velocity: CGFloat) -> Bool {
        return velocity > 973
    }
    
    private func didUserDragViewTooSmall() -> Bool {
        return passThroughView.bounds.height < 144 // arbitrary value for this demo.
    }
}

extension MessageDetailVC {
    
    fileprivate func lazyMapView() -> MKMapView {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.mapType = .standard
        view.showsTraffic = true
        view.showsBuildings = true
        view.showsPointsOfInterest = true
        
        return view
    }
    
    fileprivate func lazyPassThroughView() -> PassThroughView {
        let view = PassThroughView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addContent(to: view.contentView)
        
        return view
    }
}

extension MessageDetailVC {
    
    fileprivate func addContent(to contentView: UIView) {
        
        let stackView = makeStackView()
        contentView.addSubview(stackView)
        
        let bottomGripBar = makeGripBarView()
        contentView.addSubview(bottomGripBar)
        
    }
    
    private func makeStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            makeSwitchMapTypeButton(),
            makeToggleShadowButton(),
            makeToggleCapInsetsButton()
            ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 2
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        return stackView
    }
    
    private func makeSwitchMapTypeButton() -> UIButton {
        return makeButton(with: "Switch Map Type", selector: #selector(userWantsToSwitchMapType))
    }
    
    private func makeToggleCapInsetsButton() -> UIButton {
        return makeButton(with: "Toggle Cap Insets", selector: #selector(userWantsToToggleCapInsetLines))
    }
    
    private func makeToggleShadowButton() -> UIButton {
        return makeButton(with: "Toggle Shadow", selector: #selector(userWantsToToggleShadow))
    }
    
    private func makeButton(with title: String, selector: Selector) -> UIButton {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.setTitle(title, for: .normal)
        view.addTarget(self, action: selector, for: .primaryActionTriggered)
        
        return view
    }
    
    private func makeGripBarView() -> GripBarView {
        let view = GripBarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .lightGray
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(userDidPan(_:))))
        
        return view
    }
}
