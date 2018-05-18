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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var bottomLayoutTextField: NSLayoutConstraint!
    @IBOutlet weak var sendButtonTitle: UIButton!
    
    private var user: User?
    private var remoteUser: User?
    
    private var messages = [Message]()
    private var totalMessages: Int = 0
    
    func setupView(user:User, remoteUser: User) {
        self.user = user
        self.remoteUser = remoteUser
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButton(_ sender: UIButton) {
        if sender.titleLabel?.text == "SEND" {
            sendMessage()
            addMessageToArray()
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
            addMessageToArray()
        }
    }
    
    @IBAction func textFieldValue(_ sender: UITextField) {
        print("textField did change value")
        if sender.text?.count == 0 {
            print("textField did change value is nil")
            self.sendButtonTitle.setTitle("AVBRYT", for: .normal)
        } else {
            print("textField did change value is not nil")
            self.sendButtonTitle.setTitle("SEND", for: .normal)
        }
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
        if let text = chatTextField.text {
            // Send Message to remoteUser
            sendNotification(messageText: text)
            // Remove text from Textfield
            self.chatTextField.text = ""
            // Dismiss Keyboard
            self.chatTextField.endEditing(true)
            // Set Title To AVBRYT
            self.sendButtonTitle.setTitle("AVBRYT", for: .normal)
        }
    }
    
    private func sendNotification(messageText: String) {
        // Send Message
        let message = Message(from: self.user!, to: remoteUser!, message: messageText)
        Notifications.instance.sendNotifications(with: message)
        
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.45, delay: 0.045, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
                self.bottomLayoutTextField.constant = keyboardSize.height
            })
        }
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification) {
        UIView.animate(withDuration: 0.45, delay: 0.045, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
            self.bottomLayoutTextField.constant = 0.0
        })
    }
    
    // MARK: - Observer, Firebase Database Functions
    // ----------------------------------------
    private func observeMessages() {
        if let UID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            DataService.instance.REF_MESSAGES.child("private").child(UID).child("all").queryOrdered(byChild: "messageTime").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                    self.totalMessages = snapValue.keys.count
                    
                    print("snapshot count: \(snapValue.keys.count)")
                    print("------------------")
                    
                    for (_,value) in snapValue.reversed() {
                        if let snapMessage = value as? [String:AnyObject] {
                            
                            guard let userID = self.user?.userUID else { return }
                            guard let remoteID = self.remoteUser?.userUID else { return }
                            
                            if let remoteU = self.remoteUser?.familyID {
                                print(remoteU)
                            }
                            
                            print(snapMessage)
                            print("userID \(userID)")
                            print("remoteID \(remoteID)")
                            
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
    
    private func addMessageToArray() {
        if let remote = self.remoteUser {
            if let user = self.user {
                var message = Message(
                    from: user.userUID,
                    to: remote.userUID,
                    message:  self.chatTextField.text!,
                    messageTime:  returnTimeStamp(),
                    highlighted: true)
                message.setMessageID()
                self.messages.append(message)
                self.messages.sort(by: { $0._messageTime > $1._messageTime })
                self.tableView.reloadData()
            }
        }
    }
}

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
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tableView.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        observeMessages()
        // animateCells(in: self.tableView, true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboard()
    }
}

extension MessageDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let user = self.user, messages[indexPath.row]._fromUID == user.userUID {
            if let leftCell = tableView.dequeueReusableCell(withIdentifier: "MessageDetailLeftCell", for: indexPath) as? MessageDetailTableCell {
                leftCell.setupView(with: self.messages[indexPath.row], to: user)
                leftCell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
                // leftCell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                return leftCell
            }
        } else if let remoteUser = self.remoteUser {
            if let rightCell = tableView.dequeueReusableCell(withIdentifier: "MessageDetailRightCell", for: indexPath) as? MessageDetailTableCell {
                rightCell.setupView(with: self.messages[indexPath.row], to: remoteUser)
                rightCell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
                // tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                // rightCell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                return rightCell
            }
        }
        return MessageDetailTableCell()
    }
}
