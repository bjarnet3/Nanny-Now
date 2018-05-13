//
//  NannyViewController.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 10.09.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit
import MapKit
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
    @IBOutlet weak var orderMenu: UIView!
    @IBOutlet weak var orderMenuImage: MenuImageView!
    @IBOutlet weak var requestMenu: FrostyCornerView!
    @IBOutlet weak var locationMenu: FrostyCornerView!
    @IBOutlet weak var locationPicker: UIPickerView!
    
    // Request Outlets ------------------------
    @IBOutlet weak var requestImage: CustomImageView!
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var requestName: UILabel!
    @IBOutlet weak var requestRating: UILabel!
    @IBOutlet weak var requestAge: UILabel!
    @IBOutlet weak var requestGender: UILabel!
    @IBOutlet weak var requestDistance: UILabel!
    @IBOutlet weak var requestMessage: UITextField!
    @IBOutlet weak var requestType: UISegmentedControl!
    
    @IBOutlet weak var fromDateTime: UIDatePicker!
    @IBOutlet weak var toDateTime: UIDatePicker!
    
    @IBOutlet weak var effectView: UIVisualEffectView!
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    var user: User?
    var nannies = [Nanny]()
    var request: Request?
    
    // Property Observer
    var nannyBadge: Int = 0 {
        didSet {
            self.nannyTabBar.badgeValue = nannyBadge != 0 ? "\(nannyBadge)" : nil
        }
    }
    
    var nannyAdOn = [String:Bool]()
    var nanniesUID = [String]()
    
    var lastRowSelected: IndexPath?
    var exemptIDs = [String]()
    
    // Location
    var locationManager = CLLocationManager()
    var orderLocationLibrary = [String:CLLocation]()

    var activeLocations = [String]()
    var activeLocation = "current"

    var locationMenuShowing = false
    var orderMenuShowing = false
    var requestMenuShowing = true
    
    var animator: UIViewPropertyAnimator?
    
    // MARK: - IBAction: Methods connected to UI
    // ----------------------------------------
    @IBAction func nannyAdAction(_ sender: UISwitch) {
        self.nannyAd.alpha = 1
        getMapViewPoints()
        updateAd(turnOn: sender.isOn)
        self.exitAllMenu()
    }
    
    @IBAction func requestTypeAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            fromDateTime.alpha = 1.0
            toDateTime.alpha = 1.0
        } else {
            fromDateTime.alpha = 0.2
            toDateTime.alpha = 0.2
        }
    }
    
    @IBAction func requestOrder(_ sender: Any) {
        self.exitOrderMenu()
        if let lastRow = lastRowSelected?.row {
            let lastNanny = self.nannies[lastRow]
            
            self.requestImage.loadImageUsingCacheWith(urlString: lastNanny.imageName)
            self.requestName.text = lastNanny.firstName
            self.requestAge.text = "\(lastNanny.age) år"
            self.requestTitle.text = lastNanny.jobTitle
            self.requestGender.text = lastNanny.gender
            self.requestRating.text = lastNanny.ratingStar
            self.requestDistance.text = lastNanny.returnDistance
            
            self.fromDateTime.minimumDate = Date(timeIntervalSinceNow: 900.0)
            self.toDateTime.minimumDate = Date(timeIntervalSinceNow: 4800.0)
            
            self.enterRequestMenu()
        }
    }
    
    @IBAction func sendRequest(_ sender: UIButton) {
        if let lastRow = lastRowSelected?.row {
            let lastNanny = self.nannies[lastRow]
            
            var requestMessage = "Melding til: \(lastNanny.firstName)"
            if let text = self.requestMessage.text, text != "" { requestMessage = text }
            
            if self.requestType.selectedSegmentIndex == 0 {
                // Send Request
                let request = Request(nanny: lastNanny, user: self.user!, timeFrom: self.fromDateTime.date, timeTo: self.toDateTime.date, message: requestMessage)
                Notifications.instance.sendNotifications(with: request)
                
            } else {
                // Send Message
                let message = Message(from: self.user!, to: lastNanny, message: requestMessage)
                Notifications.instance.sendNotifications(with: message)
                
            }
        }
        
        self.exitAllMenu()
        for selectedAnnotation in self.mapView.selectedAnnotations {
            self.mapView.deselectAnnotation(selectedAnnotation, animated: true) }
        self.mapView.showAnnotations(self.nannies, animated: lowPowerModeDisabled)
    }
    
    @IBAction func cancelRequest(_ sender: Any) {
        self.exitAllMenu()
        for selectedAnnotation in self.mapView.selectedAnnotations {
            self.mapView.deselectAnnotation(selectedAnnotation, animated: true)
        }
        self.mapView.showAnnotations(self.nannies, animated: lowPowerModeDisabled)
        
    }
    
    @IBAction func locationMenuAction() {
        if !locationMenuShowing {
            enterLocationMenu()
        } else {
            exitLocationMenu()
        }
    }
    
    @IBAction func orderMenuAction() {
        if !orderMenuShowing {
            enterOrderMenu()
        } else {
            exitOrderMenu()
        }
    }
    
    @IBAction func goToUser(_ sender: Any) {
        goToDetail(row: (lastRowSelected?.row)!)
        exitAllMenu()
    }
    
    @IBAction func resignKeyboard(_ sender: Any) {
        dismissKeyboard()
    }
    
    // MARK: - Functions, Database & Animation
    // ----------------------------------------
    func getUserSettings() {
        if let user = LocalService.instance.getUser() {
            self.user = user
            self.user?.location = locationManager.location
            self.checkForBlocked(user.userUID)
        }
    }
    
    func checkForBlocked(_ userID: String) {
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
    
    func checkIfNannyAdActive(_ userID: String) {
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
    
    func updateAd(turnOn: Bool) {
        // Animate View
        if lowPowerModeDisabled {
            UIView.animate(withDuration: 2.0, delay: 0.450, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.nannyAd.alpha = 0
            })
        } else {
            self.nannyAd.alpha = 0
        }
        
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            if let location = currentLocation {
                DataService.instance.updateLocationAndPostcodeOnUser(from: location, userID: userID)
            } else {
                printDebug(object: "ERROR: updateLocationAndPostcodeOnUser in NannyViewController")
            }
            if turnOn {
                self.nannyAd.setTitle("Nanny Annonse er Aktiv", for: .normal)
                self.nannyAd.setTitleColor(UIColor.white, for: .normal)
                self.nannyAd.backgroundColor = hexStringToUIColor("#FF1744")
                self.locationManager.startUpdatingLocation()
                self.user?.location = locationManager.location!
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
                            let badge : [String : Any] = [
                                "badge" : 0
                            ]
                            DataService.instance.updateUserChildValues(uid: userID, userData: badge)
                            DataService.instance.updateNannyChildValues(uid: userID, userData: nannies)
                            let nanniesActive = DataService.instance.REF_NANNIES_ACTIVE
                            DataService.instance.copyTokenToREF(for: userID, reference: nanniesActive)
                            DataService.instance.copyLocationToREF(for: userID, fromLocation: self.activeLocation, reference: nanniesActive)
                            self.nannyAdOn.updateValue(true, forKey: userID)
                        }
                    }
                }
            } else {
                self.nannyAd.setTitle("Nanny Annonse er Slått Av", for: .normal)
                self.nannyAd.setTitleColor(UIColor.black, for: .normal)
                self.nannyAd.backgroundColor = UIColor.white
                self.locationManager.stopUpdatingLocation()
                self.user?.location = locationManager.location!
                
                self.nannyBadge = 0
                
                let nannyActive = DataService.instance.REF_NANNIES_ACTIVE
                DataService.instance.removeReferenceChildValues(uid: userID, reference: nannyActive)
                self.nannyAdOn.updateValue(false, forKey: userID)
            }
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // LocationManager
    func enableLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        // locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    var currentLocation: CLLocation? {
        var location: CLLocation?
        if let currentLocation = locationManager.location {
            location = currentLocation
        } else if let userLocation = user?.location {
            location = userLocation
        } else {
            location = CLLocation(latitude: 60.0436638, longitude: 5.5220319)
        }
        return location
    }
    
    func getLocationsFromUserInfo() {
        if let locations = userInfo["location"] as? [String: Any] {
            for (key, val) in locations {
                print(key, val)
                if key != "active" {
                    activeLocations.append(key)
                } else if key == "active" {
                    if let active = val as? String {
                        self.activeLocation = active
                    }
                }
            }
        }
    }
    
    // Observe Nannies .childRemoved & Remove from [nannies] at index - Reload TableView
    func observeChildRemoved(_ exemptIDs: [String]) {
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
    
    func observeChildAdded(_ exemptIDs: [String]) {
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
    func fetchNannyObserver(_ nannyID: String, long: Double, lat: Double) {
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

    func updateNannyArrayAndAnnotation( nanny: Nanny) {
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
    
    func removeNannyArrayAndAnnotation() {
        self.nannies.removeAll()
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
    }
    
    // Remove DatabaseObservers
    func removeDatabaseObservers() {
        DataService.instance.REF_NANNIES_ACTIVE.removeAllObservers()
    }

    // Location Menu
    func enterLocationMenu(animated: Bool = true) {
        let animated = animated && lowPowerModeDisabled ? true : false
        if !locationMenuShowing {
            self.nannyAdSwitch.setOn(false, animated: animated)
            self.updateAd(turnOn: false)
            if animated {
                UIView.animate(withDuration: 0.6, delay: 0.03, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.locationMenu.alpha = 1.0
                    self.locationMenu.frame = self.locationMenu.frame.offsetBy(dx: 0, dy: 175)
                    self.locationMenuShowing = true
                })
            } else {
                self.locationMenu.alpha = 1.0
                self.locationMenu.frame = self.locationMenu.frame.offsetBy(dx: 0, dy: 175)
                self.locationMenuShowing = true
            }
        } else {
            print("enterLocationMenu - locationMenuShowing or Error")
        }
    }
    
    func exitLocationMenu(animated: Bool = true) {
        let animated = animated && lowPowerModeDisabled ? true : false
        if locationMenuShowing {
            if animated {
                UIView.animate(withDuration: 0.6, delay: 0.03, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.locationMenu.alpha = 0.0
                    self.locationMenu.frame = self.locationMenu.frame.offsetBy(dx: 0, dy: -175)
                    self.locationMenuShowing = false
                })
            } else {
                self.locationMenu.alpha = 0.0
                self.locationMenu.frame = self.locationMenu.frame.offsetBy(dx: 0, dy: -175)
                self.locationMenuShowing = false
            }
        }
    }
    
    // Request Menu
    func enterOrderMenu(_ animated: Bool = true, delay: TimeInterval = 0.03) {
        let animated = animated && lowPowerModeDisabled ? true : false
        if !orderMenuShowing {
            if animated {
                UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.orderMenu.alpha = 1.0
                    self.orderMenu.frame = self.orderMenu.frame.offsetBy(dx: 0, dy: -80)
                    self.orderMenuShowing = true
                })
                
            } else {
                self.orderMenu.alpha = 1.0
                self.orderMenu.frame = self.orderMenu.frame.offsetBy(dx: 0, dy: -80)
                self.orderMenuShowing = true
            }
        } else {
            print("enterOrder - orderMenuShowing or Error")
        }
    }
    
    var exitOrderMenu: Bool = true {
        didSet {
            print("exitOrderMenu")
        }
    }
    
    func exitOrderMenu(animated: Bool = true) {
        let animated = animated && lowPowerModeDisabled ? true : false
        if orderMenuShowing {
            if animated {
                UIView.animate(withDuration: 0.6, delay: 0.03, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.orderMenu.alpha = 0.0
                    self.orderMenu.frame = self.orderMenu.frame.offsetBy(dx: 0, dy: 80)
                    self.orderMenuShowing = false
                })
            } else {
                self.orderMenu.alpha = 0.0
                self.orderMenu.frame = self.orderMenu.frame.offsetBy(dx: 0, dy: 80)
                self.orderMenuShowing = false
            }
        }
    }
    
    // Animate Request Menu
    func enterRequestMenu(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0.09, animated: Bool = true) {
        let animated = animated && lowPowerModeDisabled ? true : false
        if !requestMenuShowing {
            
            self.requestMenu.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            self.requestMenu.alpha = 0.0
            
            if animated {
                self.effectView.effect = nil
                
                animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                    self.effectView.effect = UIBlurEffect(style: .light)
                }
                
                UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.requestMenu.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.requestMenu.alpha = 1.0
                    
                    self.animator?.startAnimation()
                    self.effectView.isUserInteractionEnabled = true
                })
            } else {
                self.requestMenu.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.requestMenu.alpha = 1.0
            }
            self.requestMenuShowing = true
        }
    }
    
    func exitRequestMenu(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0.09, animated: Bool = true) {
        let animated = animated && lowPowerModeDisabled ? true : false
        if requestMenuShowing {
            self.requestMenu.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
            self.requestMenu.alpha = 1.0
            
            self.animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                self.effectView.effect = nil
            }
            
            if animated {
                UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.requestMenu.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                    self.requestMenu.alpha = 0.0
                    
                    self.animator?.startAnimation()
                    self.effectView.isUserInteractionEnabled = false
                    
                })
            } else {
                self.requestMenu.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                self.requestMenu.alpha = 0.0
            }
            self.requestMenuShowing = false
        }
    }
    
    func exitAllMenu() {
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
        
        self.exitRequestMenu(animated: false)
        self.exitLocationMenu(animated: false)
        
        self.getUserSettings()
        
        self.enableLocationServices()
        self.getLocationsFromUserInfo()
        
        // TableView and MapView Delegate and Datasource
        self.mapView.alpha = 0
        self.mapView.delegate = self
        
        self.tableView.alpha = 0
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController!.tabBar.frame.height, 0)
        
        self.locationPicker.delegate = self
        self.locationPicker.dataSource = self
        
        self.requestMenu.backgroundColor = UIColor.clear
        
        self.observeChildRemoved(self.exemptIDs)
        self.observeChildAdded(self.exemptIDs)

        revealingSplashAnimation(self.view , type: SplashAnimationType.swingAndZoomOut, duration: 1.9, delay: 2.9, completion: {
            self.viewDidLoadAnimation()
        })

        // Add Force 3D Touch Capability
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
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
            hapticButton(.light, lowPowerModeDisabled)
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
        exitOrderMenu()
        if let last = lastRowSelected, last == indexPath {
            goToDetail(row: last.row)
        } else {
            // Get image from selected cell
            if let cell = tableView.cellForRow(at: indexPath) as? NannyTableViewCell {
                if let image = cell.profilImage.image {
                    self.orderMenuImage.image = image
                }
            }
            
            hapticButton(.success, lowPowerModeDisabled)
            tableView.deselectRow(at: indexPath, animated: lowPowerModeDisabled)
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
            // Meny Animation
            // enterOrderMenu()
            
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
    
    // TODO: - get the points on the map
    func getMapViewPoints() {
        let mRect = self.mapView.visibleMapRect
        let neMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), mRect.origin.y)
        let swMapPoint = MKMapPointMake(mRect.origin.x, MKMapRectGetMaxY(mRect))
        let neCoord = MKCoordinateForMapPoint(neMapPoint)
        let swCoord = MKCoordinateForMapPoint(swMapPoint)
        
        if !lowPowerModeDisabled {
            print(neCoord.latitude)
            print(neCoord.longitude)
            print(swCoord.latitude)
            print(swCoord.longitude)
        }
    }
    
    // Center Map On Location Function : mapView.setRegion()
    func centerMapOnLocation(_ location: CLLocation, regionRadius: CLLocationDistance, animated: Bool) {
        let coordinateRadius = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.2, regionRadius * 2.2)
        mapView.setRegion(coordinateRadius, animated: animated)
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
        
        if lowPowerModeDisabled {
            self.view.fadeOut()
        }
        
        let alertController = UIAlertController(title: "\(self.nannies[row].firstName) ( \(self.nannies[row].gender) \(self.nannies[row].age) år )", message: "\(self.nannies[row].jobTitle) - \(self.nannies[row].policeAttest ? "Godkjent Vandel" : "Ikke levert Vandel")", preferredStyle: .actionSheet)
        
        let profileAction = UIAlertAction(title: "Mer informasjon", style: .default) { (_) in
            if lowPowerModeDisabled {
                self.view.fadeIn()
            }
        }
        
        /*
        let sendMapRequest = UIAlertAction(title: "Send Kart Forespørsel", style: .default) { (_) in
            if lowPowerModeDisabled {
                Notifications.instance.sendNotification(to: userIDatRow, text: "mapRequest", categoryRequest: .mapRequest)
                    // sendNotification(userIDatRow, dt.description, .nannyRequest, "")
                self.view.fadeIn()
            }
        }
        */
        
        let sendRequest = UIAlertAction(title: "Send Forespørsel", style: .default) { (_) in
            self.enterRequestMenu()
        }
        
        let cancelAction = UIAlertAction(title: "Avbryt", style: .destructive) { (_) in
            self.tableView.setEditing(false, animated: lowPowerModeDisabled)
            if lowPowerModeDisabled {
                self.view.fadeIn()
            }
            self.exitOrderMenu()
        }
        
        alertController.addAction(profileAction)
        alertController.addAction(sendRequest)
        // alertController.addAction(sendMapRequest)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: lowPowerModeDisabled) {
        }
    }
    
    func sendRequestAlert(row: Int) {
        if lowPowerModeDisabled {
            self.view.blur(blurRadius: 7.0)
        }
        
        let controller = UIAlertController(title: "Forespørsel til \(self.nannies[row].firstName)", message: "Skriv bare tidspunktet, og hvilken dag (Kl. 'fra - til' og 'i dag' / 'dato)", preferredStyle: .alert)
        
        let cancelButton = UIAlertAction(title: "Avbryt", style: .destructive) { (action) in
            self.exitOrderMenu()
            self.view.unBlur()
            hapticButton(.warning, lowPowerModeDisabled)
        }
        
        let sendButton = UIAlertAction(title: "Send", style: .default) { (action) in
            let text = controller.textFields?.first?.text
            
            let userIDatRow = self.nannies[row].userUID
            Notifications.instance.sendNotification(to: userIDatRow, text: text!, categoryRequest: .nannyRequest)
            // sendNotification(userIDatRow, text!, .nannyRequest, "")
            
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
        return activeLocations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // let compo = rollingPicker?.calendar.description ?? "component String"
        // let titleForRow = orderMenuShowing ? activeLocations[row] : compo
        return activeLocations[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.activeLocation = self.activeLocations[row]
     // self.activeLocation = orderMenuShowing ? activeLocations[row] : fromDateTime.accessibilityElement(at: row) as! String
        // self.mapView.setCenter(self.activeLocation[row], animated: true)
    }
}

