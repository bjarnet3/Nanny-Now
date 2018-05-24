//
//  NotificationViewController.swift
//  NotificationMessageResponse
//
//  Created by Bjarne Tvedten on 14.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class User {
    // Identification
    // --------------
    private(set) public var _userUID: String?
    private(set) public var _userFID: String?
    
    // Personal information (Private)
    // ------------------------------
    private(set) public var _imageName: String?
    private(set) public var _firstName: String?
    private(set) public var _lastName: String?
    
    // Computed Properties
    // -------------------
    var userUID: String { return _userUID! }
    var userFID: String { return _userFID! }
    
    var imageName: String { get { return _imageName! } set { _imageName = newValue } }
    var firstName: String { get { return _firstName! } set { _firstName = newValue } }
    var lastName: String { return _lastName! }
    
    // Initializers
    // ------------
    init(userUID: String?, imageName: String?, firstName: String?) {
        self._userUID = userUID
        self._imageName = imageName
        self._firstName = firstName
    }
}

struct Message {
    // Personal information (Private)
    // ------------------------------
    private(set) public var _toUser: User?
    private(set) public var _fromUser: User?
    
    private(set) public var _toUID: String
    private(set) public var _fromUID: String
    
    private(set) public var _imageURL: String?
    
    // Service information (Request)
    // -----------------------------
    private(set) public var _messageID: String
    private(set) public var _messageTime: String
    private(set) public var _message: String
    
    private(set) public var _highlighted: Bool = false
    
    mutating func setTo(user: User) {
        self._toUser = user
    }
    
    mutating func setFrom(user: User) {
        self._fromUser = user
    }
    
    mutating func setImageUrl(imageURL: String) {
        self._imageURL = imageURL
    }
    
    init(from fromUser: User, to toUser: User, message: String) {
        self._toUser = toUser
        self._fromUser = fromUser
        
        self._toUID = toUser.userUID
        self._fromUID = fromUser.userUID
        
        self._imageURL = fromUser.imageName
        
        self._messageID = "messageID"
        self._message = message
        self._messageTime = "messageTime"
        
        self._highlighted = false
    }
    
    init(from fromUID: String, to toUID: String, messageID: String, message: String, messageTime: String, highlighted: Bool = true) {
        self._toUID = toUID
        self._fromUID = fromUID
        
        self._messageID = messageID
        self._message = message
        self._messageTime = messageTime
        
        self._highlighted = highlighted
    }
    
}

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    // MARK: - IBOutlet: Connection to Storyboard
    // ----------------------------------------
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    private var user: User?
    private var remoteUser: User?
    
    private var messages = [Message]()
    private var totalMessages: Int = 0
    
    @IBAction func sendButton(_ sender: UIButton) {
        if sender.titleLabel?.text == "SEND" {
            sendMessage()
        } else {
            self.view.endEditing(true)
        }
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
    
    private func getMessage(messageText: String) {
        let message = Message(from: (self.remoteUser?.userUID)!, to: (self.user?.userUID)!, messageID: "messageID", message: messageText, messageTime: "messageTime")
        self.messages.append(message)
    }
    
    private func addMessage(messageText: String) {
        if let remote = self.remoteUser {
            if let user = self.user {
                let message = Message(from: user.userUID, to: remote.userUID, messageID: "messageID", message: messageText, messageTime: "messageTime")
                
                self.messages.append(message)
                self.messages.sort(by: { $0._messageTime > $1._messageTime })
                
                self.totalMessages += 1
                self.tableView.reloadData()
            }
        }
    }
    
    func didReceive(_ notification: UNNotification) {
        
        let userInfo = notification.request.content.userInfo
        
        let userID = userInfo["userID"] as? String
        let remoteID = userInfo["remoteID"] as? String
        
        // let userImageUrl = AnyHashable("userUrl")
        let userURL = AnyHashable("remoteURL")
        let remoteURL = AnyHashable("userURL")
        
        let userImageName = userInfo[userURL]! as? String
        let remoteImageName = userInfo[remoteURL]! as? String
        
        let messageText = notification.request.content.body
        
        let user = User(userUID: userID, imageName: userImageName, firstName: "userName")
        let remoteUser = User(userUID: remoteID, imageName: remoteImageName, firstName: "remoteName")
        
        setupView(user: user, remoteUser: remoteUser)
        
        self.getMessage(messageText: messageText)
        // let title = notification.request.content.title
        // let body = notification.request.content.body
    }

}

// MARK: - ViewDidLoad, ViewWillLoad etc...
// ----------------------------------------
extension NotificationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.reloadData()
        print(messages.count)
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let user = self.user, messages[indexPath.row]._fromUID == user.userUID {
            if let leftCell = tableView.dequeueReusableCell(withIdentifier: "MessageDetailLeftCell", for: indexPath) as? NotificationMessageCell {
                leftCell.setupView(with: self.messages[indexPath.row], to: user)
                // leftCell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                return leftCell
            }
        } else if let remoteUser = self.remoteUser {
            if let rightCell = tableView.dequeueReusableCell(withIdentifier: "MessageDetailRightCell", for: indexPath) as? NotificationMessageCell {
                rightCell.setupView(with: self.messages[indexPath.row], to: remoteUser)
                // rightCell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                return rightCell
            }
        }
        return NotificationMessageCell()
    }
    
}
