//
//  MessageDetailVC.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 04.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SwiftKeychainWrapper

private extension Selector {
    static let keyboardWillShow = #selector(MessageDetailVC.keyboardWillShow(notification:))
    static let keyboardWillDisappear = #selector(MessageDetailVC.keyboardWillDisappear(notification:))
}

public enum ActionType : String {
    case start = " START ▲", avbryt = "AVBRYT ▼", send = "SEND ▶︎", setup = "SETUP"
}

class MessageDetailVC: UIViewController {
    
    // MARK: - IBOutlet: Connection to Storyboard
    // ----------------------------------------
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var textFieldBackView: FrostyView!
    
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var textFieldBottom: NSLayoutConstraint!
    
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    private var user: User?
    private var remoteUser: User?
    
    private var messages = [Message]()
    private var totalMessages: Int = 0
    
    // MARK: - IBAction: Methods connected to UI
    // ----------------------------------------
    @IBAction func backButton(_ sender: Any) {
        self.view.endEditing(true)
        self.progressView.setProgress(0.0, animated: false)
        self.progressView.alpha = 1.0
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButton(_ sender: UIButton) {
        if sender.titleLabel?.text == "SEND ▶︎" {
            sendMessage()
        } else if sender.titleLabel?.text == "AVBRYT ▼" {
            self.view.endEditing(true)
        } else if sender.titleLabel?.text == " START ▲" {
            textField.becomeFirstResponder()
        }
    }
    
    @IBAction func touchedBackground(_ sender: Any) {
        // Dissmiss
        self.view.endEditing(true)
    }
    
    @IBAction func textFieldEnter(_ sender: UITextField) {
        if (sender.returnKeyType==UIReturnKeyType.send)
        {
            sendMessage()
        }
    }
    
    @IBAction func textFieldValue(_ sender: UITextField) {
        if (sender.text?.isEmpty)! {
            performAction(for: .avbryt)
        } else {
            performAction(for: .send, onlyButton: true)
        }
    }
    
    // MARK: - Functions, Database & Animation
    // ----------------------------------------
    func setupView(user: User, remoteUser: User) {
        self.user = user
        self.remoteUser = remoteUser
    }

    private func setUpKeyboard() {
        NotificationCenter.default.addObserver(self, selector: .keyboardWillShow, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: .keyboardWillDisappear, name: .UIKeyboardWillHide, object: nil)
    }
    
    private func removeKeyboard() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow , object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide , object: nil)
    }
    
    private func sendMessage() {
        if let messageText = textField.text {
            // Send Message to remoteUser
            // sendNotification(messageText: text)
            addMessage(messageText: messageText)
            // Remove text from Textfield
            self.textField.text = ""
            // Dismiss Keyboard
            self.textField.endEditing(true)
            // Set Title To START
            performAction(for: .start)
        }
    }
    
    private func performAction(for actionType: ActionType, onlyButton: Bool = false) {
        switch actionType {
        case .start:
            self.sendButton.setTitle(" START ▲", for: .normal)
            self.sendButton.setTitleColor(PINK_DARK_SHARP, for: .normal)
            self.sendButton.backgroundColor = WHITE_SOLID
            
            if !onlyButton {
                self.textField.textColor = WHITE_ALPHA
                self.textField.tintColor = WHITE_SOLID
                self.textField.backgroundColor = PINK_DARK_SHARP
                
                self.textField.layer.borderColor = WHITE_SOLID.cgColor
                self.textField.layer.borderWidth = 1.5
                
                if self.textField.text == "" {
                    self.textField.text = ". . . TAP TAP . . . "
                }
            }
        case .send:
            self.sendButton.setTitle("SEND ▶︎", for: .normal)
            self.sendButton.setTitleColor(WHITE_SOLID, for: .normal)
            self.sendButton.backgroundColor = AQUA_BLUE
        case .avbryt:
            self.sendButton.setTitle("AVBRYT ▼", for: .normal)
            self.sendButton.setTitleColor(WHITE_SOLID, for: .normal)
            self.sendButton.backgroundColor = PINK_DARK_SHARP
            
            if !onlyButton {
                self.textField.textColor = PINK_DARK_SHARP
                self.textField.tintColor = PINK_DARK_SHARP
                self.textField.backgroundColor = WHITE_ALPHA
                
                self.textField.layer.borderColor = LIGHT_GREY.cgColor
                self.textField.layer.borderWidth = 0.8
                
                if self.textField.text == ". . . TAP TAP . . . " {
                    self.textField.text = nil
                }
            }
        case .setup:
            self.sendButton.layer.borderWidth = 1.5
            self.sendButton.layer.borderColor = LIGHT_GREY.cgColor
            
            if !onlyButton {
                self.textField.layer.cornerRadius = textField.layer.frame.height / 2
                self.textField.layer.masksToBounds = true
            }
            
            performAction(for: .start, onlyButton: onlyButton)
            
        }
    }
    
    private func sendNotification(message: Message) {
        
        // Send Notification Message
        Notifications.instance.sendNotifications(with: message)
        
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
    }
    
    private func addMessage(messageText: String) {
        setProgress(progress: 0.0, animated: false, alpha: 1.0)
        if let remote = self.remoteUser {
            if let user = self.user {
                setProgress(progress: 0.5, animated: true, alpha: 1.0)
                
                var message = Message(from: user, to: remote, message: messageText)
                message.setCategory(category: .messageConfirm)
                sendNotification(message: message)
                
                self.messages.append(message)
                self.messages.sort(by: { $0._messageTime > $1._messageTime })
                
                self.totalMessages += 1
                self.tableView.reloadData()
            }
        }
    }
    
    @objc fileprivate func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.45, delay: 0.045, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
                
                self.tableViewBottom.constant = keyboardSize.height
                self.textFieldBottom.constant = keyboardSize.height
                
                self.performAction(for: .avbryt)
                
                
                hapticButton(.selection)
            })
        }
    }
    
    @objc fileprivate func keyboardWillDisappear(notification: NSNotification) {
        UIView.animate(withDuration: 0.45, delay: 0.045, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseOut, animations: {
            
            self.tableViewBottom.constant = 0.0
            self.textFieldBottom.constant = 0.0
            
            self.performAction(for: .start)
            
            
            hapticButton(.light)
        })
    }
    
    private func setProgress(progress: Float = 1.0, animated: Bool = true, alpha: CGFloat = 1.0) {
        if let progressView = self.progressView {
            if animated {
                progressView.setProgress(progress, animated: animated)
                UIView.animate(withDuration: 0.60, delay: 0.75, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    progressView.alpha = alpha
                })
            } else {
                progressView.setProgress(progress, animated: animated)
                progressView.alpha = alpha
            }
        }
    }
    
    // MARK: - Observer, Firebase Database Functions
    // ----------------------------------------
    private func removeMessagesObserver() {
        if let UID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            DataService.instance.REF_MESSAGES.child("private").child(UID).child("all").removeAllObservers()
        }
    }
    
    private func observeMessages() {
        if let UID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            DataService.instance.REF_MESSAGES.child("private").child(UID).child("all").queryOrdered(byChild: "messageTime").observe(.value, with: { (snapshot) in
                
                self.messages.removeAll()
                
                if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                    self.totalMessages = snapValue.keys.count
                    
                    for (_,value) in snapValue {
                        if let snapMessage = value as? [String:AnyObject] {
                            
                            guard let userID = self.user?.userUID else { return }
                            guard let remoteID = self.remoteUser?.userUID else { return }
                            
                            if let remoteU = self.remoteUser?.familyID {
                                print(remoteU)
                            }
                            
                            if userID != remoteID {
                                
                                if let fromUID = snapMessage["fromUID"] as? String, fromUID == userID || fromUID == remoteID {
                                    
                                    if let toUID = snapMessage["toUID"] as? String, toUID == userID || toUID == remoteID {
                                        
                                        if fromUID != toUID {
                                            
                                            if fromUID == userID {
                                                
                                                self.fetchMessageObserver(snapMessage, remoteUID: fromUID, userUID: toUID)
                                                
                                            } else if fromUID == remoteID {

                                                self.fetchMessageObserver(snapMessage, remoteUID: remoteID, userUID: userID)
                                                
                                            }
                                        }
                                    }
                                }
                            } else {
                                if let firstUID = snapMessage["fromUID"] as? String, firstUID == userID {
                                    if let secondUID = snapMessage["toUID"] as? String, secondUID == remoteID {
                                        self.fetchMessageObserver(snapMessage, remoteUID: remoteID, userUID: userID)
                                    }
                                }
                            }
                            
                        }
                    }
                }
                
            })
        }
    }
    
    private func fetchMessageObserver(_ messageSnap: Dictionary<String, AnyObject>, remoteUID: String, userUID: String) {
        let message = Message(
            from: remoteUID,
            to:  userUID,
            messageID: messageSnap["messageID"] as? String,
            message:  (messageSnap["message"] as? String)!,
            messageTime:  messageSnap["messageTime"] as! String,
            highlighted:  messageSnap["highlighted"] as? Bool ?? true)
        self.messages.append(message)
        self.messages.sort(by: { $0._messageTime > $1._messageTime })
        
        self.tableView.reloadData()
        self.setProgress(progress: 1.0, animated: true, alpha: 0.0)
    }
    
}

