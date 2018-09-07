//
//  NannyViewController.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 10.09.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit
import MapKit
import MapKitGoogleStyler
import Firebase
import SwiftKeychainWrapper
import UserNotifications
import RevealingSplashView

class NannyViewController: UIViewController, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    // MARK: - IBOutlet: Connection to Storyboard
    // ----------------------------------------
    @IBOutlet var nannyTabBar: UITabBarItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var nannyAd: CustomButton!
    @IBOutlet weak var nannyAdSwitch: UISwitch!
    
    @IBOutlet weak var profileButton: CustomButton!
    @IBOutlet weak var orderMenu: FrostyCornerView!
    @IBOutlet weak var orderMenuImage: UserImageView!

    @IBOutlet weak var locationMenu: FrostyCornerView!
    @IBOutlet weak var locationPicker: UIPickerView!

    // https://medium.com/@brianclouser/swift-3-creating-a-custom-view-from-a-xib-ecdfe5b3a960
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    private var user: User?
    private var nannies = [Nanny]()
    private var request: Request?
    
    private var animator: UIViewPropertyAnimator?
    // var visualView: UIVisualEffectView?
    // var requestMenu: NannyRequestMenu?
    
    // Property Observer
    private var nannyBadge: Int = 0 {
        didSet {
            self.nannyTabBar.badgeValue = nannyBadge != 0 ? "\(nannyBadge)" : nil
        }
    }
    
    private func setupOverLay() {
        addCirleMaskWithFrostOn(self.mapView)
    }
    
    private func addCirleMaskWithFrostOn(_ subView: UIView) {
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
    
    private var nannyAdOn = [String:Bool]()
    private var nanniesUID = [String]()
    
    private var lastRowSelected: IndexPath?
    private var exemptIDs = [String]()
    
    // -------------------------------------
    // -------------------------------------
    // LocationManager  /   LocationService
    // -------------------------------------
    private var locationManager = CLLocationManager()
    private var activeLocations = [String:CLLocation]()
    
    private var activeLocationNames = [String]()
    private var activeLocationName = "current"

    private var locationMenuShowing = true
    private var orderMenuShowing = true
    
    private var currentMapStyle:MapStyleForView = .veryLightMap
    private var backgroundMapViewIsRendered = false
    private var index = 0
    

    
    // MARK: - IBAction: Methods connected to UI
    // ----------------------------------------
    @IBAction func nannyAdAction(_ sender: UISwitch) {
        self.nannyAd.alpha = 1
        updateAd(turnOn: sender.isOn)
        self.exitAllMenu()
    }
    
    @IBAction func locationMenuAction() {
        if !locationMenuShowing {
            enterLocationMenu()
        } else {
            exitLocationMenu()
            setActiveLocation()
        }
    }
    
    @IBAction func orderMenuAction() {
        if !orderMenuShowing {
            enterOrderMenu()
        } else {
            exitOrderMenu()
            resetMapView()
        }
    }
    
    @IBAction func requestOrder(_ sender: Any) {
        self.exitOrderMenu()
        self.enterRequestMenu()
    }
    
    @IBAction func goToUser(_ sender: Any) {
        goToDetail(row: (lastRowSelected?.row)!)
        exitAllMenu()
    }
    
    func displayOnTitle(displayMessage: String) {
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.25, options: .curveEaseOut, animations: {
            self.nannyAd.alpha = 1.0
            self.nannyAd.setTitle(displayMessage, for: .normal)
            self.nannyAd.setTitleColor(UIColor.white, for: .normal)
            self.nannyAd.backgroundColor = hexStringToUIColor("#FF1744")
        }, completion: { (_) in
            UIView.animate(withDuration: 0.7, delay: 1.6, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.38, options: .curveEaseOut, animations: {
                self.nannyAd.alpha = 0.0
                self.nannyAd.backgroundColor = UIColor.white
            }, completion: { (_) in
                self.nannyAd.setTitle("", for: .normal)
                self.nannyAd.setTitleColor(UIColor.black, for: .normal)
            })
        })
    }
    
    private func getUserSettings() {
        if let user = LocalService.instance.getUser() {
            self.user = user
            self.user?.location = returnCurrentLocation
            self.checkForBlocked(user.userUID)
        }
    }
    
    private func checkForBlocked(_ userID: String) {
        DataService.instance.REF_USERS_PUBLIC.child(userID).child("blocked").observeSingleEvent(of: .value, with: { snapshot in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    self.exemptIDs.append(snap.key)
                    print(snap.key)
                }
            }
        })
        
        DataService.instance.REF_USERS_PRIVATE.child(userID).child("blocked").observeSingleEvent(of: .value, with: { snapshot in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    self.exemptIDs.append(snap.key)
                    print(snap.key)
                }
            }
        })
    }
    
    private func checkIfNannyAdActive(_ userID: String) {
        DataService.instance.REF_NANNIES_ACTIVE.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key == userID {
                        self.nannyAdOn.updateValue(true, forKey: userID)
                        if let nannyOn = self.nannyAdOn[userID] {
                            self.nannyAdSwitch.setOn(nannyOn, animated: true)
                        } else {
                            self.nannyAdSwitch.setOn(false, animated: true)
                        }
                    }
                }
            }
        })
    }
    
    private func updateAd(turnOn: Bool) {
        // Animate View
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            UIView.animate(withDuration: 2.0, delay: 0.450, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.nannyAd.alpha = 0
            })
            DataService.instance.updateLocationAndPostcodeOnUser(from: returnCurrentLocation, userID: userID)
            if turnOn {
                self.nannyAd.setTitle("Nanny Annonse er Aktiv", for: .normal)
                self.nannyAd.setTitleColor(UIColor.white, for: .normal)
                self.nannyAd.backgroundColor = hexStringToUIColor("#FF1744")
                
                self.locationManager.startUpdatingLocation()
                DataService.instance.addTokenToDatabase(for: userID)
                
                if let gender = userInfo["gender"] as? String {
                    if let birthday = userInfo["birthday"] as? String {
                        let ageString = calcAge(birthday: birthday)
                        if let age = Int(ageString) {
                            let ratings = userInfo["ratings"] as? [String:Int] ?? [ "" : 0 ]
                            let ratingAvrage = returnAvrageRatings(ratings)
                            let nannies : [String : Any] = [
                                "ratings" : ratingAvrage,
                                "age" : age,
                                "gender" : gender
                            ]
                            let badge : [String : Any] = [ "badge" : 0 ]
                            
                            DataService.instance.updateUserChildValues(uid: userID, userData: badge)
                            DataService.instance.updateNannyChildValues(uid: userID, userData: nannies)
                            
                            let nanniesActive = DataService.instance.REF_NANNIES_ACTIVE
                            DataService.instance.copyTokenToREF(for: userID, reference: nanniesActive)
                            DataService.instance.copyLocationToREF(for: userID, fromLocation: self.activeLocationName, reference: nanniesActive)
                            
                            self.nannyAdOn.updateValue(true, forKey: userID)
                        }
                    }
                }
            } else {
                self.nannyAd.setTitle("Nanny Annonse er Slått Av", for: .normal)
                self.nannyAd.setTitleColor(UIColor.black, for: .normal)
                self.nannyAd.backgroundColor = UIColor.white
                self.locationManager.stopUpdatingLocation()
                
                self.nannyBadge = 0
                
                // Remove Nanny Active from Database
                let nannyActive = DataService.instance.REF_NANNIES_ACTIVE
                DataService.instance.removeReferenceChildValues(uid: userID, reference: nannyActive)
                self.nannyAdOn.updateValue(false, forKey: userID)
            }
        }
    }
    
    // LocationManager
    private func enableLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        // locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private var returnCurrentLocation: CLLocation {
        var location: CLLocation
        if let currentLocation = locationManager.location {
            location = currentLocation
        } else if let userLocation = user?.location {
            location = userLocation
        } else {
            location = CLLocation(latitude: 60.0436638, longitude: 5.5220319)
        }
        return location
    }
    
    private var returnActiveLocation: CLLocation {
        return self.user?.activeLocation ?? returnCurrentLocation
    }
    
    private func setActiveLocation() {
        let active = self.activeLocationName
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            var location: (latitude: Double?, longitude: Double?)
            // var longitude: Double?
            DataService.instance.REF_USERS_PRIVATE.child(userID).child("location").child(active).observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                    
                    for (key, val) in snapshot {
                        if let longitude = val as? Double, key == "longitude" {
                            location.longitude = longitude
                        }
                        
                        if let latitude = val as? Double, key == "latitude" {
                            location.latitude = latitude
                        }
                    }
                    if location.latitude != nil && location.longitude != nil {
                        self.user?.activeLocation = CLLocation(latitude: location.latitude!, longitude: location.longitude!)
                    }
                }
            })
        }
    }
    
    private func getLocationsFromUserInfo() {
        if let locations = userInfo["location"] as? [String: Any] {
            for (key, value) in locations {
                if key != "active" {
                    let locationkey = key
                    self.activeLocationNames.append(locationkey)
                } else if key == "active" {
                    if let active = value as? String {
                        self.activeLocationName = active
                        self.setActiveLocation()
                    }
                }
            }
        }
    }
    
    private func resetMapView() {
        for selectedAnnotation in self.mapView.selectedAnnotations {
            self.mapView.deselectAnnotation(selectedAnnotation, animated: true)
        }
        self.mapView.showAnnotations(self.nannies, animated: lowPowerModeDisabled)
    }
    
    // Observe Nannies .childRemoved & Remove from [nannies] at index - Reload TableView
    private func observeChildRemoved(_ exemptIDs: [String]) {
        let zipMin = 5000
        let zipMax = 5200
        
        DataService.instance.REF_NANNIES_ACTIVE.queryOrdered(byChild: "zip").queryStarting(atValue: zipMin).queryEnding(atValue: zipMax).observe(.childRemoved, with: { (snapshot) in
            
            let nannyID = snapshot.key
            
            for (index, nanny) in self.nannies.enumerated() {
                if nanny.userUID == nannyID {
                    if !exemptIDs.contains(nannyID) {
                        if !self.mapView.selectedAnnotations.isEmpty {
                            for selectedAnnotation in self.mapView.selectedAnnotations {
                                self.self.mapView.deselectAnnotation(selectedAnnotation, animated: true)
                            }
                        }
                        
                        self.mapView.removeAnnotation(self.nannies[index])
                        self.nannies.remove(at: index)
                        
                        let indexPath = [IndexPath(item: index, section: 0)]
                        self.tableView.deleteRows(at: indexPath, with: .fade)
                        self.mapView.showAnnotations(self.nannies, animated: lowPowerModeDisabled)
                        
                        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
                            if userID == nannyID {
                                self.nannyAdOn.updateValue(false, forKey: userID)
                                if let nannyOn = self.nannyAdOn[nannyID] {
                                    self.nannyAdSwitch.setOn(nannyOn, animated: true)
                                } else {
                                    self.nannyAdSwitch.setOn(false, animated: true)
                                }
                            }
                        }
                    }
                }
            }
            for (i, n) in self.nanniesUID.enumerated() {
                if n == nannyID {
                    self.nanniesUID.remove(at: i)
                }
            }
        })
    }
    
    private func observeChildAdded(_ exemptIDs: [String]) {
        let zipMin = 5000
        let zipMax = 5200
        
        DataService.instance.REF_NANNIES_ACTIVE.queryOrdered(byChild: "zip").queryStarting(atValue: zipMin).queryEnding(atValue: zipMax).observe(.childAdded, with: { (snapshot) in
            let nannyID = snapshot.key
            if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                if !exemptIDs.contains(nannyID) {
                    if let longitude = snapValue["longitude"] as? Double {
                        if let latitude = snapValue["latitude"] as? Double {
                            for (index,_) in snapValue.enumerated() {
                                if index == 0 {
                                    self.fetchNannyObserver(nannyID, long: longitude, lat: latitude)
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    // ERROR: This will leave an error here
    private func fetchNannyObserver(_ nannyID: String, long: Double, lat: Double) {
        DataService.instance.REF_USERS_PRIVATE.child(nannyID).observeSingleEvent(of:.value, with: { snapshot in
            if let snapValue = snapshot.value as? Dictionary<String, AnyObject>  {
                if !self.exemptIDs.contains(nannyID) {
                    let userID = snapValue["userID"] as! String
                    if nannyID == userID {
                        if !self.nanniesUID.contains(userID) {
                            if let imageName = snapValue["imageUrl"] as? String {
                                let ratings = snapValue["ratings"] as? [String:Int]
                                let nanny = Nanny(
                                    userUID: (snapValue["userID"] as? String)!,
                                    userFID: nil,
                                    imageName: imageName,
                                    firstName: (snapValue["first_name"] as? String)!,
                                    birthDay: snapValue["birthday"] as? String,
                                    gender: snapValue["gender"] as? String,
                                    jobTitle: snapValue["yrke"] as? String,
                                    policeAttest: snapValue["vistPolitiatest"] as? Bool,
                                    location: CLLocation(latitude: lat, longitude: long),
                                    ratings: ratings
                                )
                                self.updateNannyArrayAndAnnotation(nanny: nanny)
                            }
                        }
                    }
                }
            }
        })
    }

    private func updateNannyArrayAndAnnotation( nanny: Nanny) {
        nanny.setAnnotation()
        nanny._distance = self.locationManager.location?.distance(from: nanny.location!)
        
        self.nannyBadge += 1
        self.nannies.append(nanny)
        self.nanniesUID.append(nanny.userUID)
        self.nannies.sort(by: { $0.returnIntDistance < $1.returnIntDistance })
        
        var nannyIndex = 0
        for (idx, nan) in self.nannies.enumerated() {
            if nan.userUID == nanny.userUID {
                nannyIndex = idx
            }
        }
        
        let indexPath = [IndexPath(item: nannyIndex, section: 0)]
        self.tableView.insertRows(at: indexPath, with: .automatic)
        
        if !mapView.selectedAnnotations.isEmpty {
            for selectedAnnotation in mapView.selectedAnnotations {
                mapView.deselectAnnotation(selectedAnnotation, animated: true)
            }
        }
        self.mapView.showAnnotations(self.nannies, animated: lowPowerModeDisabled)
    }
    
    private func removeNannyArrayAndAnnotation() {
        self.nannies.removeAll()
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
    }
    
    // Remove DatabaseObservers
    private func removeDatabaseObservers() {
        DataService.instance.REF_NANNIES_ACTIVE.removeAllObservers()
    }

    // Location Menu
    private func enterLocationMenu(animated: Bool = true) {
        let animated = animated && lowPowerModeDisabled ? true : false
        if !locationMenuShowing {
            self.nannyAdSwitch.setOn(false, animated: animated)
            self.updateAd(turnOn: false)
            if animated {
                UIView.animate(withDuration: 0.6, delay: 0.03, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.locationMenu.alpha = 1.0
                    self.locationMenu.transform = CGAffineTransform(translationX: 0, y: 20) // self.locationMenu.frame.offsetBy(dx: 0, dy: 175)
                    self.locationMenuShowing = true
                })
            } else {
                self.locationMenu.alpha = 1.0
                self.locationMenu.transform = CGAffineTransform(translationX: 0, y: 20)
                self.locationMenuShowing = true
            }
        } else {
            self.locationMenuShowing = true
        }
    }
    
    private func exitLocationMenu(animated: Bool = true) {
        let animated = animated && lowPowerModeDisabled ? true : false
        if locationMenuShowing {
            if animated {
                UIView.animate(withDuration: 0.6, delay: 0.03, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.locationMenu.alpha = 0.0
                    self.locationMenu.transform = CGAffineTransform(translationX: 0, y: -20)
                    self.locationMenuShowing = false
                })
            } else {
                self.locationMenu.alpha = 0.0
                self.locationMenu.transform = CGAffineTransform(translationX: 0, y: -20)
                self.locationMenuShowing = false
            }
        } else {
            self.locationMenuShowing = false
        }
    }
    
    // Request Menu
    private func enterOrderMenu(_ animated: Bool = true, delay: TimeInterval = 0.03) {
        
        let animated = animated && lowPowerModeDisabled ? true : false
        if !orderMenuShowing {
            if animated {
                UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.orderMenu.alpha = 1.0
                    self.orderMenu.transform = CGAffineTransform(translationX: 0, y: -20)
                    self.orderMenuShowing = true
                })
            } else {
                self.orderMenu.alpha = 1.0
                self.orderMenu.transform = CGAffineTransform(translationX: 0, y: -20)
                self.orderMenuShowing = true
            }
        } else {
            self.orderMenuShowing = true
        }
    }
    
    private func exitOrderMenu(animated: Bool = true) {
        let animated = animated && lowPowerModeDisabled ? true : false
        if orderMenuShowing {
            if animated {
                UIView.animate(withDuration: 0.6, delay: 0.03, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.orderMenu.alpha = 0.0
                    self.orderMenu.transform = CGAffineTransform(translationX: 0, y: 20)
                    self.orderMenuShowing = false
                }, completion: { (_) in
                    printFunc("completion:")
                })
            } else {
                self.orderMenu.alpha = 0.0
                self.orderMenu.transform = CGAffineTransform(translationX: 0, y: -20)
                self.orderMenuShowing = false
            }
        } else {
            self.orderMenuShowing = false
        }
    }
    
    // Display Request Menu "View"
    private func enterRequestMenu() {
        // Instantiate Visual Blur View
        let visualView = UIVisualEffectView(frame: UIScreen.main.bounds)
        self.view.addSubview(visualView)
        
        // Instantiate RequestMenu View
        let requestFrame = CGRect(x: 15, y: 30, width: UIScreen.main.bounds.width - 30, height: 520)
        let requestMenu = NannyRequestMenu(frame: requestFrame)
        
        // Set properties
        visualView.effect = nil
        requestMenu.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        requestMenu.alpha = 0.0
        requestMenu.backgroundColor = UIColor.clear

        // Instantiate UIPropertyAnimator
        animator = UIViewPropertyAnimator(duration: 0.38, curve: .easeOut) {
            visualView.effect = UIBlurEffect(style: .light)
        }
        
        // Add Visual and RequestView to subview
        self.view.addSubview(visualView)
        self.view.addSubview(requestMenu)
        
        // Start Animator Animation (visualView)
        animator?.startAnimation()
        visualView.isUserInteractionEnabled = true
        
        // Start Request Animation
        UIView.animate(withDuration: 0.42, delay: 0.05, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
            requestMenu.alpha = 1.0
            requestMenu.isUserInteractionEnabled = true
            requestMenu.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        
        // Init Data to requestMenu
        requestMenu.initData(user: self.user, remote: self.nannies[(lastRowSelected?.row)!], completion: {
            // Run exit process when done...
            self.exitAllMenu()
        })
    }
    
    private func exitRequestMenu() {
        var visualView: UIVisualEffectView?
        var requestMenu: NannyRequestMenu?
        
        for view in self.view.subviews {
            if view is UIVisualEffectView {
                print("VisualEffectView is found")
                visualView = (view as? UIVisualEffectView)!
            }
            if view is NannyRequestMenu {
                if let requestMenuView = view as? NannyRequestMenu {
                    requestMenu = requestMenuView
                    print("requestMenu found")
                    
                    if let visualView = visualView {
                        self.animator = UIViewPropertyAnimator(duration: 0.38, curve: .easeOut) {
                            visualView.effect = nil
                        }
                        self.animator?.startAnimation()
                        visualView.isUserInteractionEnabled = false
                        
                        UIView.animate(withDuration: 0.35, delay: 0.00, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                            
                            requestMenu?.alpha = 0.0
                            requestMenu?.isUserInteractionEnabled = false
                            requestMenu?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                        })
                        requestMenu = nil
                    }
                    
                }
            }
        }
        
        self.resetMapView()
    }
    
    private func exitAllMenu() {
        exitLocationMenu()
        exitOrderMenu()
        exitRequestMenu()
    }
}

// MARK: - ViewDidLoad, ViewWillLoad etc...
// ----------------------------------------
extension NannyViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Animation / Hide
        self.exitAllMenu()
        
        // Settings & Setup
        self.enableLocationServices()
        self.getLocationsFromUserInfo()
        self.getUserSettings()
        
        // TableView and MapView Delegate and Datasource
        self.mapView.alpha = 0
        self.mapView.delegate = self
        
        setMapBackgroundOverlay(mapName: .veryLightMap, mapView: self.mapView)
        
        self.tableView.alpha = 0
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController!.tabBar.frame.height, 0)
        
        // PickerView Delegate and Datasource
        self.locationPicker.delegate = self
        self.locationPicker.dataSource = self
        
        // Observer Methods
        self.observeChildRemoved(self.exemptIDs)
        self.observeChildAdded(self.exemptIDs)

        // Animation
        revealingSplashAnimation(self.view , type: SplashAnimationType.swingAndZoomOut, duration: 1.9, delay: 2.9, completion: {
            self.viewDidLoadAnimation()
        })

        // Add Force 3D Touch Capability
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        
        setupOverLay()
        setupParallex()
        
    }
    
    func setupParallex() {
        addParallaxEffectOnView(self.mapView, -6)
        addParallaxEffectOnView(self.tableView, 14)
    }
    
    func remoteParallex() {
        removeParallaxEffectOnView(self.mapView)
        removeParallaxEffectOnView(self.tableView)
    }
    
    func viewDidLoadAnimation() {
        self.centerMapOnLocation(calculateCenterPositionFromArrayOfLocations(self.nannies), regionRadius: AltitudeDistance.large, animated: false)
        self.mapView.showAnnotations(self.nannies, animated: lowPowerModeDisabled)
        animateTable(self.tableView, delay: 0.21, animated: lowPowerModeDisabled, mapView: self.mapView)
        hapticButton(.light, lowPowerModeDisabled)
    }
    
    // Is called later then View Did load (One time)
    override func viewDidLayoutSubviews() {
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            checkIfNannyAdActive(userID)
        }
        self.nannyBadge = 0
    }
    
    // MARK: View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        let tab = self.tabBarController?.tabBar as! FrostyTabBar
        tab.setEffect(blurEffect: .light)
        
        hapticButton(.light, lowPowerModeDisabled)
        
        if !mapView.selectedAnnotations.isEmpty {
            for selectedAnnotation in mapView.selectedAnnotations {
                mapView.deselectAnnotation(selectedAnnotation, animated: false)
            }
        }
        if nannies.count != 0 {
            self.centerMapOnLocation(calculateCenterPositionFromArrayOfLocations(nannies), regionRadius: AltitudeDistance.XXLarge, animated: false)
        }
    }
    
    // MARK: View Did Something
    override func viewDidAppear(_ animated: Bool) {
        if nannies.count != 0 {
            self.mapView.showAnnotations(self.nannies, animated: lowPowerModeDisabled)
            animateTable(self.tableView, delay: 0.15, animated: lowPowerModeDisabled, mapView: self.mapView)
        }
        self.nannyBadge = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // removeDatabaseObservers()
        self.tableView.alpha = 0
        self.mapView.alpha = 0
        self.exitAllMenu()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.centerMapOnLocation(calculateCenterPositionFromArrayOfLocations(nannies), regionRadius: AltitudeDistance.XLarge, animated: false)
        self.nannyBadge = 0
    }
    
    // MARK: Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - TableView, Delegate & Datasource
