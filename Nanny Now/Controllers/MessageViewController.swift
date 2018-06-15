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
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainTable: CustomTableView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backTable: CustomTableView!
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var backLabel: UILabel!
    
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    var user: User?
    
    var requests = [Request]()
    var messages = [Message]()
    
    var totalRequests: Int = 0
    var totalMessages: Int = 0
    
    var lastRowSelected: IndexPath?
    var heightForRow:[CGFloat] = [5,170,80]
    
    var animatorIsBusy = false
    var introAnimationLoaded = false
    var returnWithDismiss = false
    
    let cornerRadius: CGFloat = 22.0
    let inactiveOffset: CGFloat = 80
    
    let mainTableMaxY: CGFloat = 85
    var mainTableMinimized = false
    let mainTableMaximizedHeight: CGFloat = UIScreen.main.bounds.height - 85
    let mainTableMinimizedHeight: CGFloat = 97
    
    let backTableOffset: CGFloat = 0
    let backTableMaxY: CGFloat = 22
    let backTableMaximizedHeight: CGFloat = UIScreen.main.bounds.height - 22
    let backTableMinimizedWidth: CGFloat = UIScreen.main.bounds.width - 22
    
    var mainScreenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    var mainScreenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Property Observer
    var pendingCount: Int = 0 {
        didSet {
            let secondCell = mainTable.cellForRow(at: IndexPath(row: 1, section: 0)) as? RequestBodyCell
            secondCell?.pendingCount = pendingCount
        }
    }
    
    var acceptedCount: Int = 0 {
        didSet {
            let secondCell = mainTable.cellForRow(at: IndexPath(row: 1, section: 0)) as? RequestBodyCell
            secondCell?.acceptedCount = acceptedCount
        }
    }
    
    var completeCount: Int = 0 {
        didSet {
            let secondCell = mainTable.cellForRow(at: IndexPath(row: 1, section: 0)) as? RequestBodyCell
            secondCell?.completeCount = completeCount
        }
    }
        
    var rejectedCount: Int = 0 {
        didSet {
            let secondCell = mainTable.cellForRow(at: IndexPath(row: 1, section: 0)) as? RequestBodyCell
            secondCell?.rejectedCount = rejectedCount
        }
    }
    
    var runningCount: Int = 0 {
        didSet {
            print("running")
        }
    }
    
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
    
    func mainAction() {
        hapticButton(.selection)
        if mainTableMinimized {
            maxiMizeTableView()
            self.animatorIsBusy = true
            self.mainTableMinimized = false
            
            self.mainLabel.text = "• • •"
            self.backLabel.text = "◦ ◦ ◦"
        } else {
            miniMizeTableView()
            self.animatorIsBusy = true
            self.mainTableMinimized = true
            
            self.mainLabel.text = "◦ ◦ ◦"
            self.backLabel.text = "• • •"
        }
    }
    
    // MARK: - IBAction: Methods connected to UI
    // ----------------------------------------
    
    @IBAction func backAction(_ sender: Any) {
        mainAction()
    }
    
    @IBAction func mainAction(_ sender: Any) {
        mainAction()
    }
    
    // MARK: - Functions, Database & Animation
    // ----------------------------------------
    func maxiMizeTableView() {
        self.blurAnimator?.stopAnimation(true)
        self.scrollAnimator?.stopAnimation(true)

        self.blurAnimator?.startAnimation()
        
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
        self.animatorIsBusy = true
        
        self.blurAnimator?.stopAnimation(true)
        // self.scrollAnimator?.stopAnimation(true)
        self.scrollAnimator?.stopAnimation(true)
        // self.scrollAnimator?.pauseAnimation()
        
        // setBlurEffectWithAnimator(on: self.mainTable, duration: 0.45, startBlur: false, curve: .easeIn)
        // self.blurAnimator?.startAnimation()
        
        UIView.animate(withDuration: 0.45, delay: 0.010, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
            self.enterBackTable()
            
        }, completion: { (true) in
            self.mainTableMinimized = true
            self.animatorIsBusy = false
            
            self.setBlurEffectWithAnimator(on: self.mainTable, duration: 0.45, startBlur: true, curve: .easeOut)
            // self.setScrollEffectWithAnimator(on: self.backTable, reversed: true)
            self.setScrollEffectWithAnimator(on: self.backTable, reversed: true, curve: .easeOut)
            // self.scrollAnimator?.fractionComplete = 0.0
        })
    }
    
    // THIS NEEDS TO BE FIXED
    // ----------------------
    func setMainTable() {
        self.mainView.frame = CGRect(x: 0, y: self.mainTableMaxY, width: self.mainScreenWidth, height: self.mainScreenHeight - self.mainTableMaxY)
        // self.mainView.frame = self.mainView.frame.offsetBy(dx: 0, dy: inactiveOffset)
        self.mainView.layer.cornerRadius = self.cornerRadius
        // Specify which corners to round = [ upper left , upper right ]
        self.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.mainTable.contentInset.top = 5
        self.mainTable.contentInset.bottom = 50
    }
    
    func showMainTable() {
        self.mainView.frame = CGRect(x: 0, y: self.mainTableMaxY, width: self.mainScreenWidth, height: self.mainScreenHeight - self.mainTableMaxY)
        self.mainView.layer.cornerRadius = self.cornerRadius
        self.mainTable.isScrollEnabled = true
        
        self.mainLabel.text = "• • •"
        self.backLabel.text = "◦ ◦ ◦"
    }
    
    func hideMainTable() {
        self.mainView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.mainView.frame = CGRect(x: 0, y: self.mainScreenHeight - self.mainTableMinimizedHeight, width: self.mainScreenWidth, height: self.mainTableMinimizedHeight)
        self.mainView.layer.cornerRadius = 0
        
        self.mainTable.isScrollEnabled = false
        self.mainTable.scrollToRow(at: IndexPath(row: 0, section: 0), at:.top, animated: true)
        self.mainTable.layoutIfNeeded()
    }
    
    func setBackTable() {
        // self.backView.frame = CGRect(x: self.backTableOffset, y: self.backTableMaxY, width: self.mainScreenWidth - (self.backTableOffset * 2), height: self.mainScreenHeight - self.backTableMaxY)
        self.backView.frame = CGRect(x: 0, y: self.backTableMaxY, width: self.mainScreenWidth, height: self.mainScreenHeight - self.backTableMaxY)
        self.backView.alpha = 0.75
        self.backView.layer.cornerRadius = self.cornerRadius
        // Specify which corners to round = [ upper left , upper right ]
        self.backView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.backTable.contentInset.top = 20
        self.backTable.contentInset.bottom = 110
        // self.backTable.contentOffset.y = 35
    }
    
    func showBackTable() {
        self.backView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.backView.layer.cornerRadius = self.cornerRadius
        self.backView.alpha = 1.0
        
        self.backTable.isScrollEnabled = true
        self.backTable.layoutIfNeeded()
        
        self.mainLabel.text = "◦ ◦ ◦"
        self.backLabel.text = "• • •"
    }
    
    func midBackTable() {
        
        self.backView.transform = CGAffineTransform(scaleX: 0.97, y: 0.940)
        self.backView.layer.cornerRadius = self.cornerRadius
        self.backView.alpha = 0.65
        
        self.backTable.layoutIfNeeded()
    }
    
    func hideBackTable() {
        self.backView.transform = CGAffineTransform(scaleX: 0.94, y: 0.90)
        self.backView.layer.cornerRadius = self.cornerRadius
        self.backView.alpha = 0.45
        
        self.backTable.isScrollEnabled = false
        self.backTable.layoutIfNeeded()
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
        scrollAnimator = UIViewPropertyAnimator(duration: 0.6, curve: curve) {
            if reversed {
                self.showBackTable()
            } else {
                self.midBackTable()
                self.mainView.transform = CGAffineTransform(translationX: 0, y: 25)
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
    
    // MARK: - Observer, Firebase Database Functions
    // ----------------------------------------
    func observeRequestsOnce(_ exemptIDs: [String] = []) {
        if let UID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            DataService.instance.REF_REQUESTS.child("private").child(UID).child("requests").observeSingleEvent(of: .value, with: { snapshot in
                
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
    
    
    func updatePublicRequestValue() {
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
                
                self.mainView.frame = self.mainView.frame.offsetBy(dx: 0, dy: -self.inactiveOffset)
                self.mainView.layoutIfNeeded()
                
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
        
        self.updatePublicRequestValue()

        if !self.returnWithDismiss {
            if self.introAnimationLoaded {
                if !self.mainTableMinimized {
                    
                    // self.showBackTable()
                    self.midBackTable()
                    self.mainView.frame = self.mainView.frame.offsetBy(dx: 0, dy: inactiveOffset)
                    // self.setBlurEffect(on: self.mainTable)
                    
                    self.setBlurEffectWithAnimator(on: self.mainTable, duration: 0.40, startBlur: true, curve: .easeOut)
                    
                    self.maxiMizeTableView()
                    self.mainTable.layoutIfNeeded()
                } else {
                    animateCells(in: self.backTable, true)
                    
                    // tableView
                    self.mainView.layer.cornerRadius = 0
                    self.mainView.frame = CGRect(x: 0, y: self.mainScreenHeight - self.mainTableMinimizedHeight, width: self.mainScreenWidth, height: self.mainTableMinimizedHeight)
                    
                    // backTable - scrollEffect

                    self.mainTableMinimized = true
                    self.animatorIsBusy = false
                    self.setScrollEffectWithAnimator(on: self.backTable, reversed: true)
                    
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
                    if scrollView.contentOffset.y < -30 {
                        if scrollAnimator?.state != .stopped {
                            // print("scrollAnimator.state is not stopped")
                            let scrollResult = returnScrollValue(with: scrollView.contentOffset.y, valueOffset: 0.30)
                            scrollAnimator?.fractionComplete = scrollResult
                        }
                    }
                }
            }
        }
        
        if mainTable == scrollView {
            if blurAnimator != nil && scrollAnimator != nil {
                if !mainTableMinimized || !animatorIsBusy {
                    
                    if scrollView.contentOffset.y < -15 && scrollView.contentOffset.y > -125 {
                        let blurResult = returnScrollValue(with: scrollView.contentOffset.y, valueOffset: 0.30)
                        blurAnimator?.fractionComplete = blurResult
                        
                        if scrollAnimator?.state != .stopped {
                            // print("scrollAnimator.state is not stopped")
                            let scrollResult = returnScrollValue(with: scrollView.contentOffset.y, valueOffset: 0.30)
                            scrollAnimator?.fractionComplete = scrollResult
                        }
                    }
                    
                }
            }
        }
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("scrollViewWillEndDragging: \(velocity)")
        
        if scrollView.contentOffset.y <= -80 {
            if scrollAnimator?.state != .stopped {
                if scrollView == mainTable {
                    // self.mainAction()
                    self.miniMizeTableView()
                } else {
                    // self.mainAction()
                    self.maxiMizeTableView()
                }
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
        // Drag down
        if scrollView.contentOffset.y <= -80 {
            if scrollAnimator?.state != .stopped {
                if scrollView == mainTable {
                    miniMizeTableView()
                } else {
                    maxiMizeTableView()
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
                        
                        requestDetail.initWith(adminUser: adminUser, guestUser: guestUser, viewRect: mainTable.bounds)
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
            
            if tableView == self.mainTable {
                self.standardAlert(request: self.requests[indexPath.row - 2])
            }
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
