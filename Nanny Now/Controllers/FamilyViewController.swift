//
//  FamilyViewController.swift
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

class FamilyViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - IBOutlet: Connection to View "storyboard"
    // ----------------------------------------
    @IBOutlet weak var familyTabBar: UITabBarItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var paymentMenu: UIView!
    
    // MARK: - Array, Constants & Varables
    // -------------------------------------
    var familiez = [Families]()
    var families = [Family]()
    
    var user: User?
    var nanny: User?
    
    let exemptIDs = ["sflkjsdf"]
    var myUserID = ""
    
    var familyAdOn = [String:Bool]()
    var familiesUID = [String]()
    
    var firstLoad: Bool = true
    var alertController:UIAlertController = UIAlertController()
    
    // Property Observer
    // -----------------
    var familyBadge: Int = 0 {
        didSet {
            self.familyTabBar.badgeValue = self.familyBadge != 0 ? "\(self.familyBadge)" : nil
        }
    }
    
    // Location Manager & Current Location
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation? {
        var location: CLLocation?
        if let currentLocation = locationManager.location {
            location = currentLocation
        } else if let userLocation = user?.location {
            location = userLocation
        } else {
            location = nil
        }
        return location
    }
    
    var cellHeights: [CGFloat] = []
    struct CellHeight {
            static let close: CGFloat = 120 // equal or greater foregroundView height
            static let open: CGFloat = 220 // equal or greater containerView height
    }
    
    // MARK: - Action Buttons
    // ----------------------------------------
    @IBAction func AnimateButton(_ sender: UIButton) {
        self.paymentAnimation()
    }

    // MARK: - Functions:
    // ----------------------------------------
    func setUserSettings() {
        if let user = LocalService.instance.user {
            self.user = user
            self.nanny = user
        }
    }
    
    // LocationManager
    func enableLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        // locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func observeChildAdded(_ exemptIDs: [String]) {
        let zipMin = 5000
        let zipMax = 5200
        
        DataService.instance.REF_FAMILIESACTIVE.queryOrdered(byChild: "zip").queryStarting(atValue: zipMin).queryEnding(atValue: zipMax).observe(.childAdded, with: { (snapshot) in
            
            let familyID = snapshot.key
            
            if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                if !exemptIDs.contains(familyID) {
                    if let longitude = snapValue["longitude"] as? Double {
                        if let latitude = snapValue["latitude"] as? Double {
                            if let amount = snapValue["requestAmount"] as? Int {
                                if let start = snapValue["requestStart"] as? String {
                                    for (index,_) in snapValue.enumerated() {
                                        if index == 0 {
                                            self.fetchFamilyObserver(familyID, long: longitude, lat: latitude, amount: amount, start: start)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func fetchFamilyObserver(_ familyID: String, long: Double, lat: Double, amount: Int, start: String) {
        DataService.instance.REF_USERS_PRIVATE.child(familyID).observeSingleEvent(of:.value, with: { snapshot in
            
            if let snapValue = snapshot.value as? Dictionary<String, AnyObject>  {
                let userID = snapValue["userID"] as! String
                if familyID == userID {
                    if !self.familiesUID.contains(userID) {

                        if let imageName = snapValue["imageUrl"] as? String {
                            let ratings = snapValue["ratings"] as? [String:Int]
                            // let users = snapValue["users"] as? [String:String]
                            let family = Families(
                                imageName: imageName,
                                birthday: snapValue["birthday"] as? String,
                                userName: snapValue["userName"] as? String,
                                firstName: snapValue["first_name"] as? String,
                                lastName: snapValue["last_name"] as? String,
                                genderImage: "pin_f.png",
                                gender: snapValue["gender"] as? String,
                                yrke: snapValue["yrke"] as? String,
                                // rating: postDict["ratings"] as? Int,
                                isApproved: snapValue["vistPolitiatest"] as? Bool,
                                latitude: lat,
                                longitude: long,
                                // activateNanny: postDict["activateNanny"] as? Bool,
                                userID: (snapValue["userID"] as? String)!,
                                ratings: ratings,
                                start: start,
                                amount: amount
                            )
                            self.updateFamilyArrayAndAnnotation(family: family)
                        }
                    }
                }
            }
        })
    }
    
    func updateFamilyArrayAndAnnotation( family: Families) {
        family.distance = (self.locationManager.location?.distance(from: family.location))!
        
        self.familyBadge += 1
        self.familiez.append(family)
        self.familiesUID.append(family.userID)
        self.familiez.sort(by: { $0.intDistance < $1.intDistance })
        self.cellHeights.append(CellHeight.close)
        tableView.estimatedRowHeight = CellHeight.close
        
        var famIndex = 0
        for (idx, fam) in self.familiez.enumerated() {
            if fam.userID == family.userID {
                famIndex = idx
            }
        }
        
        let indexPath = [IndexPath(item: famIndex, section: 0)]
        self.tableView.insertRows(at: indexPath, with: .automatic)
    }
    
    // ----------------------
    // PAYMENT SYSTEM TESTING
    func paymentAnimation(animated: Bool = true) {
        if paymentShowing {
            exitPayment(animated: animated)
        } else {
            enterPayment(animated: animated)
        }
    }
    
    var paymentShowing = true
    
    func enterPayment(animated: Bool = true) {
        func initialValue() {
            self.paymentMenu.alpha = 1.0
            self.paymentMenu.layer.transform = CATransform3DMakeRotation(0, 0, 1, 0)
            self.paymentMenu.layer.transform = CATransform3DMakeScale(1.05, 1.05, 1.1)  // CGAffineTransform(scaleX: 1.00, y: 1.00)
        }
        if animated {
            UIView.animate(withDuration: 0.351, delay: 0.051, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.155, options: .curveEaseOut, animations: {
                initialValue()
            })
        } else {
            initialValue()
        }
        paymentShowing = true
    }
    
    func exitPayment(animated: Bool = true) {
        func initialValue() {
            self.paymentMenu.alpha = 0.0
            self.paymentMenu.layer.transform = CATransform3DMakeRotation(0, CGFloat.pi / 2, 1, 0)
            self.paymentMenu.layer.transform = CATransform3DMakeScale(0.9, 0.9, 0.9)
            // self.paymentMenu.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
        }
        if animated {
            UIView.animate(withDuration: 0.351, delay: 0.051, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.155, options: .curveEaseOut, animations: {
                initialValue()
            })
        } else {
            initialValue()
        }
        paymentShowing = false
    }
    // PAYMENT SYSTEM TESTING
    // ----------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.exitPayment()
        self.paymentMenu.layer.cornerRadius = 20.0
        
        self.setUserSettings()
        self.enableLocationServices()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.alpha = 0
        self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        
        self.observeChildAdded(self.exemptIDs)
        
        revealingSplashAnimation(self.view, type: SplashAnimationType.woobleAndZoomOut, duration: 1.90, delay: 0)
        
        self.user?.location = locationManager.location!
        self.nanny?.location = locationManager.location!
        
        self.familyTabBar.badgeValue = "2"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tab = self.tabBarController?.tabBar as! FrostyTabBar
        tab.setEffect(blurEffect: .light)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("viewDidAppear")
        
        if firstLoad {
            animateCells(in: self.tableView, delay: 1.95)
            self.firstLoad = false
        } else {
            animateCells(in: self.tableView)
            
        }
        hapticButton(.medium, lowPowerModeDisabled)
        self.familyBadge = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(" --- ")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tableView.alpha = 0
        self.familyBadge = 0
    }
    
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews")
        
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            self.myUserID = userID
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension FamilyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is FoldingCell {
            print("cell is FoldingCell")
        } else {
            print("cell is not of type: FoldingCell")
        }
        // allows you to check if cell "as FoldingCell" does match the pattern cell
        // "case alone" is used to match against one case.. "if case let" Explaination :
        // http://alisoftware.github.io/swift/pattern-matching/2016/05/16/pattern-matching-4/
        // Can we use "is" here ??
        if case let cell as FoldingCell = cell {
            if cellHeights[indexPath.row] == CellHeight.close {
                cell.unfold(false, animated: false, completion: nil)

            } else {
                cell.unfold(true, animated: false, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let cell as FamilyTableViewCell = tableView.cellForRow(at: indexPath) else {
            return
        }
        var duration = 0.0
        if cellHeights[indexPath.row] == CellHeight.close || !cell.isUnfolded { // open cell
            cellHeights[indexPath.row] = CellHeight.open
            cell.unfold(true, animated: true, completion: nil) // selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[indexPath.row] = CellHeight.close
            cell.unfold(false, animated: true, completion: nil) // selectedAnimation(false, animated: true, completion: nil)
            duration = 1.1
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return familiez.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FamilyCell", for: indexPath) as? FamilyTableViewCell {
            cell.setupView(family: familiez[indexPath.row], user: self.user!)
            return cell
        } else {
            return FamilyTableViewCell()
        }
    }
}