// ----------------------------------------
extension NannyViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NannyCell", for: indexPath) as? NannyTableViewCell {
            cell.setupView(nanny: nannies[indexPath.row])
            return cell
        } else {
            return NannyTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nannies.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.centerMapOnLocation(self.nannies[indexPath.row].location!, regionRadius: AltitudeDistance.normal, animated: lowPowerModeDisabled)
        self.mapView.selectAnnotation(self.nannies[indexPath.row], animated: lowPowerModeDisabled)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        print("didEndEditingRowAt")
        self.mapView.deselectAnnotation(self.nannies[(indexPath?.row)!], animated: lowPowerModeDisabled)
        centerMapOnLocation(calculateCenterPositionFromArrayOfLocations(nannies), regionRadius: AltitudeDistance.XLarge, animated: lowPowerModeDisabled)
        self.exitOrderMenu()
    }
    
    // Swipe to delete implemented :-P,, other tableView cell button implemented :-D howdy!
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        self.centerMapOnLocation(self.nannies[indexPath.row].location!, regionRadius: AltitudeDistance.tiny, animated: lowPowerModeDisabled)
        // Haptic Light
        hapticButton(.light, lowPowerModeDisabled)
        
        self.lastRowSelected = indexPath
        
        let delete = UITableViewRowAction(style: .destructive, title: " ⊗ ") { (action , indexPath ) -> Void in
            // if true, crash (because didEndEditingRow is called)
            tableView.isEditing = false
            // Remove annotation from mapview (only the added properties "in for loop",, weird)
            self.mapView.deselectAnnotation(self.nannies[indexPath.row], animated: lowPowerModeDisabled)
            self.mapView.removeAnnotation(self.nannies[indexPath.row])
            self.centerMapOnLocation(calculateCenterPositionFromArrayOfLocations(self.nannies), regionRadius: AltitudeDistance.XLarge, animated: lowPowerModeDisabled)
            // Remove from Array
            self.nannies.remove(at: indexPath.row)
            // self.annot.remove(at: indexPath.row)
            // Remove from tableView (with animation)
            tableView.deleteRows(at: [indexPath], with: .fade)
            // Update badgeValue
            self.nannyTabBar.badgeValue = "\(self.nannies.count)"
        }
        
        let request = UITableViewRowAction(style: .destructive, title: " ☑︎ ") { (action , indexPath) -> Void in
            self.enterRequestMenu()
            // self.enterRequestMenu()
            // self.sendRequestAlert(row: indexPath.row)
        }
        
        let more = UITableViewRowAction(style: .default, title: " ⋮ ") { (action, indexPath) -> Void in
            // Show on map
            self.standardAlert(row: indexPath.row)
        }
        
        delete.backgroundColor = SILVER
        request.backgroundColor = LIGHT_GREY
        more.backgroundColor = PINK_NANNY_LOGO
        
        return [delete, request, more]
    }
    
    func goToDetail(row: Int) {
        if let nannyDetail = self.storyboard?.instantiateViewController(withIdentifier: "NannyDetailVC") as? NannyDetailVC {
            if let cell = tableView.cellForRow(at: lastRowSelected!) as? NannyTableViewCell {
                if let image = cell.profilImage.image {
                    nannyDetail.initData(forImage: image, nanny: self.nannies[(lastRowSelected?.row)!], user: self.user!, myLocation: locationManager.location!)
                    self.present(nannyDetail, animated: true)
                }
            }
        }
    }
    
    func singelTapToEnterOrderMenu(_ tableView: UITableView, indexPath: IndexPath)  {
        self.exitOrderMenu()
        self.exitLocationMenu()
        hapticButton(.selection, lowPowerModeDisabled)
        tableView.deselectRow(at: indexPath, animated: lowPowerModeDisabled)
        if let last = lastRowSelected, last == indexPath {
            self.enterRequestMenu()
            // goToDetail(row: last.row)
        } else {
            // Get image from selected cell
            if let cell = tableView.cellForRow(at: indexPath) as? NannyTableViewCell {
                if let image = cell.profilImage.image {
                    self.orderMenuImage.image = image
                }
            }
            self.centerMapOnLocation(self.nannies[indexPath.row].location!, regionRadius: AltitudeDistance.medium, animated: lowPowerModeDisabled)
            self.mapView.selectAnnotation(self.nannies[indexPath.row], animated: lowPowerModeDisabled)
            
            // Meny Animation
            enterOrderMenu(delay: 1.0)
            lastRowSelected = indexPath
        }
    }
    
    func doubleTapToEnterOrderMenu(_ tableView: UITableView, indexPath: IndexPath) {
        exitAllMenu()
        if let last = lastRowSelected, last == indexPath {
            // Get image from selected cell
            if let cell = tableView.cellForRow(at: indexPath) as? NannyTableViewCell {
                if let image = cell.profilImage.image {
                    self.orderMenuImage.image = image
                }
            }
            
            hapticButton(.success, lowPowerModeDisabled)
            tableView.deselectRow(at: indexPath, animated: lowPowerModeDisabled)
            self.mapView.selectAnnotation(self.nannies[indexPath.row], animated: lowPowerModeDisabled)
            
            enterOrderMenu(delay: 1.0)
        } else {
            lastRowSelected = indexPath
            hapticButton(.selection, lowPowerModeDisabled)
            tableView.deselectRow(at: indexPath, animated: lowPowerModeDisabled)
            self.centerMapOnLocation(self.nannies[indexPath.row].location!, regionRadius: AltitudeDistance.medium, animated: lowPowerModeDisabled)
            self.mapView.selectAnnotation(self.nannies[indexPath.row], animated: lowPowerModeDisabled)
            exitAllMenu()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        singelTapToEnterOrderMenu(tableView, indexPath: indexPath)
        // doubleTapToEnterOrderMenu(tableView, indexPath: indexPath)
    }
}
// MARK: - Peak and Pop Preview Delegate
// -------------------------------------
extension NannyViewController : UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        self.user?.location = locationManager.location!
        
        guard let indexPath = tableView?.indexPathForRow(at: location), let cell = tableView?.cellForRow(at: indexPath) as? NannyTableViewCell else { return nil }
        
        guard let nannyDetailVC = storyboard?.instantiateViewController(withIdentifier: "NannyDetailVC") as? NannyDetailVC else {
            return nil
        }
        
        nannyDetailVC.initData(forImage: cell.profilImage.image!, nanny: self.nannies[indexPath.row], user: self.user!, myLocation: locationManager.location!)

        previewingContext.sourceRect = cell.frame
        return nannyDetailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

