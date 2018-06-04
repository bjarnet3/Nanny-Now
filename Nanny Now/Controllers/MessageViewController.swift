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
    @IBOutlet weak var backTable: CustomTableView!
    @IBOutlet weak var mainTable: CustomTableView!
    
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    var user: User?
    
    var requests = [Request]()
    var messages = [Message]()
    
    var totalRequests: Int = 0
    var totalMessages: Int = 0
    
    var lastRowSelected: IndexPath?
    var heightForRow:[CGFloat] = [50,160,80]
    
    var animatorIsBusy = false
    var introAnimationLoaded = false
    var returnWithDismiss = false
    
    let cornerRadius: CGFloat = 22.0
    let inactiveOffset: CGFloat = 80
    
    let mainTableMaxY: CGFloat = 55
    var mainTableMinimized = false
    let mainTableMaximizedHeight: CGFloat = UIScreen.main.bounds.height - 55
    let mainTableMinimizedHeight: CGFloat = 95
    
    let backTableOffset: CGFloat = 25
    
    var mainScreenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    var mainScreenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Property Observer
    var messageBadge: Int = 0 {
        didSet {
            self.tabBarItem.badgeValue = messageBadge != 0 ? "\(messageBadge)" : nil
        }
    }
    
    // Animating Blur Radius
    var blurAnimator: UIViewPropertyAnimator? {
        didSet {
            print("blurAnimator didSet")
        }
    }
    
    var scrollAnimator: UIViewPropertyAnimator? {
        didSet {
            print("scrollAnimator didSet")
        }
    }
    
    // MARK: - IBAction: Methods connected to UI
    // ----------------------------------------
    @IBAction func tapToMinimize(_ sender: UITapGestureRecognizer) {
        if self.mainTable.frame.height > mainTableMinimizedHeight {
            self.animatorIsBusy = true
            self.mainTableMinimized = false
            miniMizeTableView()
        } else {
            self.animatorIsBusy = true
            self.mainTableMinimized = true
            maxiMizeTableView()
        }
    }
    
    // MARK: - Functions, Database & Animation
    // ----------------------------------------
    func maxiMizeTableView() {
        self.blurAnimator?.stopAnimation(true)
        self.scrollAnimator?.stopAnimation(true)
        
        setBlurEffectWithAnimator(on: self.mainTable, duration: 0.42, startBlur: true, curve: .easeIn)
        self.blurAnimator?.startAnimation()
        
        self.mainTable.reloadData()
        self.mainTable.setNeedsDisplay()
        
        UIView.animate(withDuration: 0.45, delay: 0.045, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
            self.enterMainTable()
        }, completion: { (true) in
            self.mainTableMinimized = false
            self.animatorIsBusy = false
            
            self.backTable.reloadData()
            self.backTable.setNeedsDisplay()
            
            self.setBlurEffectWithAnimator(on: self.mainTable, startBlur: false)
            self.setScrollEffectWithAnimator(on: self.mainTable, reversed: false)
        })
    }
    
    func miniMizeTableView() {
        self.blurAnimator?.stopAnimation(true)
        self.scrollAnimator?.stopAnimation(true)
        
        setBlurEffectWithAnimator(on: self.mainTable, duration: 0.45, startBlur: false, curve: .easeIn)
        self.blurAnimator?.startAnimation()
        
        self.backTable.reloadData()
        self.backTable.setNeedsDisplay()
        
        UIView.animate(withDuration: 0.45, delay: 0.010, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
            
            self.enterBackTable()
            
        }, completion: { (true) in
            self.mainTableMinimized = true
            self.animatorIsBusy = false
            
            self.setScrollEffectWithAnimator(on: self.backTable, reversed: true)
        })
    }
    
    // THIS NEEDS TO BE FIXED
    // ----------------------
    func setMainTable() {
        self.mainTable.frame = CGRect(x: 0, y: self.mainTableMaxY, width: self.mainScreenWidth, height: self.mainScreenHeight - self.mainTableMaxY)
        self.mainTable.frame = self.mainTable.frame.offsetBy(dx: 0, dy: inactiveOffset)
        self.mainTable.layer.cornerRadius = cornerRadius
        // Specify which corners to round = [ upper left , upper right ]
        self.mainTable.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.mainTable.contentInset.bottom = 60
    }
    
    func setBackTable() {
        self.backTable.frame = UIScreen.main.bounds
        self.backTable.alpha = 0.70
        self.backTable.layer.cornerRadius = 0
        // Specify which corners to round = [ upper left , upper right ]
        self.backTable.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.backTable.contentInset.top = 35
        self.backTable.contentInset.bottom = 100
        self.backTable.contentOffset.y = 35
    }
    
    func hideBackTable() {
        self.backTable.layer.cornerRadius = self.cornerRadius
        self.backTable.alpha = 0.35
        self.backTable.transform = CGAffineTransform(scaleX: 0.89, y: 0.89)
        // self.backTable.isScrollEnabled = false
        self.backTable.layoutIfNeeded()
    }
    
    func midBackTable() {
        self.backTable.layer.cornerRadius = self.cornerRadius * 0.8
        self.backTable.alpha = 0.45
        self.backTable.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        // self.backTable.isScrollEnabled = false
        self.backTable.layoutIfNeeded()
    }
    
    func showBackTable() {
        self.backTable.layer.cornerRadius = 0
        self.backTable.alpha = 1.0
        self.backTable.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.backTable.isScrollEnabled = true
        self.backTable.layoutIfNeeded()
    }
    
    func hideMainTable() {
        self.mainTable.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.mainTable.frame = CGRect(x: 0, y: self.mainScreenHeight - self.mainTableMinimizedHeight, width: self.mainScreenWidth, height: self.mainTableMinimizedHeight)
        self.mainTable.layer.cornerRadius = 0
        self.mainTable.isScrollEnabled = false
        self.mainTable.scrollToRow(at: IndexPath(row: 0, section: 0), at:.top, animated: true)
        self.mainTable.layoutIfNeeded()
    }
    
    func showMainTable() {
        self.mainTable.frame = CGRect(x: 0, y: self.mainTableMaxY, width: self.mainScreenWidth, height: self.mainScreenHeight - self.mainTableMaxY)
        self.mainTable.layer.cornerRadius = self.cornerRadius
        self.mainTable.isScrollEnabled = true
    }
    
    func enterMainTable() {
        self.hideBackTable()
        self.showMainTable()
    }
    
    func enterBackTable() {
        self.hideMainTable()
        self.showBackTable()
    }
    // THIS NEEDS TO BE FIXED
    // ----------------------
    
    // Set User Object
    func getUserSettings() {
        if let user = LocalService.instance.getUser() {
            self.user = user
        }
    }
    
    // Check if image is loaded for RequestUserCell
    func lastMainCellLayout() {
        for cell in mainTable.visibleCells {
            if cell is RequestUserCell {
                if let customCell = cell as? RequestUserCell {
                    if customCell.cellImageLoaded != true {
                        self.mainTable.reloadData()
                    }
                }
            }
        }
    }
    
    // Check if image is loaded for MessageTableViewCell
    func lastBackCellLayout() {
        for cell in backTable.visibleCells {
            if cell is MessageTableViewCell {
                if let backCells = cell as? MessageTableViewCell {
                    if backCells.cellImageLoaded != true {
                        self.backTable.reloadData()
                    }
                }
            }
        }
    }
    
    func setScrollEffectWithAnimator(on view: UIView, reversed: Bool = false, curve: UIViewAnimationCurve = .easeOut) {
        scrollAnimator = UIViewPropertyAnimator(duration: 0.8, curve: curve) {
            if reversed {
                self.backTable.layer.cornerRadius = 22.0
                self.backTable.alpha = 0.4
                self.backTable.transform = CGAffineTransform(translationX: 0, y: 35)
                self.backTable.layoutIfNeeded()
            } else {
                self.backTable.layer.cornerRadius = 9
                self.backTable.alpha = 0.7
                self.backTable.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
                self.backTable.layoutIfNeeded()
                self.mainTable.transform = CGAffineTransform(translationX: 0, y: 25)
            }
        }
    }
    
    func setBlurEffectWithAnimator(on view: UIView, duration: TimeInterval = 0.45, startBlur: Bool = false, curve: UIViewAnimationCurve = .easeOut) {
        removeBlurEffect(on: view)
        
        let blurEffect = startBlur ? UIBlurEffect(style: .light) : nil
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = view.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.isUserInteractionEnabled = false
        
        view.addSubview(effectView)
        
        blurAnimator = UIViewPropertyAnimator(duration: duration, curve: curve) {
            // this is the main trick, animating between a blur effect and nil is how you can manipulate blur radius
            effectView.effect = startBlur ? nil : UIBlurEffect(style: .light)
        }
    }
    
    func setBlurEffect(on view: UIView) {
        var effectView: UIVisualEffectView?
        for subview in view.subviews {
            if subview is UIVisualEffectView {
                if let visualView = subview as? UIVisualEffectView {
                    effectView = visualView
                    effectView?.isUserInteractionEnabled = false
                }
            }
        }
        if effectView == nil {
            effectView = UIVisualEffectView(frame: view.bounds)
            effectView?.isUserInteractionEnabled = false
        }
        effectView?.effect = UIBlurEffect(style: .light)
        view.addSubview(effectView!)
    }
    
    func removeBlurEffect(on view: UIView) {
        for subview in view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
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
    
    // MARK: - Observer, Firebase Database Functions
    // ----------------------------------------
    func observeRequests(_ exemptIDs: [String] = []) {
        if let UID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            DataService.instance.REF_REQUESTS.child("private").child(UID).child("requests").observe(.value, with: { (snapshot) in
                
                if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                    self.totalRequests = snapValue.keys.count
                    
                    self.requests.removeAll()
                    
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
    
    // MARK: - Observer, Firebase Database Functions
    // ----------------------------------------
    func observeRequestsOnce(_ exemptIDs: [String] = []) {
        if let UID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            DataService.instance.REF_REQUESTS.child("private").child(UID).child("requests").observeSingleEvent(of: .value, with: { snapshot in
                
                if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                    self.totalRequests = snapValue.keys.count
                    self.requests.removeAll()
                    
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
            requestAmount: requestSnap["requestAmount"] as! Int,
            requestStatus: requestSnap["requestStatus"] as! String,
            requestCategory: requestSnap["requestCategory"] as! String,
            requestREF: userRef)
        self.observeUser(request: request, userRef: userRef)
    }
    
    func observeUser(request: Request, userRef: DatabaseReference) {
        print("observeUser")
        
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
                    self.mainTable.insertRows(at: [indexPath], with: .automatic)
                } else {
                    self.requests.append(requestVal)
                }
                self.mainTable.reloadData()
                self.messageBadge += 1
            })
        } else {
            self.mainTable.reloadData()
        }
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
                    
                    self.backTable.reloadData()
                }
            })
        } else {
            self.backTable.reloadData()
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
    
    
    func removeDatabaseSubValue() {
        if let UID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            let privateRequest = DataService.instance.REF_REQUESTS.child("private").child(UID).child("requests")
            let publicRequest = DataService.instance.REF_REQUESTS.child("public").child(UID)
            publicRequest.observeSingleEvent(of: .value, with: { snapshot in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    
                    for snap in snapshot {
                        if let snapValue = snap.value as? [String: AnyObject] {
                            for (key,val) in snapValue {
                                if key == "familyID" || key == "nannyID" {
                                    if let remoteUID = val as? String, remoteUID != UID {
                                        publicRequest.child(snap.key).child("userID").setValue(remoteUID)
                                    }
                                }
                                if key == "requestStatus", val as? String != "pending" {
                                    if let requestValue = val as? String {
                                        privateRequest.child(snap.key).child(key).setValue(requestValue)
                                        publicRequest.child(snap.key).removeValue()
                                    }
                                } else {
                                    DataService.instance.copyValuesFromRefToRef(fromReference: publicRequest, toReference: privateRequest)
                                }
                                // self.requests.removeAll()
                                self.mainTable.reloadData()
                            }
                            
                        }
                    }
                }
                
            })
        }
    }
    
    
}

