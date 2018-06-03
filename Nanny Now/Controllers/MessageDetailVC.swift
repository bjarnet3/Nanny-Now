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

class MessageDetailVC: UIViewController {
    
    // MARK: - IBOutlet: Connection to Storyboard
    // ----------------------------------------
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var bottomLayoutTextField: NSLayoutConstraint!
    
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    private var user: User?
    private var remoteUser: User?
    
    private var messages = [Message]()
    private var totalMessages: Int = 0
    
    // MARK: - IBAction: Methods connected to UI
    // ----------------------------------------
    @IBAction func backButton(_ sender: Any) {
        self.progressView.setProgress(0.0, animated: false)
        self.progressView.alpha = 1.0
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButton(_ sender: UIButton) {
        if sender.titleLabel?.text == "SEND" {
            sendMessage()
        } else {
            self.view.endEditing(true)
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
            self.sendButton.setTitle("AVBRYT", for: .normal)
        } else {
            self.sendButton.setTitle("SEND", for: .normal)
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
            // Set Title To AVBRYT
            self.sendButton.setTitle("AVBRYT", for: .normal)
        }
    }
    
    private func sendNotification(message: Message) {
        // Send Notification Message
        Notifications.instance.sendNotifications(with: message)
        
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
    }
    
    private func addMessage(messageText: String) {
        if let remote = self.remoteUser {
            if let user = self.user {
                
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
                self.bottomLayoutTextField.constant = keyboardSize.height
            })
        }
    }
    
    @objc fileprivate func keyboardWillDisappear(notification: NSNotification) {
        UIView.animate(withDuration: 0.45, delay: 0.045, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
            self.bottomLayoutTextField.constant = 0.0
        })
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpKeyboard()
        observeMessages()
        // observeMessagesOnce()
        self.tableView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let progress = self.progressView
        progress?.setProgress(0.0, animated: false)
        progress?.alpha = 1.0
        
        animateCellsWithProgress(in: self.tableView, true, progress: progress!, completion: {
            print("complete home")
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let user = self.user, messages[indexPath.row]._fromUID == user.userUID {
            if let leftCell = tableView.dequeueReusableCell(withIdentifier: "MessageDetailLeftCell", for: indexPath) as? MessageDetailTableCell {
                leftCell.setupView(with: self.messages[indexPath.row], to: user)
                // leftCell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                return leftCell
            }
        } else if let remoteUser = self.remoteUser {
            if let rightCell = tableView.dequeueReusableCell(withIdentifier: "MessageDetailRightCell", for: indexPath) as? MessageDetailTableCell {
                rightCell.setupView(with: self.messages[indexPath.row], to: remoteUser)
                // rightCell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                return rightCell
            }
        }
        return MessageDetailTableCell()
    }
}