// MARK: - MKMapView & Delegate
// ----------------------------
extension NannyViewController : MKMapViewDelegate {
    
    // Center Map On Location Function : mapView.setRegion()
    func centerMapOnLocation(_ location: CLLocation, regionRadius: CLLocationDistance, animated: Bool) {
        let coordinateRadius = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.2, regionRadius * 2.2)
        mapView.setRegion(coordinateRadius, animated: animated)
    }
    
    // https://github.com/fmo91/MapKitGoogleStyler
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // This is the final step. This code can be copied and pasted into your project
        // without thinking on it so much. It simply instantiates a MKTileOverlayRenderer
        // for displaying the tile overlay.
        if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    // MapView & Annotation (functions)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is User) { return nil }
        
        let userAnnotation = annotation as! User
        let reuseId = userAnnotation.userUID
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if anView == nil {
            // Public createAnnotation Function
            // --------------------------------
            anView = createAnnotation(annotation: userAnnotation)
        } else {
            anView!.annotation = annotation
        }
        
        anView?.centerOffset = CGPoint(x: -12.1, y: -40.4)
        return anView
    }
}

// MARK: - UIAlertController (Add Alert Actions)
// ---------------------------------------------
extension NannyViewController {
    
    func standardAlert(row: Int) {
        // Show on map
        self.centerMapOnLocation(self.nannies[row].location!, regionRadius: AltitudeDistance.XSmall, animated: lowPowerModeDisabled)
        
        let user = self.user ?? LocalService.instance.user!
        let remoteUser = self.nannies[row]
        
        var message = Message(from: user, to: remoteUser, message: "Standard Message", messageID: nil)
        var request = Request(nanny: remoteUser, user: user, timeFrom: Date(timeIntervalSinceNow: 3600.0), timeTo: Date(timeIntervalSinceNow: 7200.0), message: "Nanny Map Request")
        
        let alertController = UIAlertController(title: "\(remoteUser.firstName) ( \(remoteUser.gender) \(remoteUser.age) år )", message: "\(remoteUser.jobTitle) - \(remoteUser.policeAttest ? "Godkjent Vandel" : "Ikke levert Vandel")", preferredStyle: .actionSheet)
        
        let profileAction = UIAlertAction(title: "Mer informasjon", style: .default) { (_) in
            print("Mer informasjon --- ")
        }
        
        let sendRequest = UIAlertAction(title: "Send Forespørsel", style: .default) { (_) in
            
            // let row = self.lastRowSelected?.row ?? row
            for view in self.view.subviews {
                if view is NannyRequestMenu {
                    if let requestMenu = view as? NannyRequestMenu {
                        requestMenu.initData(user: user, remote: remoteUser)
                        requestMenu.sendRequest()
                    }
                }
            }
            // LAST / ONLY requestMenu vas Outlet
            // self.requestMenu?.initData(user: self.user, nanny: self.nannies[row])
            // self.requestMenu?.sendRequest()
            
            // REALLY OLD / WHEN MENUS WAS OUTLETS
            // self.requestMenuOrder.initData(user: self.user, nanny: self.nannies[(self.lastRowSelected?.row)!])
            // self.requestMenuOrder.sendRequest()
        }
        
        let sendMapRequest = UIAlertAction(title: "Send Map Forespørsel", style: .default) { (_) in
            // let row = self.lastRowSelected?.row ?? row
            // var request = Request(nanny: self.nannies[row], user: self.user!, timeFrom: Date(timeIntervalSinceNow: 3600), timeTo: Date(timeIntervalSinceNow: 7200 ), message: "Barnevakt forespørsel")
            
            request.requestCategory = NotificationCategory.nannyMapRequest.rawValue
            Notifications.instance.sendNotification(with: request)
        }
        
        let sendMessage = UIAlertAction(title: "Send Message", style: .default) { (_) in
            if lowPowerModeDisabled {
                
                message.setCategory(category: .messageConfirm)
                message.setMessage(message: "This is a simple message")
                Notifications.instance.sendNotification(with: message)
                
            }
        }
        
        let sendMessageRequest = UIAlertAction(title: "Send Message Request", style: .default) { (_) in
            if lowPowerModeDisabled {
                
                message.setCategory(category: .messageRequest)
                message.setMessage(message: "This is a message with response")
                Notifications.instance.sendNotification(with: message)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Avbryt", style: .destructive) { (_) in
            self.tableView.setEditing(false, animated: lowPowerModeDisabled)
            self.exitOrderMenu()
            
        }
        
        alertController.addAction(profileAction)
        alertController.addAction(sendRequest)
        alertController.addAction(sendMapRequest)
        
        alertController.addAction(sendMessage)
        alertController.addAction(sendMessageRequest)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: lowPowerModeDisabled) {
        }
    }
    
