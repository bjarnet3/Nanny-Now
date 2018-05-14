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

class MessageDetailVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    
    var user: User?
    var remoteUser: User?
    
    var messages = [Message]()
    var totalMessages: Int = 0
    
    func setupView(user:User, remoteUser: User) {
        self.user = user
        self.remoteUser = remoteUser
    }
    
    @IBAction func sendButton(_ sender: Any) {
        sendMessage()
        dismissKeyboard()
        addMessageToArray()
    }
    
    @IBAction func resignKeyboard(_ sender: Any) {
        dismissKeyboard()
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendMessage() {
        if let text = chatTextField.text {
            // Send Message to remoteUser
            sendNotification(messageText: text)
            // Remove text from Textfield
            self.chatTextField.text = ""
            // Dismiss Keyboard
            // self.dismissKeyboard()
            self.chatTextField.endEditing(true)
            self.tableView.reloadData()
        }
    }
    
    func sendNotification(messageText: String) {
        // Send Message
        let message = Message(from: self.user!, to: remoteUser!, message: messageText)
        Notifications.instance.sendNotifications(with: message)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.returnKeyType==UIReturnKeyType.go)
        {
            
        }
        return true
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - Observer, Firebase Database Functions
    // ----------------------------------------
    func observeMessages() {
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
    
    func fetchMessageObserver(_ messageSnap: Dictionary<String, AnyObject>, remoteUID: String, userUID: String) {
        let message = Message(
            from: remoteUID,
            to:  userUID,
            messageID: messageSnap["messageID"] as? String,
            message:  (messageSnap["message"] as? String)!,
            messageTime:  messageSnap["messageTime"] as! String,
            highlighted:  messageSnap["highlighted"] as? Bool ?? true)
        self.messages.append(message)
        self.messages.sort(by: { $0._messageTime < $1._messageTime })
        self.tableView.reloadData()
    }
    
    func addMessageToArray() {
        if let remote = self.remoteUser {
            if let user = self.user {
                var message = Message(
                    from: user.userUID,
                    to:  remote.userUID,
                    message:  self.chatTextField.text!,
                    messageTime:  returnTimeStamp(),
                    highlighted: true)
                message.setMessageID()
                self.messages.append(message)
                self.messages.sort(by: { $0._messageTime < $1._messageTime })
                self.tableView.reloadData()
                // self.tableView.reloadData()
            }
        }
    }
}

extension MessageDetailVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tableView.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        observeMessages()
        animateCells(in: self.tableView, true)
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
                return leftCell
            }
        } else if let remoteUser = self.remoteUser {
            if let rightCell = tableView.dequeueReusableCell(withIdentifier: "MessageDetailRightCell", for: indexPath) as? MessageDetailTableCell {
                rightCell.setupView(with: self.messages[indexPath.row], to: remoteUser)
                return rightCell
            }
        }
        return MessageDetailTableCell()
    }
}