// MARK: - ViewDidLoad, ViewWillLoad etc...
// ----------------------------------------
extension MessageDetailVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.scrollsToTop = true
        
        tableView.contentInset.top = 65
        tableView.contentInset.bottom = 45
        
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        // tableView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
        
        performAction(for: .setup)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpKeyboard()
        observeMessages()
        // observeMessagesOnce()
        self.tableView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setProgress(progress: 0.0, animated: false, alpha: 1.0)
        animateCellsWithProgress(in: self.tableView, true, progress: self.progressView, completion: {
            print("animateCellsWithProgress completion")
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboard()
        removeMessagesObserver()
    }
    
}

// MARK: - TableView, Delegate & Datasource
// ----------------------------------------
extension MessageDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableViewCellHasLabel(tableView: UITableView, indexPath: IndexPath) -> Bool {
        let previousRow: Int? = indexPath.row != 0 ? indexPath.row - 1 : nil
        let previousPost = previousRow == nil ? false : true
        let previousMessage = previousPost == true ? messages[previousRow!].messageTime.timeIntervalSince(messages[indexPath.row].messageTime) > 3600 : false
        return previousMessage
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mainBoundsWidth = self.view.frame.width - 106
        // let characterCount = self.messages[indexPath.row]._message.count
        
        let firstRow: CGFloat = 54.5 // 51.0 // UIFont(name: "Avenir-Book", size: 12.0)
        let extraRowHeight: CGFloat = 19.75 // 18.0 // UIFont(name: "Avenir-Book", size: 12.0)
        
