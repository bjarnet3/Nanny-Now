//
//  RequestViewController.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 06.12.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SwiftKeychainWrapper
import UserNotifications
import RevealingSplashView

class MessageViewController: UIViewController {
    
    // MARK: - IBOutlet: Connection to Storyboard
    // ----------------------------------------
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTable: CustomTableView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var requestTable: CustomTable!
    
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    private var user: User?
    private var messages = [Message]()
    
    private var totalMessages: Int = 0
    
    private var lastRowSelected: IndexPath?
    private var heightForRow:[CGFloat] = [5,170,80]
    
    private var animatorIsBusy = false
    private var introAnimationLoaded = false
    private var returnWithDismiss = false
    
    private let cornerRadius: CGFloat = 22.0
    private let inactiveOffset: CGFloat = 80
    
    private let messageTableOffset: CGFloat = 0
    private let messageTableMaxY: CGFloat = 22
    
    private let messageTableMaximizedHeight: CGFloat = UIScreen.main.bounds.height - 22
    private let messageTableMinimizedWidth: CGFloat = UIScreen.main.bounds.width - 22
    
    private var mainScreenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    private var mainScreenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Property Observer
    private var runningCount: Int = 0 {
        didSet {
        }
    }
    
    private var messageBadge: Int = 0 {
        didSet {
            self.tabBarItem.badgeValue = messageBadge != 0 ? "\(messageBadge)" : nil
        }
    }
    
    private func mainAction() {
        hapticButton(.selection)
    }
    
    // MARK: - Functions, Database & Animation
    // ----------------------------------------
    private func setMessageTable() {
        self.messageView.frame = CGRect(x: 0, y: self.messageTableMaxY, width: self.mainScreenWidth, height: self.mainScreenHeight - self.messageTableMaxY)
        self.messageView.alpha = 1.0
        self.messageView.layer.cornerRadius = self.cornerRadius
        self.messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.messageTable.contentInset.top = 20
        self.messageTable.contentInset.bottom = 110
    }
    
    // Set User Object
    private func getUserSettings() {
        if let user = LocalService.instance.getUser() {
            self.user = user
        }
    }
    
    // MARK: - Observer, Firebase Database Functions
    // ----------------------------------------
    private func observeMessages(_ exemptIDs: [String] = []) {
        if let UID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            DataService.instance.REF_MESSAGES.child("private").child(UID).child("last").queryOrdered(byChild: "messageTime").observe(.value, with: { (snapshot) in
                let remoteID = snapshot.key
                
                self.messages.removeAll()
                
                if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                    self.totalMessages = snapValue.keys.count
                    
                    if !exemptIDs.contains(remoteID) {
                        
                        for (key,value) in snapValue {
                            if let snapMessage = value as? [String:AnyObject] {
                                self.fetchMessageObserver(snapMessage, remoteUID: key, userUID: UID)
                            }
                        }
                    }
                }
                
            })
        }
    }
    
    // MARK: - Observer, Firebase Database Functions
    // ----------------------------------------
    private func fetchMessageObserver(_ messageSnap: Dictionary<String, AnyObject>, remoteUID: String, userUID: String) {
        let userREF = DataService.instance.REF_USERS_PRIVATE.child(remoteUID)
        let message = Message(
            from:  messageSnap["fromUID"] as! String,
            to:  messageSnap["toUID"] as! String,
            messageID: messageSnap["messageID"] as? String,
            message:  messageSnap["message"] as! String,
            messageTime:  messageSnap["messageTime"] as! String,
            highlighted:  (messageSnap["highlighted"] as? Bool)!)
        self.observeUser(with: message, userRef: userREF)
    }
    
    private func observeUser(with message: Message, userRef: DatabaseReference) {
        if self.messages.count < self.totalMessages {
            userRef.observeSingleEvent(of: .value, with: { snapshot in
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
                        if let timeString = val as? String, key == "status" {
                            userStatus = stringToDateTime(timeString)
                        }
                    }
                    
                    var message = message
                    
                    let user = User(userUID: message._fromUID, imageName: imageName, firstName: firstName)
                    message.setFrom(user: user)
                    
                    let remote = User(userUID: message._toUID, imageName: imageName, firstName: firstName)
                    message.setTo(user: remote)
                    message.userStatus = userStatus!
                    
                    self.messages.sort(by: { $0._messageTime > $1._messageTime })
                    self.messages.append(message)
                    self.messages.sort(by: { $0._messageTime > $1._messageTime })
                    
                    self.messageTable.reloadData()
                }
            })
        } else {
            self.messageTable.reloadData()
        }
    }
    
    // MARK: - Go to : LoginPageVC, InfoVC
    // ----------------------------------------
    public func goToRegister(pageToLoadFirst: Int = 0) {
        /*
        guard let loginPageVC = storyboard?.instantiateViewController(withIdentifier: "LoginPageVC") as? LoginPageVC else {
            return
        }
        loginPageVC.pageToLoadFirst = pageToLoadFirst
        present(loginPageVC, animated: false)
        */
    }
    
    public func goToInfoVC(pageToLoadFirst: Int = 0) {
        /*
        guard let infoVC = storyboard?.instantiateViewController(withIdentifier: "InfoVC") as? InfoViewController else {
            return
        }
        present(infoVC, animated: true)
        */
    }
    
}

