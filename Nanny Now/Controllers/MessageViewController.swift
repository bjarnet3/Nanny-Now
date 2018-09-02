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
    @IBOutlet weak var tableView: CustomTableView!
    
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    var user: User?
    var messages = [Message]()
    var totalMessages: Int = 0
    
    var heightForRow:[CGFloat] = [5,170,80]
    
    var introAnimationLoaded = false
    var returnWithDismiss = false
    
    let messageTableOffset: CGFloat = 0
    let messageTableMaxY: CGFloat = 22
    let messageTableMaximizedHeight: CGFloat = UIScreen.main.bounds.height - 22
    let messageTableMinimizedWidth: CGFloat = UIScreen.main.bounds.width - 22
    
    var mainScreenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    var mainScreenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    var messageBadge: Int = 0 {
        didSet {
            self.tabBarItem.badgeValue = messageBadge != 0 ? "\(messageBadge)" : nil
        }
    }
    
    func setMessageTable() {
        self.tableView.contentInset.top = 20
        self.tableView.contentInset.bottom = 110
    }
    
    // Set User Object
    func getUserSettings() {
        if let user = LocalService.instance.getUser() {
            self.user = user
        }
    }
    
    
    // Check if image is loaded for MessageTableViewCell
    func lastBackCellLayout() {
        for cell in tableView.visibleCells {
            if cell is MessageTableViewCell {
                if let backCells = cell as? MessageTableViewCell {
                    if backCells.cellImageLoaded != true {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - Observer, Firebase Database Functions
    // ----------------------------------------
    func observeMessages(_ exemptIDs: [String] = []) {
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
    
    func fetchMessageObserver(_ messageSnap: Dictionary<String, AnyObject>, remoteUID: String, userUID: String) {
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
    
    func observeUser(with message: Message, userRef: DatabaseReference) {
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
                    
                    var message = message
                    let user = User(userUID: message._fromUID, imageName: imageName, firstName: firstName)
                    message.setFrom(user: user)
                    
                    let remote = User(userUID: message._toUID, imageName: imageName, firstName: firstName)
                    message.setTo(user: remote)
                    
                    message.userStatus = userStatus!
                    
                    self.messages.sort(by: { $0._messageTime > $1._messageTime })
                    self.messages.append(message)
                    self.messages.sort(by: { $0._messageTime > $1._messageTime })
                    
                    self.tableView.reloadData()
                }
            })
        } else {
            self.tableView.reloadData()
        }
    }
    
    func removeAllDatabaseObservers() {
        if let UID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            DataService.instance.REF_MESSAGES.child("private").child(UID).child("last").queryOrdered(byChild: "messageTime").removeAllObservers()
        }
    }
    
    // MARK: - Go to : LoginPageVC, InfoVC
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
}

// MARK: - ViewDidLoad, ViewWillLoad etc...
// ----------------------------------------
extension MessageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()


        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        setMessageTable()
        getUserSettings()
        observeMessages()
        
        revealingSplashAnimation(self.view, type: SplashAnimationType.swingAndZoomOut, completion: {
            
            self.tableView.reloadData()
            
            UIView.animate(withDuration: 0.51, delay: 0.151, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.95, options: .curveEaseIn, animations: {
                print("- revealingSplashAnimation (completion:)")

            }, completion: { (true) in
                
                
            })
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.returnWithDismiss {
            hapticButton(.heavy, lowPowerModeDisabled)
        }
        
        self.removeAllDatabaseObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeMessages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeAllDatabaseObservers()
        self.messageBadge = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - ScrollView, Delegate & Datasource
// ----------------------------------------
extension MessageViewController: UIScrollViewDelegate {
    // Search for: scrollViewDidScroll UIVisualEffect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView == scrollView {
           
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("scrollViewWillEndDragging: \(velocity)")

    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        print("decelerate: \(decelerate)")
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as? MessageTableViewCell {
                cell.setupView(with: messages[indexPath.row])
                return cell
            }
        return returnCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    // Swipe to delete implemented :-P,, other tableView cell button implemented :-D howdy!
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Haptic Light
        hapticButton(.light, lowPowerModeDisabled)
        
        let delete = UITableViewRowAction(style: .destructive, title: " ⊗ ") { (action , indexPath ) -> Void in
                self.messages.remove(at: indexPath.row)
                
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
        }
        
        delete.backgroundColor = SILVER
        request.backgroundColor = LIGHT_GREY
        more.backgroundColor = PINK_NANNY_LOGO
        
        return [delete, request, more]
    }
    
}