    func sendRequestAlert(row: Int) {
        if lowPowerModeDisabled {
            self.view.blur(blurRadius: 7.0)
        }
        
        let user = self.user ?? LocalService.instance.user!
        let remoteUser = self.nannies[row]
        
        var request = Request(nanny: remoteUser, user: user, timeFrom: Date(timeIntervalSinceNow: 3600.0), timeTo: Date(timeIntervalSinceNow: 7200.0), message: "Nanny Request")
        
        let controller = UIAlertController(title: "Forespørsel til \(self.nannies[row].firstName)", message: "Skriv bare tidspunktet, og hvilken dag (Kl. 'fra - til' og 'i dag' / 'dato)", preferredStyle: .alert)
        
        let cancelButton = UIAlertAction(title: "Avbryt", style: .destructive) { (action) in
            self.exitOrderMenu()
            self.view.unBlur()
            hapticButton(.warning, lowPowerModeDisabled)
        }
        
        let sendButton = UIAlertAction(title: "Send", style: .default) { (action) in
            request.message = controller.textFields?.first?.text ?? "Nanny Request"
            request.requestCategory = NotificationCategory.nannyRequest.rawValue
            Notifications.instance.sendNotification(with: request)
            
            self.exitOrderMenu()
            self.view.unBlur()
            hapticButton(.success, lowPowerModeDisabled)
        }
        
        controller.addTextField { (textField) in
            textField.placeholder = "  f.eks: 20:00 til 01:00 i kveld  "
            textField.keyboardType = .numbersAndPunctuation
        }

        controller.addAction(cancelButton)
        controller.addAction(sendButton)
        
        self.present(controller, animated: lowPowerModeDisabled, completion: { () in
            controller.view.superview?.isUserInteractionEnabled = true
            controller.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc func alertControllerBackgroundTapped()
    {
        self.view.unBlur()
        hapticButton(.success, lowPowerModeDisabled)
        let allSelectedAnnotations = self.mapView.selectedAnnotations
        for selectedAnnotation in allSelectedAnnotations {
            self.mapView.deselectAnnotation(selectedAnnotation, animated: true)
        }
        self.mapView.showAnnotations(self.nannies, animated: lowPowerModeDisabled)
        self.exitAllMenu()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIPickerViewDelegate & Datasource
// ---------------------------------------------
extension NannyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // let compo = rollingPicker?.calendar.component(.minute, from: rollingDateNow!) ?? 1
        // let numberOfCompo = orderMenuShowing ? 1 : 3
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // let numberOfRows = orderMenuShowing ? activeLocations.count : comp
        return activeLocationNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // let compo = rollingPicker?.calendar.description ?? "component String"
        // let titleForRow = orderMenuShowing ? activeLocations[row] : compo
        return activeLocationNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let active = self.activeLocationNames[row]
        self.activeLocationName = active
        
     // self.activeLocation = orderMenuShowing ? activeLocations[row] : fromDateTime.accessibilityElement(at: row) as! String
        // self.mapView.setCenter(self.activeLocation[row], animated: true)
    }
}

