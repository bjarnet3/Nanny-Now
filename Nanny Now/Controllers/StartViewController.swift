//
//  StartViewController.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 14.09.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit
// MapKit
import MapKit
// Firebase Part 3
import Firebase
// Facebook Part 4
import FBSDKCoreKit
import FBSDKLoginKit
// SplashView
import RevealingSplashView
// KeychainWrapper
import SwiftKeychainWrapper

class StartViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - IBOutlet: Connection to Storyboard
    // ----------------------------------------
    @IBOutlet var startTabBar: UITabBarItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties: Array and Varables
    // ----------------------------------------
    var profileImage: UIImage?
    var settings = [Settings]()
    
    var user: User?
    var viewAnimationLoaded = false
    var locationManager = CLLocationManager()
    
    // MARK: Facebook Logout
    // ----------------------------------------
    func facebookLogout() {
        let loginView : FBSDKLoginManager = FBSDKLoginManager()
        loginView.loginBehavior = FBSDKLoginBehavior.web
        
        let manager = FBSDKLoginManager()
        manager.logOut()
        
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
    }
    
    // MARK: - GET from Firebase
    // ----------------------------------------
    func getInfoFromFirebase() {
        print("-- getInfoFromFirebase")
        var user: User?
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            signedIn = true
            user = User(userUID: userID)
            let firebasePost = DataService.instance.REF_USERS_PRIVATE.child(userID)
            firebasePost.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        // Jump over communication, friends and tokens
                        if snap.key != "communication" {
                            if snap.key != "friends" {
                                if snap.key != "tokens" {
                                    if snap.key == "id" {
                                        let fid = "fid"
                                        userInfo.updateValue(snap.value!, forKey: fid)
                                    }
                                    userInfo.updateValue(snap.value as AnyObject, forKey: snap.key)
                                    
                                    if let name = snap.value as? String, snap.key == "first_name" { user?.firstName = name }
                                    if let yrke = snap.value as? String, snap.key == "yrke" { user?.jobTitle = yrke }
                                    if let birthday = snap.value as? String, snap.key == "birthday" { user?.birthday = birthday }
                                    if let imageName = snap.value as? String, snap.key == "imageUrl" {
                                        user?.imageName = imageName
                                    }
                                    
                                    if let ratings = snap.value as? [String:Int], snap.key == "ratings" {
                                        for (key, val) in ratings {
                                            user?.ratings?.updateValue(val, forKey: key)
                                        }
                                    }
                                    
                                    // Get locations from Database
                                    if snap.key == "location" {
                                        if let locations = snap.value as? [String:Any] {
                                            var location = user?._locations
                                            for (key, val) in locations {
                                                if key != "active" {
                                                    let locationName = key
                                                    if let locationCordinates = val as? [String:AnyObject] {
                                                        guard let latitude = locationCordinates["latitude"] as? Double,
                                                            let longitude = locationCordinates["longitude"] as? Double else {
                                                                printDebug(object: "didnt find anyting")
                                                                return
                                                        }
                                                        let coordinate = CLLocation(latitude: latitude, longitude: longitude)
                                                        location?.updateValue(coordinate, forKey: locationName)
                                                    }
                                                }
                                            }
                                            user?._locations = location
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                // Data Loaded From Firebase
                self.user = user
                LocalService.instance.user = user
                self.tableView.reloadData()

                // Remove RevealingSplashView from SuperView (Stop Animation)
                for splashView in self.view.subviews {
                    if splashView is RevealingSplashView {
                        // let revealingSplash = splashView as! RevealingSplashView
                        // revealingSplash.finishHeartBeatAnimation()
                        splashView.removeFromSuperview()
                        fadeView(self.tableView, direction: .Left, delay: 0.0)
                        self.viewAnimationLoaded = true
                    }
                }
            })
        }
    }
    
    // Location Services (Enable)
    func enableLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Register, Logout (function, action)
    // ----------------------------------------
    func goToRegister(pageToLoadFirst: Int = 0) {
        guard let loginPageVC = storyboard?.instantiateViewController(withIdentifier: "LoginPageVC") as? LoginPageVC else {
            return
        }
        loginPageVC.pageToLoadFirst = pageToLoadFirst
        present(loginPageVC, animated: false)
    }
    
    func goToInfoVC(pageToLoadFirst: Int = 0) {
        guard let infoVC = storyboard?.instantiateViewController(withIdentifier: "InfoVC") as? InfoViewController else {
            return
        }
        present(infoVC, animated: true)
    }
    
    func goToSubSettings() {
        guard let subSettings = storyboard?.instantiateViewController(withIdentifier: "SubSettingsViewController") as? SubSettingsViewController else {
            return
        }
        present(subSettings, animated: true)
    }
    
    func logout(service: Service = .All) {
        switch service {
        case .Facebook:
            self.facebookLogout()
        case .Firebase:
            try! Auth.auth().signOut()
        default:
            _ = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            try! Auth.auth().signOut()
            self.facebookLogout()
            self.imageView.image = UIImage(named: "")
            signedIn = false
            userFriends.removeAll()
            userInfo.removeAll()
            user = nil
            LocalService.instance.user = nil
            publicInfo.removeAll()
        }
    }
}

// MARK: - ViewDidLoad, ViewWillLoad etc...
// ----------------------------------------
extension StartViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.alpha = 0.0
        revealingSplashAnimation(self.view, type: SplashAnimationType.heartBeat, completion: {
            // fadeView(self.tableView, direction: .Left, delay: 0.0)
            // self.viewAnimationLoaded = true
        })
        
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            signedIn = true
            DataService.instance.addTokenToDatabase(for: userID)
            DataService.instance.clearBadge()
            self.getInfoFromFirebase()
            self.enableLocationServices()
        } else {
            signedIn = false
            self.goToRegister(pageToLoadFirst: 0)
        }
        
        self.settings = LocalService.instance.getSettings()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Set Frosty TabBar
        let tab = self.tabBarController?.tabBar as! FrostyTabBar
        tab.setEffect(blurEffect: .extraLight)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if viewAnimationLoaded {
            fadeView(self.tableView)
        }
        
        if !signedIn { self.goToRegister() }
        hapticButton(.heavy, lowPowerModeDisabled)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tableView.alpha = 0.0
    }
}

