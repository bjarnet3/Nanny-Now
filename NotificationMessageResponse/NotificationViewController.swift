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

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    // MARK: - IBOutlet: Connection to Storyboard
    // ----------------------------------------
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    @IBAction func sendButton(_ sender: UIButton) {
        if sender.titleLabel?.text == "SEND" {
            sendMessage(message: "the message")
        } else {
            self.view.endEditing(true)
        }
    }
    
    @IBAction func textFieldEnter(_ sender: UITextField) {
        if (sender.returnKeyType==UIReturnKeyType.send)
        {
            if let message = self.textField.text {
                
                sendMessage(message: message)
            }
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
    private func sendMessage(message: String) {
    }
    
    func didReceive(_ notification: UNNotification) {
        
        let remoteURL = AnyHashable("userURL")
        let userURL = AnyHashable("remoteURL")
        
        // let title = notification.request.content.title
        let messageText = notification.request.content.body
        
        let userInfo = notification.request.content.userInfo
        
        guard let userImageName = userInfo[userURL] as? String else { return }
        guard let remoteImageName = userInfo[remoteURL] as? String else { return }
        
        // self.yourImageView.loadImageUsingCacheWith(urlString:yourImageUrl)
        // self.remoteImageView.loadImageUsingCacheWith(urlString: remoteImageUrl)
        
        let userID = userInfo["remoteID"] as? String
        let remoteID = userInfo["userID"] as? String
    }

}

// MARK: - ViewDidLoad, ViewWillLoad etc...
// ----------------------------------------
extension NotificationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