        let addedRow: CGFloat = tableViewCellHasLabel(tableView: tableView, indexPath: indexPath) ? 20.0 : 0.0
        // let charactersEachRow = 55
        // let extraRowCount = characterCount / charactersEachRow
        // let rowHeight: CGFloat = firstRow + CGFloat(Int(extraRowHeight) * extraRowCount)
        
        let messageText = self.messages[indexPath.row]._message
        let messageTextRows = messageText.linesFor(font: UIFont(name: "Avenir-Book", size: 14.0)!, width: mainBoundsWidth)
        
        let rowHeight: CGFloat = firstRow - extraRowHeight + CGFloat(Double(messageTextRows) * Double(extraRowHeight)) + addedRow
        return rowHeight // 55.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*
        let previousRow: Int? = indexPath.row != 0 ? indexPath.row - 1 : nil
        
        let previousPost = previousRow == nil ? false : true
        let previousMessage = previousPost == true ? messages[previousRow!].messageTime.timeIntervalSince(messages[indexPath.row].messageTime) > 3600 : false
        */
        
        let hasLabel = tableViewCellHasLabel(tableView: tableView, indexPath: indexPath)
        
        let leftIdentifier = hasLabel ? "MessageDetailLeftLabelCell" : "MessageDetailLeftCell"
        let rightIdentifier = hasLabel ? "MessageDetailRightLabelCell" : "MessageDetailRightCell"
        
        if let user = self.user, messages[indexPath.row]._fromUID == user.userUID {
            
            if let leftCell = tableView.dequeueReusableCell(withIdentifier: leftIdentifier, for: indexPath) as? MessageDetailTableCell {
                leftCell.setupView(with: self.messages[indexPath.row], to: user, hasDateTime: hasLabel)
                return leftCell
                
            }
        } else if let remoteUser = self.remoteUser {
            
            if let rightCell = tableView.dequeueReusableCell(withIdentifier: rightIdentifier, for: indexPath) as? MessageDetailTableCell {
                rightCell.setupView(with: self.messages[indexPath.row], to: remoteUser, hasDateTime: hasLabel)
                return rightCell
            }
        }
        return MessageDetailTableCell()
    }
}
