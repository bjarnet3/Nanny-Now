//
//  RequestViewController.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 02.09.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SwiftKeychainWrapper
import UserNotifications
import RevealingSplashView

class RequestViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: CustomTableView!

    @IBOutlet weak var profileImage: CustomImageView!

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var brandingLabel: UILabel!
    
    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var acceptLabel: UILabel!
    @IBOutlet weak var rejectLabel: UILabel!
    @IBOutlet weak var completeLabel: UILabel!
    
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    var user: User?
    var requests = [Request]()
    
    var requestSections = [RequestStatus:[Request]]()
    var totalRequests: Int = 0
    var returnWithDismiss = false
    
    // Set User Object
    func getUserSettings() {
        if let user = LocalService.instance.getUser() {
            self.user = user
            
            self.welcomeLabel.text = "Hello, \(user.firstName)"
            self.profileImage.loadImageUsingCacheWith(urlString: user.imageName)
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
    
    func setBrandingLabel() {
        self.brandingLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.brandingLabel.layer.cornerRadius = self.brandingLabel.frame.height / 2
        self.brandingLabel.clipsToBounds = true
    }
    
    // LocationManager
    func enableLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        // locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Property Observer
    // ----------------
    var pendingCount: Int = 0 {
        didSet {
            self.pendingLabel.text = "\(pendingCount) pending"
            if pendingCount == 0 {
                self.requestSections.removeValue(forKey: .pending)
            } else {
                var requestArray = requests.filter{ $0.requestStatus == RequestStatus.pending.rawValue }
                requestArray.sort(by: { $0.timeRequested <= $1.timeRequested })
                requestSections.updateValue(requestArray, forKey: .pending)
            }
        }
    }
    
    var acceptedCount: Int = 0 {
        didSet {
            self.acceptLabel.text = "\(acceptedCount) accepted"
            if acceptedCount == 0 {
                self.requestSections.removeValue(forKey: .accepted)
            } else {
                var requestArray = requests.filter{ $0.requestStatus == RequestStatus.pending.rawValue }
                requestArray.sort(by: { $0.timeRequested <= $1.timeRequested })
                requestSections.updateValue(requestArray, forKey: .accepted)
            }
        }
    }
    
    var rejectedCount: Int = 0 {
        didSet {
            self.rejectLabel.text = "\(rejectedCount) rejected"
            if rejectedCount == 0 {
                self.requestSections.removeValue(forKey: .rejected)
            } else {
                var requestArray = requests.filter{ $0.requestStatus == RequestStatus.pending.rawValue }
                requestArray.sort(by: { $0.timeRequested <= $1.timeRequested })
                requestSections.updateValue(requestArray, forKey: .rejected)
            }
        }
    }
    
    var completeCount: Int = 0 {
        didSet {
            self.completeLabel.text = "\(completeCount) complete"
            if completeCount == 0 {
                self.requestSections.removeValue(forKey: .complete)
            } else {
                var requestArray = requests.filter{ $0.requestStatus == RequestStatus.complete.rawValue }
                requestArray.sort(by: { $0.timeRequested <= $1.timeRequested })
                requestSections.updateValue(requestArray, forKey: .complete)
            }
        }
    }
    
    var runningCount: Int = 0 {
        didSet {
            if runningCount == 0 {
                self.requestSections.removeValue(forKey: .running)
            } else {
                var requestArray = requests.filter{ $0.requestStatus == RequestStatus.complete.rawValue }
                requestArray.sort(by: { $0.timeRequested <= $1.timeRequested })
                requestSections.updateValue(requestArray, forKey: .running)
            }
        }
    }
    
    var requestBadge: Int = 0 {
        didSet {
            self.tabBarItem.badgeValue = requestBadge != 0 ? "\(requestBadge)" : nil
        }
    }
    // ----------------
    // ----------------
    
    // MARK: - Observer, Firebase Database Functions
    // ----------------------------------------
    func observeRequests(_ exemptIDs: [String] = []) {
        if let UID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            DataService.instance.REF_REQUESTS.child("private").child(UID).child("requests").observe(.value, with: { (snapshot) in
                
                if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                    self.totalRequests = snapValue.keys.count
                    
                    self.requests.removeAll()
                    self.requestSections.removeAll()
                    self.resetRequestStatusCount()
                    
                    for (_,value) in snapValue {
                        if let snapRequest = value as? [String:AnyObject] {
                            
                            if let snapKey = snapRequest["userID"] as? String {
                                self.fetchRequestObserver(snapRequest, remoteUID: snapKey)
                            }
                        }
                    }
                }
                
            })
        }
    }
    
    func fetchRequestObserver(_ requestSnap: Dictionary<String, AnyObject>, remoteUID: String) {
        let userRef = DataService.instance.REF_USERS_PRIVATE.child(remoteUID)
        // let userPublicREF = DataService.instance.REF_USERS_PUBLIC.child(remoteUID)
        let request = Request(
            requestID: requestSnap["requestID"] as! String,
            nannyID: requestSnap["nannyID"] as! String,
            userID: requestSnap["userID"] as! String,
            familyID: requestSnap["familyID"] as! String,
            highlighted: requestSnap["highlighted"] as! Bool,
            timeRequested: requestSnap["requestDate"] as! String,
            timeFrom: requestSnap["timeFrom"] as! String,
            timeTo: requestSnap["timeTo"] as! String,
            message: requestSnap["requestMessage"] as? String,
            requestAmount: requestSnap["requestAmount"] as? Int ?? 0,
            requestStatus: requestSnap["requestStatus"] as! String,
            requestCategory: requestSnap["requestCategory"] as! String,
            requestREF: userRef)
        self.oldObserveUser(request: request, userRef: userRef)
    }
    
    func oldObserveUser(request: Request, userRef: DatabaseReference) {
        if self.requests.count < self.totalRequests {
            
            var requestVal = request
            let reference = userRef
            
            reference.observeSingleEvent(of: .value, with: { snapshot in
                if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                    
                    var imageName: String?
                    var firstName: String?
                    var userStatus: Date?
                    
                    for (key, val) in snapValue {
                        if key == "imageUrl" {
                            imageName = val as? String
                        }
                        if key == "first_name" {
                            firstName = val as? String
                        }
                        
                        if key == "status" {
                            if let status = val as? [String: AnyObject] {
                                for (k, v) in status {
                                    if k == "time" {
                                        if let timeValue = v as? String {
                                            userStatus = stringToDateTime(timeValue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    requestVal.imageName = imageName != nil ? imageName! : ""
                    requestVal.firstName = firstName != nil ? firstName! : ""
                    requestVal.userStatus = userStatus!
                    
                    self.requests.append(requestVal)
                    self.setRequestStatusCountFrom(request: requestVal)
                    
                    self.requestBadge = self.requests.count
                    self.tableView.reloadData()
                }
            })
        } else {
            self.tableView.reloadData()
        }
    }
    
    func resetRequestStatusCount() {
        self.acceptedCount = 0
        self.pendingCount = 0
        self.completeCount = 0
        self.acceptedCount = 0
        self.runningCount = 0
    }
    
    func setRequestStatusCountFrom(request: Request) {
        if let requestStatus = requestStatusString(request: request.requestStatus) {
            switch requestStatus {
            case .accepted:
                self.acceptedCount += 1
            case .complete:
                self.completeCount += 1
            case .pending:
                self.pendingCount += 1
            case .rejected:
                self.rejectedCount += 1
            case .running:
                self.runningCount += 1
            }
        }
    }
    
    func removeAllDatabaseObservers() {
        if let UID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            DataService.instance.REF_REQUESTS.child("private").child(UID).child("requests").removeAllObservers()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getUserSettings()
        setBrandingLabel()
        
        self.enableLocationServices()
        self.user?.location = locationManager.location
        
        observeRequests()
        
        // Splash Animation
        // ----------------
        revealingSplashAnimation(self.view, type: SplashAnimationType.woobleAndZoomOut, completion: {
            // self.tableView.reloadData()
            UIView.animate(withDuration: 0.51, delay: 0.151, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.95, options: .curveEaseIn, animations: {
                printFunc("revelingSplashAnimation Animation Complete")
            }, completion: { (true) in
                printFunc("revelingSplashAnimation Completion:")
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - TableView, Delegate & Datasource
// ----------------------------------------
extension RequestViewController: UITableViewDelegate, UITableViewDataSource {
    
    // TableView Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return requestSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        for (reqIndex, reqSection) in self.requestSections.keys.enumerated() {
            if reqIndex == section {
                return reqSection.rawValue
            }
        }
        return nil
    }
    
    // TableView Rows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = UITableViewCell()
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as? RequestCell {
            
            for (index, sectRequests) in self.requestSections.values.enumerated() {
                if index == indexPath.section {
                    for val in sectRequests {
                        cell.setupView(request: val, animated: true)
                        return cell
                    }
                }
            }
        }
        return defaultCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // let mainHeight = (indexPath.row < self.heightForRow.count) ? self.heightForRow[indexPath.row] : 80
        // let cellHeight = self.requests[indexPath.row + 2].requestStatus != "rejected" ? cellHeights[indexPath.row - 2] : mainHeight
        return 80.0 // 140.0 cellHeights[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for (idx, val) in requestSections.values.enumerated() {
            if idx == section {
                return val.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let requestDetail = storyboard?.instantiateViewController(withIdentifier: "RequestDetail") as? RequestDetailVC else { return
        }
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell is RequestUserCell {
                let request = requests[indexPath.row - 2]
                if let adminUser = self.user {
                    let guestUser = User(userUID: request.userID, imageName: request.imageName, firstName: request.firstName)
                    requestDetail.initWith(adminUser: adminUser, guestUser: guestUser, viewRect: tableView.bounds)
                    self.returnWithDismiss = true
                    present(requestDetail, animated: false)
                } else {
                    printFunc("adminUser / user not initialized")
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Swipe to delete implemented :-P,, other tableView cell button implemented :-D howdy!
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Haptic Light
        hapticButton(.light, lowPowerModeDisabled)
        
        let delete = UITableViewRowAction(style: .destructive, title: " ⊗ ") { (action , indexPath ) -> Void in
            
            self.requests.remove(at: indexPath.row)
            self.tableView.isEditing = false
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let request = UITableViewRowAction(style: .destructive, title: " ☑︎ ") { (action , indexPath) -> Void in
            // self.enterRequestMenu()
            // self.sendRequestAlert(row: indexPath.row)
        }
        
        let more = UITableViewRowAction(style: .default, title: " ⋮ ") { (action, indexPath) -> Void in
            // Show on map
            // self.standardAlert(row: indexPath.row)
            self.standardAlert(request: self.requests[indexPath.row])
        }
        
        delete.backgroundColor = SILVER
        request.backgroundColor = LIGHT_GREY
        more.backgroundColor = PINK_NANNY_LOGO
        
        return [delete, request, more]
    }
}

// SET STATUS
extension RequestViewController {
    func standardAlert(request: Request) {
        
        guard let userID = self.user?.userUID else { return }
        let remoteID = request.userID
        guard let requestID = request.requestID else { return }
        
        let publicRequest = DataService.instance.REF_REQUESTS.child("public").child(userID).child(requestID)
        let privateRequest = DataService.instance.REF_REQUESTS.child("private").child(userID).child("requests").child(requestID)
        
        let publicRemote = DataService.instance.REF_REQUESTS.child("public").child(remoteID).child(requestID)
        // let privateRemote = DataService.instance.REF_REQUESTS.child("private").child(remoteID).child("requests").child(requestID)
        
        func returnRequestStatus(requestStatus: RequestStatus) -> [String:String] {
            return [ "requestStatus":requestStatus.rawValue ]
        }
        
        let alertController = UIAlertController(title: "Oppdater Forespørsel", message: "Sett status og svar på forespørsel", preferredStyle: .alert)
        
        let setAccept = UIAlertAction(title: "Aksepter", style: .default) { (_) in
            let updateStatus = returnRequestStatus(requestStatus: RequestStatus.accepted)
            
            publicRequest.updateChildValues(updateStatus)
            DataService.instance.moveValuesFromRefToRef(fromReference: publicRequest, toReference: privateRequest)
            
            publicRemote.updateChildValues(updateStatus)
            
            var returnRequest = request
            returnRequest.requestStatus = RequestStatus.accepted.rawValue
            returnRequest.userID = userID
            
            Notifications.instance.sendNotification(with: returnRequest)
        }
        
        let setPending = UIAlertAction(title: "Venter", style: .default) { (_) in
            let updateStatus = returnRequestStatus(requestStatus: RequestStatus.pending)
            
            publicRequest.updateChildValues(updateStatus)
            DataService.instance.moveValuesFromRefToRef(fromReference: publicRequest, toReference: privateRequest)
            
            publicRemote.updateChildValues(updateStatus)
            
            var returnRequest = request
            returnRequest.requestStatus = RequestStatus.pending.rawValue
            returnRequest.userID = userID
            
            Notifications.instance.sendNotification(with: returnRequest)
        }
        
        let setReject = UIAlertAction(title: "Avvis", style: .destructive) { (_) in
            let updateStatus = returnRequestStatus(requestStatus: RequestStatus.rejected)
            
            publicRequest.updateChildValues(updateStatus)
            DataService.instance.moveValuesFromRefToRef(fromReference: publicRequest, toReference: privateRequest)
            
            publicRemote.updateChildValues(updateStatus)
            
            var returnRequest = request
            returnRequest.requestStatus = RequestStatus.rejected.rawValue
            returnRequest.userID = userID
            
            Notifications.instance.sendNotification(with: returnRequest)
        }
        
        let cancelAction = UIAlertAction(title: "Tilbake", style: .cancel) { (_) in
        }
        
        setAccept.isEnabled = request.requestStatus == RequestStatus.accepted.rawValue ? false : true
        setPending.isEnabled = request.requestStatus == RequestStatus.pending.rawValue ? false : true
        setReject.isEnabled = request.requestStatus == RequestStatus.rejected.rawValue ? false : true
        
        alertController.addAction(setAccept)
        alertController.addAction(setPending)
        alertController.addAction(setReject)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: lowPowerModeDisabled) {
        }
    }
}