// MARK: - ViewDidLoad, ViewWillLoad etc...
// ----------------------------------------
extension MessageViewController {
    override func viewDidLoad() {
        print("-- viewDidLoad")
        super.viewDidLoad()
        
        setMainTable()
        setBackTable()
        
        self.setBlurEffectWithAnimator(on: self.mainTable, startBlur: true)
        
        self.mainTable.delegate = self
        self.mainTable.dataSource = self
        
        self.backTable.delegate = self
        self.backTable.dataSource = self
        
        getUserSettings()
        
        observeRequests()
        observeMessages()
        
        revealingSplashAnimation(self.view, type: SplashAnimationType.swingAndZoomOut, completion: {
            
            self.midBackTable()
            
            self.setBlurEffectWithAnimator(on: self.mainTable, duration: 0.45, startBlur: true, curve: .easeIn)
            self.mainTable.reloadData()
            
            UIView.animate(withDuration: 0.51, delay: 0.151, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.95, options: .curveEaseIn, animations: {
                print("- revealingSplashAnimation (completion:)")
                self.blurAnimator?.startAnimation()
                
                // backTableView
                self.hideBackTable()
                
                self.mainTable.frame = self.mainTable.frame.offsetBy(dx: 0, dy: -self.inactiveOffset)
                self.mainTable.layoutIfNeeded()
                
            }, completion: { (true) in
                self.introAnimationLoaded = true
                self.animatorIsBusy = false
                
                self.backTable.reloadData()
                self.backTable.setNeedsDisplay()
                
                self.setBlurEffectWithAnimator(on: self.mainTable, startBlur: false)
                self.setScrollEffectWithAnimator(on: self.mainTable, reversed: false)
            })
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("- viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("- viewDidAppear")
        
        self.animatorIsBusy = false
        self.mainTable.isUserInteractionEnabled = true
        
        self.removeDatabaseSubValue()
        
        if !self.returnWithDismiss {
            if self.introAnimationLoaded {
                if !self.mainTableMinimized {
                    
                    // self.showBackTable()
                    self.midBackTable()
                    self.mainTable.frame = self.mainTable.frame.offsetBy(dx: 0, dy: inactiveOffset)
                    self.setBlurEffect(on: self.mainTable)
                    
                    self.maxiMizeTableView()
                    self.mainTable.layoutIfNeeded()
                } else {
                    animateCells(in: self.backTable, true)
                    // animateCells3d(in: self.backTable, true)
                    
                    // tableView
                    self.mainTable.layer.cornerRadius = 0
                    self.mainTable.frame = CGRect(x: 0, y: self.mainScreenHeight - self.mainTableMinimizedHeight, width: self.mainScreenWidth, height: self.mainTableMinimizedHeight)
                }
            } else {
                let tab = self.tabBarController?.tabBar as! FrostyTabBar
                tab.setEffect(blurEffect: .extraLight)
            }
            hapticButton(.heavy, lowPowerModeDisabled)
        } else {
            self.returnWithDismiss = false
            self.mainTable.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        print("- viewDidLayoutSubviews")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("- viewWillDisappear")
        
        self.animatorIsBusy = true
        self.mainTable.isUserInteractionEnabled = false
        self.scrollAnimator?.stopAnimation(true)
        self.blurAnimator?.stopAnimation(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("- viewDidDisappear")
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
    
    func returnScrollValue(with scrollOffset: CGFloat, valueOffset: CGFloat) -> CGFloat {
        let value = (((scrollOffset / 100)) / -1) - valueOffset
        
        let valueMin = value < 0.0 ? 0.0 : value
        let valueMax = value > 1.0 ? 1.0 : value
        
        let result = value < valueMin ? valueMin : valueMax
        
        return result
    }
    
    // Search for: scrollViewDidScroll UIVisualEffect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if backTable == scrollView {
            if blurAnimator != nil && scrollAnimator != nil {
                if !animatorIsBusy {
                    if scrollView.contentOffset.y < -25 {
                        if scrollAnimator?.state != .stopped {
                            // print("scrollAnimator.state is not stopped")
                            let scrollResult = returnScrollValue(with: scrollView.contentOffset.y, valueOffset: 0.50)
                            scrollAnimator?.fractionComplete = scrollResult
                            print(scrollResult)
                        }
                    }
                    
                }
            }
        }
        
        if mainTable == scrollView {
            if blurAnimator != nil && scrollAnimator != nil {
                if !mainTableMinimized || !animatorIsBusy {
                    
                    if scrollView.contentOffset.y < -15 {
                        let blurResult = returnScrollValue(with: scrollView.contentOffset.y, valueOffset: 0.25)
                        blurAnimator?.fractionComplete = blurResult
                        
                        if scrollAnimator?.state != .stopped {
                            // print("scrollAnimator.state is not stopped")
                            let scrollResult = returnScrollValue(with: scrollView.contentOffset.y, valueOffset: 0.15)
                            scrollAnimator?.fractionComplete = scrollResult
                        }
                    }
                    
                }
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("scrollViewWillEndDragging: \(velocity)")
        
        if scrollView.contentOffset.y < -80  {
            if scrollView == mainTable {
                self.miniMizeTableView()
            } else {
                self.maxiMizeTableView()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        print("decelerate: \(decelerate)")
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if mainTable == scrollView {
            print("scrollViewWillBeginDecelerating")
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        if scrollView.contentOffset.y >= -80 {
            print(scrollView.contentOffset.y)
            if scrollAnimator?.state != .stopped {
                
                if scrollView.contentOffset.y <= 0 {
                    self.mainTable.contentOffset = .zero
                    // self.backTable.contentOffset = CGPoint(x: 0, y: 35)
                }
            }
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
        
        if tableView == mainTable {
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
        }
        
        if tableView == backTable {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as? MessageTableViewCell {
                cell.setupView(with: messages[indexPath.row])
                return cell
            }
        }
        return returnCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let backHeight: CGFloat = 80
        let mainHeight = (indexPath.row < self.heightForRow.count) ? self.heightForRow[indexPath.row] : 80
        return tableView == mainTable ? mainHeight : backHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView == mainTable && indexPath.row >= 2 || tableView == backTable
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == mainTable ? requests.count + 2 : messages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.mainTable {
            guard let requestDetail = storyboard?.instantiateViewController(withIdentifier: "RequestDetail") as? RequestDetailVC else { return
            }
            
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell is RequestUserCell {
                    if let requestCell = cell as? RequestUserCell {
                        
                        let request = requests[indexPath.row - 2]
                        let adminUser = self.user!
                        let guestUser = User(userUID: request.userID, imageName: request.imageName, firstName: request.firstName)
                        
                        requestDetail.initWith(adminUser: adminUser, guestUser: guestUser, viewRect: mainTable.frame)
                        self.returnWithDismiss = true
                        present(requestDetail, animated: false)
                        
                        if !requestCell.hasSelected {
                            self.messageBadge = (messageBadge > 0) ? (messageBadge - 1) : 0
                            requestCell.hasSelected = true
                        }
                    }
                }
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if tableView == self.backTable {
            tableView.deselectRow(at: indexPath, animated: true)
            guard let messageDetailVC = storyboard?.instantiateViewController(withIdentifier: "MessageDetail") as? MessageDetailVC else {
                return
            }

            if let remoteFrom = messages[indexPath.row]._fromUser {
                if let user = self.user {
                    if let remoteUser = remoteFrom.userUID != user.userUID ? remoteFrom : messages[indexPath.row]._toUser {
                        
                        print(remoteFrom)
                        print(remoteUser)
                        
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
            
            if tableView == self.mainTable {
                self.requests.remove(at: indexPath.row - 2)
                
                self.mainTable.isEditing = false
                self.mainTable.deleteRows(at: [indexPath], with: .fade)
            } else {
                self.messages.remove(at: indexPath.row)
                
                self.backTable.isEditing = false
                self.backTable.deleteRows(at: [indexPath], with: .fade)
            }
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

