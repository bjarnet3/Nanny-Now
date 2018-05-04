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
    var heightForRow:[CGFloat] = [40,180,80]
    
    var animatorIsBusy = false
    var introAnimationLoaded = false
  
    let cornerRadius: CGFloat = 22.0
    let inactiveOffset: CGFloat = 80
    
    let mainTableMaxY: CGFloat = 55
    var mainTableMinimized = false
    let mainTableMaximizedHeight: CGFloat = UIScreen.main.bounds.height - 55
    let mainTableMinimizedHeight: CGFloat = 105
    
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
    func setMainTable() {
        self.mainTable.frame = CGRect(x: 0, y: self.mainTableMaxY, width: self.mainScreenWidth, height: self.mainScreenHeight - self.mainTableMaxY)
        self.mainTable.frame = self.mainTable.frame.offsetBy(dx: 0, dy: inactiveOffset)
        self.mainTable.layer.cornerRadius = cornerRadius
        // Specify which corners to round = [ upper left , upper right ]
        self.mainTable.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setBackTable() {
        self.backTable.frame = CGRect(x: self.backTableOffset/2, y: self.backTableOffset, width: self.mainScreenWidth - self.backTableOffset, height: self.mainScreenHeight - self.backTableOffset)
        self.backTable.alpha = 0.95
        self.backTable.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        self.backTable.layer.cornerRadius = 0
        // Specify which corners to round = [ upper left , upper right ]
        self.backTable.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func showMainTable() {
        
        // backTableView
        self.backTable.frame = CGRect(x: self.backTableOffset/2, y: self.backTableOffset, width: self.mainScreenWidth - self.backTableOffset, height: self.mainScreenHeight - self.backTableOffset)
        self.backTable.layer.cornerRadius = self.cornerRadius
        self.backTable.alpha = 0.40
        self.backTable.isScrollEnabled = false
        
        // tableView
        self.mainTable.frame = CGRect(x: 0, y: self.mainTableMaxY, width: self.mainScreenWidth, height: self.mainScreenHeight - self.mainTableMaxY)
        self.mainTable.layer.cornerRadius = self.cornerRadius
        self.mainTable.isScrollEnabled = true
        
    }
    
    func showBackTable() {
        
        // backTableView
        self.backTable.frame = UIScreen.main.bounds
        self.backTable.layer.cornerRadius = 0
        self.backTable.alpha = 1.00
        self.backTable.isScrollEnabled = true
        self.backTable.layoutIfNeeded()
        
        // tableView
        self.mainTable.frame = CGRect(x: 0, y: self.mainScreenHeight - self.mainTableMinimizedHeight, width: self.mainScreenWidth, height: self.mainTableMinimizedHeight)
        self.mainTable.layer.cornerRadius = 0
        self.mainTable.isScrollEnabled = false
        self.mainTable.scrollToRow(at: IndexPath(row: 0, section: 0), at:.top, animated: true)
        self.mainTable.layoutIfNeeded()
        
    }
    
    func miniMizeTableView() {
        self.blurAnimator?.stopAnimation(true)
        self.scrollAnimator?.stopAnimation(true)
        
        setBlurEffectWithAnimator(on: self.mainTable, duration: 0.45, startBlur: false, curve: .easeIn)
        
        self.blurAnimator?.startAnimation()
        // self.scrollAnimator?.finishAnimation(at: .end)
        UIView.animate(withDuration: 0.45, delay: 0.010, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
            
            self.showBackTable()
            
        }, completion: { (true) in
            
            self.mainTableMinimized = true
            self.animatorIsBusy = false
            
            self.view.setNeedsDisplay()
        })
    }
    
    func maxiMizeTableView() {
        self.blurAnimator?.stopAnimation(true)
        self.scrollAnimator?.stopAnimation(true)
        
        // setBlurEffectWithAnimator(on: self.mainTable, startBlur: true, curve: .easeIn)
        setBlurEffectWithAnimator(on: self.mainTable, duration: 0.42, startBlur: true, curve: .easeIn)
        
        self.blurAnimator?.startAnimation()
        
        UIView.animate(withDuration: 0.45, delay: 0.045, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
            
            self.showMainTable()
            
        }, completion: { (true) in
            self.mainTableMinimized = false
            self.animatorIsBusy = false
            
            self.view.setNeedsDisplay()
            
            self.setBlurEffectWithAnimator(on: self.mainTable, startBlur: false)
            self.setScrollEffectWithAnimator(on: self.mainTable, reversed: false)
        })
    }
    
    // Set User Object
    func getUserSettings() {
        if let user = LocalService.instance.getUser() {
            self.user = user
        }
    }
    
    // Check if image is loaded for MessageStandardCell
    func lastCellLayout() {
        for cell in mainTable.visibleCells {
            if cell is RequestUserCell {
                if let customCell = cell as? RequestUserCell {
                    if customCell.cellImageLoaded != true {
                        print("standardCellImage is not loaded - reloadData")
                        self.mainTable.reloadData()
                    }
                }
            }
        }
    }
    
    func setScrollEffectWithAnimator(on view: UIView, reversed: Bool = false, curve: UIViewAnimationCurve = .easeOut) {
        scrollAnimator = UIViewPropertyAnimator(duration: 0.5, curve: curve) {
            if reversed {
                self.showBackTable()
            } else {
                self.showMainTable()
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
        for view in self.mainTable.subviews {
            if view is UIVisualEffectView {
                if let visualView = view as? UIVisualEffectView {
                    effectView?.isUserInteractionEnabled = false
                    effectView = visualView
                }
            }
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
            DataService.instance.REF_MESSAGES.child("private").child(UID).child("last").observe(.value, with: { (snapshot) in
                let remoteID = snapshot.key
                
                if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                    self.totalMessages = snapValue.keys.count
                    
                    print(snapValue.keys.count)
                    
                    if !exemptIDs.contains(remoteID) {
                        self.messages.removeAll()
                        
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
            DataService.instance.REF_REQUESTS.child("private").child(UID).child("users").observe(.value, with: { (snapshot) in
                let remoteID = snapshot.key
                
                if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                    self.totalRequests = snapValue.keys.count
                    print("snapshot count: \(snapValue.keys.count)")
                    print("------------------")
                    
                    if !exemptIDs.contains(remoteID) {
                        self.requests.removeAll()
                        
                        for (key,value) in snapValue {
                            if let snapRequest = value as? [String:AnyObject] {
                                self.fetchRequestObserver(snapRequest, remoteUID: key)
                            }
                        }
                    }
                }
                
            })
        }
    }
    
    // TODO: observeChildAdded : observeChildRemoved
    func observeChildAdded(_ exemptIDs: [String] = []) {
        if let UID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            DataService.instance.REF_REQUESTS.child("private").child(UID).child("users").observe(.childAdded, with: { (snapshot) in
                let remoteID = snapshot.key
                if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                    self.totalRequests = snapValue.keys.count
                    if !exemptIDs.contains(remoteID) {
                        for (index,_) in snapValue.enumerated() {
                            
                            self.fetchRequestObserver(snapValue, remoteUID: remoteID)
                            // Print first object
                            if index == 0 { print("first") }
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
            messageID: messageSnap["messageID"] as! String,
            message:  messageSnap["message"] as! String,
            messageTime:  messageSnap["messageTime"] as! String,
            highlighted:  messageSnap["highlighted"] as! Bool)
        self.observeUser(with: message, userRef: userREF)
    }
    
    
    func fetchRequestObserver(_ requestSnap: Dictionary<String, AnyObject>, remoteUID: String) {
        let userREF = DataService.instance.REF_USERS_PRIVATE.child(remoteUID)
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
            requestREF: userREF)
        self.observeUser(request: request, userRef: userREF)
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
                            }
                        }
                    }
                }
                
                // self.requests.sort(by: { $0.timeRequested > $1.timeRequested })
                if let index = self.requests.index(where: { $0.timeRequested >= requestVal.timeRequested }) {
                    self.requests.insert(requestVal, at: index)
                    
                    let indexPath = IndexPath(row: index.advanced(by: 2), section: 0)
                    let updateIndexPath = IndexPath(row: index.advanced(by: 3), section: 0)
                    
                    self.mainTable.insertRows(at: [indexPath], with: .automatic)
                    self.mainTable.reloadRows(at: [updateIndexPath], with: .automatic)
                } else {
                    self.requests.append(requestVal)
                    self.mainTable.reloadData()
                }
                self.messageBadge += 1
                if self.requests.count == self.totalRequests - 1 {
                    print("observeUser last request")
                    self.mainTable.reloadData()
                }
            })
        } else {
            print("requests.count and totalRequests unsyncronized")
            self.mainTable.reloadData()
            
            print("requests.count : \(self.requests.count)")
            print("totalRequests count: \(self.totalRequests)")
        }
    }
    
    func observeUser(with message: Message, userRef: DatabaseReference) {
        if self.messages.count < self.totalMessages {
            
            userRef.observeSingleEvent(of: .value, with: { snapshot in
                
                if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                    for (key, val) in snapValue {
                        
                        if key == "imageUrl" {
                            if let imageValue = val as? String {
                                var message = message
                                
                                message.setImageUrl(imageURL: imageValue)
                                self.messages.append(message)
                                
                            }
                        }
                        
                    }
                }
                /*
                
                // self.requests.sort(by: { $0.timeRequested > $1.timeRequested })
                if let index = self.requests.index(where: { $0.timeRequested >= requestVal.timeRequested }) {
                    self.requests.insert(requestVal, at: index)
                    
                    let indexPath = IndexPath(row: index.advanced(by: 2), section: 0)
                    let updateIndexPath = IndexPath(row: index.advanced(by: 3), section: 0)
                    
                    self.mainTable.insertRows(at: [indexPath], with: .automatic)
                    self.mainTable.reloadRows(at: [updateIndexPath], with: .automatic)
                } else {
                    self.requests.append(requestVal)
                    self.mainTable.reloadData()
                }
                self.messageBadge += 1
                if self.requests.count == self.totalRequests - 1 {
                    print("observeUser last request")
                    self.mainTable.reloadData()
                }
                
                */
            })

        } else {
            print("requests.count and totalRequests unsyncronized")
            self.mainTable.reloadData()
            
            print("requests.count : \(self.requests.count)")
            print("totalRequests count: \(self.totalRequests)")
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
            
            self.setBlurEffectWithAnimator(on: self.mainTable, duration: 0.45, startBlur: true, curve: .easeIn)
            
            UIView.animate(withDuration: 0.51, delay: 0.151, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.95, options: .curveEaseIn, animations: {
                print("- revealingSplashAnimation (completion:)")
                self.blurAnimator?.startAnimation()
                
                self.mainTable.frame = self.mainTable.frame.offsetBy(dx: 0, dy: -self.inactiveOffset)
                self.mainTable.layoutIfNeeded()
                // self.tableView.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
                
                self.backTable.alpha = 0.4
                self.backTable.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
                self.backTable.layer.cornerRadius = self.cornerRadius
                self.backTable.layoutIfNeeded()
                
            }, completion: { (true) in
                self.introAnimationLoaded = true
                self.animatorIsBusy = false
                
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
        
        if self.introAnimationLoaded {
            
            if !self.mainTableMinimized {
                
                self.mainTable.frame = self.mainTable.frame.offsetBy(dx: 0, dy: inactiveOffset)
                self.setBlurEffect(on: self.mainTable)
                self.maxiMizeTableView()
                self.mainTable.layoutIfNeeded()
                
            } else {
                
                // tableView
                self.mainTable.layer.cornerRadius = 0
                self.mainTable.frame = CGRect(x: 0, y: self.mainScreenHeight - self.mainTableMinimizedHeight, width: self.mainScreenWidth, height: self.mainTableMinimizedHeight)
                
            }
        } else {
            let tab = self.tabBarController?.tabBar as! FrostyTabBar
            tab.setEffect(blurEffect: .extraLight)
        }
        hapticButton(.heavy, lowPowerModeDisabled)

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
        
        if !self.mainTableMinimized {
            self.backTable.alpha = 0.4
            self.backTable.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.backTable.layer.cornerRadius = 0
        }
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
        if mainTable == scrollView {
            if scrollView.contentOffset.y < -15 {
                if blurAnimator != nil && scrollAnimator != nil {
                    
                    if !mainTableMinimized || !animatorIsBusy {
                        
                        let blurResult = returnScrollValue(with: scrollView.contentOffset.y, valueOffset: 0.25)
                        blurAnimator?.fractionComplete = blurResult
                        
                        if scrollAnimator?.state != .stopped {
                            let scrollResult = returnScrollValue(with: scrollView.contentOffset.y, valueOffset: 0)
                            scrollAnimator?.fractionComplete = scrollResult / 5
                        }
                    }
                }
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("scrollViewWillEndDragging: \(velocity)")
        
        if mainTable == scrollView {
            if scrollView.contentOffset.y < -80  {
                self.miniMizeTableView()
                
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        print("decelerate: \(decelerate)")
        
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDecelerating")
        if mainTable == scrollView {
            // self.scrollAnimator?.stopAnimation(true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        if mainTable == scrollView {
            if scrollAnimator?.state != .stopped {
                self.scrollAnimator?.startAnimation()
            }
        }
    }
}

// MARK: - TableView, Delegate & Datasource
// ----------------------------------------
extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var returnCell: UITableViewCell?
        
        if tableView == mainTable {
            
            if indexPath.row == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "RequestHeaderCell", for: indexPath) as? RequestHeaderCell {
                    
                    returnCell = cell
                }
            } else if indexPath.row == 1 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "RequestBodyCell", for: indexPath) as? RequestBodyCell {
                    cell.updateView(user: self.user!)
                    cell.layoutIfNeeded()
                    
                    returnCell = cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "RequestUserCell", for: indexPath) as? RequestUserCell {
                    cell.updateView(request: requests[indexPath.row - 2], animated: true)
                    
                    // https://stackoverflow.com/questions/30066625/uiimageview-in-table-view-not-showing-until-clicked-on-or-device-is-roatated
                    
                    returnCell = cell
                }
            }
        }
        
        if tableView == backTable {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as? MessageTableViewCell {
                cell.loadData(for: messages[indexPath.row])
                returnCell = cell
            }
        }
        return returnCell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = (indexPath.row < self.heightForRow.count) ? self.heightForRow[indexPath.row] : 80
        return height // self.heights?[indexPath.row] ?? 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == mainTable ? requests.count + 2 : messages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.mainTable {
            guard let messageDetailVC = storyboard?.instantiateViewController(withIdentifier: "MessageDetailVC") as? MessageDetailVC else { return
            }
            
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell is RequestUserCell {
                    if let messageCell = cell as? RequestUserCell {
                        
                        let request = requests[indexPath.row - 2]
                        let adminUser = self.user!
                        let guestUser = User(userUID: request.userID, imageName: request.imageName, firstName: request.firstName)
                        
                        messageDetailVC.initWith(adminUser: adminUser, guestUser: guestUser)
                        present(messageDetailVC, animated: false)
                        
                        if !messageCell.hasSelected {
                            print("hasSelected is false")
                            self.messageBadge = (messageBadge > 0) ? (messageBadge - 1) : 0
                            messageCell.hasSelected = true
                        } else {
                            print("hasSelected is true")
                        }
                    }
                }
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if tableView == self.backTable {
            guard let messageAll = storyboard?.instantiateViewController(withIdentifier: "MessageTableViewCell") as? MessageTableViewCell else {
                return
            }
            if let cell = tableView.cellForRow(at: indexPath) {
                print("Shit hun var fitt")
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}