// MARK: - TableView, Delegate & Datasource
// ----------------------------------------
extension StartViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight: CGFloat = 65
        if indexPath.row == 0 {
            rowHeight = 250
        }
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hapticButton(.selection, lowPowerModeDisabled)
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row != 0 {
            if indexPath.row == 1 {
                self.view.blur(blurRadius: 10.0)
                self.goToRegister(pageToLoadFirst: 1)
            } else if indexPath.row == 2 {
                self.sendRequestAlert()
            } else if indexPath.row == 3 {
                print("instillinger")
                self.goToSubSettings()
            } else if indexPath.row == 4 {
                self.standardAlert()
            } else if indexPath.row == 5 {
                self.logoutAlertActionSheet()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            if let cell = tableView.cellForRow(at: indexPath) as? SettingsTableViewCell {
                UIView.animate(withDuration: 0.30, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                    cell.titleLbl.textColor = UIColor.darkGray
                    cell.descriptionLbl.textColor = hexStringToUIColor("#FC2F92")
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FirstCell") as? FirstTableViewCell {
                if let user = self.user {
                    cell.setupView(user: user)
                    return cell
                }
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as? SettingsTableViewCell {
                let settings = LocalService.instance.getSettings()
                let settingsRow = indexPath.row - 1
                
                cell.setupView(settings: settings[settingsRow])
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if self.user != nil {
            rowCount = settings.count + 1
        }
        return rowCount
    }
}

// MARK: - UIAlertController (Alert Actions)
// ----------------------------------------
extension StartViewController {
    
    func standardAlert() {
        self.view.blur(blurRadius: 10.0)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let infoAction = UIAlertAction(title: "Informasjon", style: .default) { (_) in
            self.view.unBlur()
            self.goToInfoVC()
        }
        
        let contactAction = UIAlertAction(title: "Kontakt Oss", style: .default) { (_) in
            self.view.unBlur()
            
            if let url = URL(string: "http://www.nannynow.no"){
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Avbryt", style: .cancel) { (_) in
            self.view.unBlur()
        }
        
        alertController.addAction(infoAction)
        alertController.addAction(contactAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {
            
        }
    }
    
    func logoutAlertActionSheet() {
        self.view.blur(blurRadius: 10.0)
        
        let user = self.user
        let name = user?.firstName ?? "Deg selv"
        
        let alertController = UIAlertController(title: "Er du helt sikker på at du vil logg ut \(name)?", message: nil, preferredStyle: .actionSheet)
        
        let logoutAction = UIAlertAction(title: "Logg ut", style: .destructive) { (_) in
            self.logout(service: .All)
            self.goToRegister()
        }
        
        let cancelAction = UIAlertAction(title: "Avbryt", style: .cancel) { (_) in
            self.view.unBlur()
        }
        
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) { }
    }
    
    func sendRequestAlert() {
        self.view.blur(blurRadius: 10.0)
        
        let controller = UIAlertController(title: "Title ", message: "Message", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Avbryt", style: .cancel) { (action) in
            self.view.unBlur()
            hapticButton(.warning, lowPowerModeDisabled)
        }
        let sendButton = UIAlertAction(title: "Send", style: .default) { (action) in
            let text = controller.textFields?.first?.text
            print(text ?? "sendButton")
            
            self.view.unBlur()
            hapticButton(.success, lowPowerModeDisabled)
        }
        controller.addAction(cancelButton)
        controller.addAction(sendButton)
        
        controller.addTextField { (textField) in
            textField.placeholder = "  placeholder text  "
            textField.keyboardType = .numbersAndPunctuation
        }
        self.present(controller, animated: true, completion: nil)
    }
}

/* Notificaton Message with Data
 
 One Token
 
 curl -H "Content-type: application/json" -H "Authorization:key=AAAAd-nNctg:APA91bGhfGrYaRg-QOHx0LlfTyqU9cwOECMvm6jGHMZaeLGsToNPJtgV0y-EfcmMVFZbfbxdkF3ubJ8NC94-B-I74lV-UG2f-kuvjLtOnG_wbHecjdBc93Y59tv7XCJCEXEW3hTKH4oC"  -X POST -d '{ "data": { "score": "5x1","time": "15:10"},"to" : "ccDJKeFfbXI:APA91bHJWgGUmBzGv1mQ4Kny7VRf5EnF4GHYMSKE95TqKJsrLSp0djopYmJ4lAXm-jfQZBfIXs_mMWtp75Ov0uhzNPbLMfck_EExWnvwRDvUXmWIaFyiJuOPbOsoXwilHBojak9Lb93E","notification":{"title":"Title Text","body":"Message from Terminal","sound":"default","badge":1},"priority":10}' https://fcm.googleapis.com/fcm/send
 
 Multiple Tokens - User array ["token1", "token2"]
 
 curl -H "Content-type: application/json" -H "Authorization:key=AAAAd-nNctg:APA91bGhfGrYaRg-QOHx0LlfTyqU9cwOECMvm6jGHMZaeLGsToNPJtgV0y-EfcmMVFZbfbxdkF3ubJ8NC94-B-I74lV-UG2f-kuvjLtOnG_wbHecjdBc93Y59tv7XCJCEXEW3hTKH4oC"  -X POST -d '{ "data": { "score": "5x1","time": "15:10"},"registration_ids" : ["fid3sFDNwHg:APA91bHMFr_YCwK9ern4RP_IJJom7s7iL7sGU1t1f3EFfCQ5hOME41Fe-hy1l38xU18zeWpSnNS3GHuFGqmok-nY_QltG6pzGKQZWVJVOLD_hD8Yw5MtVYqxdLDoStjt5dcAxWOfByhz"],"notification":{"title":"Title Text","body":"Message from Terminal","sound":"default","badge":1},"priority":10}' https://fcm.googleapis.com/fcm/send
 
 */
