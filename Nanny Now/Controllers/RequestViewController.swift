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

class RequestViewController: UIViewController {

    @IBOutlet weak var tableView: CustomTableView!
    
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    var user: User?
    var requests = [Request]()
    var totalRequests: Int = 0
    var heightForRow:[CGFloat] = [5,170,80]
    
    var introAnimationLoaded = false
    var returnWithDismiss = false
    
    // Set User Object
    func getUserSettings() {
        if let user = LocalService.instance.getUser() {
            self.user = user
        }
    }
    
    // Property Observer
    // ----------------
    var pendingCount: Int = 0 {
        didSet {
            let secondCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RequestBodyCell
            secondCell?.pendingCount = pendingCount
        }
    }
    
    var acceptedCount: Int = 0 {
        didSet {
            let secondCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RequestBodyCell
            secondCell?.acceptedCount = acceptedCount
        }
    }
    
    var completeCount: Int = 0 {
        didSet {
            let secondCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RequestBodyCell
            secondCell?.completeCount = completeCount
        }
    }
    
    var rejectedCount: Int = 0 {
        didSet {
            let secondCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RequestBodyCell
            secondCell?.rejectedCount = rejectedCount
        }
    }
    
    var runningCount: Int = 0 {
        didSet {
            print("running")
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
        self.observeUser(request: request, userRef: userRef)
    }
    
    func observeUser(request: Request, userRef: DatabaseReference) {
        setRequestStatusCountFrom(request: request)
        
        if self.requests.count < self.totalRequests {
            var requestVal = request
            let reference = userRef
            reference.observeSingleEvent(of: .value, with: { snapshot in
                if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                    for (key, val) in snapValue {
                        if let userValue = val as? String {
                            if key == "first_name" {
                                requestVal.firstName = userValue
                            } else if key == "imageUrl" {
                                requestVal.imageName = userValue
                            } else if key == "status" {
                                requestVal.userStatus = stringToDateTime(userValue)
                            }
                        }
                    }
                }
                if let index = self.requests.index(where: { $0.timeRequested <= requestVal.timeRequested }) {
                    self.requests.insert(requestVal, at: index)
                    let indexPath = IndexPath(row: index.advanced(by: 2), section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                } else {
                    self.requests.append(requestVal)
                }
                self.tableView.reloadData()
                self.requestBadge += 1
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
        observeRequests()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - TableView, Delegate & Datasource
// ----------------------------------------
extension RequestViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let returnCell = UITableViewCell()
            if indexPath.row == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "RequestHeaderCell", for: indexPath) as? RequestHeaderCell {
                    return cell
                }
            } else if indexPath.row == 1 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "RequestBodyCell", for: indexPath) as? RequestBodyCell {
                    cell.setupView(user: self.user!)
                    cell.layoutIfNeeded()
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "RequestUserCell", for: indexPath) as? RequestUserCell {
                    cell.setupView(request: requests[indexPath.row - 2], animated: true)
                    // https://stackoverflow.com/questions/30066625/uiimageview-in-table-view-not-showing-until-clicked-on-or-device-is-roatated
                    return cell
                }
            }
        return returnCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mainHeight = (indexPath.row < self.heightForRow.count) ? self.heightForRow[indexPath.row] : 80
        return mainHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row >= 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count + 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let requestDetail = storyboard?.instantiateViewController(withIdentifier: "RequestDetail") as? RequestDetailVC else { return
            }
            
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell is RequestUserCell {
                    if let requestCell = cell as? RequestUserCell {
                        
                        let request = requests[indexPath.row - 2]
                        let adminUser = self.user!
                        let guestUser = User(userUID: request.userID, imageName: request.imageName, firstName: request.firstName)
                        
                        
                        
                        requestDetail.initWith(adminUser: adminUser, guestUser: guestUser, viewRect: tableView.bounds)
                        self.returnWithDismiss = true
                        present(requestDetail, animated: false)
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
            
                self.requests.remove(at: indexPath.row - 2)
                
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
                self.standardAlert(request: self.requests[indexPath.row - 2])
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