// MARK: - ViewDidLoad, ViewWillLoad etc...
// ----------------------------------------
extension MessageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.messageTable.delegate = self
        self.messageTable.dataSource = self
        
        setMessageTable()
        getUserSettings()
        observeMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !self.returnWithDismiss {
            hapticButton(.heavy, lowPowerModeDisabled)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.messageBadge = 0
    }
    
}

// MARK: - ScrollView, Delegate & Datasource
// ----------------------------------------
extension MessageViewController: UIScrollViewDelegate {
    
    func returnScrollValue(with scrollOffset: CGFloat, valueOffset: CGFloat) -> CGFloat {
        let value = (((scrollOffset / 100)) / -1) - valueOffset
        
        let valueMin = value < 0.0 ? 0.0 : value
        let valueMax = value > 1.0 ? 1.0 : value
        
        let result = value < valueMin ? valueMin : valueMax
        
        return result
    }
    
    // Search for: scrollViewDidScroll UIVisualEffect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -30 {
            
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("scrollViewWillEndDragging: \(velocity)")
        
        if scrollView.contentOffset.y <= -80 {
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        print("decelerate: \(decelerate)")
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        // Drag down
        if scrollView.contentOffset.y <= -80 {
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation")
    }
}

// MARK: - TableView, Delegate & Datasource
// ----------------------------------------
extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let returnCell = UITableViewCell()
        if tableView == messageTable {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as? MessageTableViewCell {
                cell.setupView(with: messages[indexPath.row])
                return cell
            }
            
        }
        return returnCell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let backHeight: CGFloat = 80
        return backHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView == messageTable
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.messageTable {
            tableView.deselectRow(at: indexPath, animated: true)
            
            
            guard let messageDetailVC = storyboard?.instantiateViewController(withIdentifier: "MessageDetail") as? MessageDetailVC else {
                return
            }

            if let remoteFrom = messages[indexPath.row]._fromUser {
                if let user = self.user {
                    if let remoteUser = remoteFrom.userUID != user.userUID ? remoteFrom : messages[indexPath.row]._toUser {
                        
                        messageDetailVC.setupView(user: user, remoteUser: remoteUser)
                        
                        self.returnWithDismiss = true
                        present(messageDetailVC, animated: true)
                    }
                }
            }
            
            
            
        }
    }
    
    // Swipe to delete implemented :-P,, other tableView cell button implemented :-D howdy!
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Haptic Light
        hapticButton(.light, lowPowerModeDisabled)
        
        let delete = UITableViewRowAction(style: .destructive, title: " ⊗ ") { (action , indexPath ) -> Void in
                self.messages.remove(at: indexPath.row)
                
                self.messageTable.isEditing = false
                self.messageTable.deleteRows(at: [indexPath], with: .fade)
        }
        
        let request = UITableViewRowAction(style: .destructive, title: " ☑︎ ") { (action , indexPath) -> Void in
            // self.enterRequestMenu()
            // self.sendRequestAlert(row: indexPath.row)
        }
        
        let more = UITableViewRowAction(style: .default, title: " ⋮ ") { (action, indexPath) -> Void in
            // Show on map
            // self.standardAlert(row: indexPath.row)
        }
        
        delete.backgroundColor = SILVER
        request.backgroundColor = LIGHT_GREY
        more.backgroundColor = PINK_NANNY_LOGO
        
        return [delete, request, more]
    }
    
}

// SET STATUS
extension MessageViewController {
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
