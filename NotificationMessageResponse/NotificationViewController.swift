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

private extension Selector {
    static let keyboardWillShow = #selector(NotificationViewController.keyboardWillShow(notification:))
    static let keyboardWillDisappear = #selector(NotificationViewController.keyboardWillDisappear(notification:))
}

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    // MARK: - IBOutlet: Connection to Storyboard
    // ----------------------------------------
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var textFieldBottom: NSLayoutConstraint!
    
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
    
    @objc fileprivate func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.45, delay: 0.045, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
                
                // self.tableViewBottom.constant = keyboardSize.height
                self.textFieldBottom.constant = keyboardSize.height + 55.0
            })
        }
    }
    
    @objc fileprivate func keyboardWillDisappear(notification: NSNotification) {
        UIView.animate(withDuration: 0.45, delay: 0.045, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseOut, animations: {
            
            // self.tableViewBottom.constant = 0.0
            self.textFieldBottom.constant = 55.0
        })
    }
    
    // MARK: - Functions, Database & Animation
    // ----------------------------------------
    private func sendMessage(message: String) {
    }
    
    private func setUpKeyboard() {
        NotificationCenter.default.addObserver(self, selector: .keyboardWillShow, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: .keyboardWillDisappear, name: .UIKeyboardWillHide, object: nil)
    }
    
    private func removeKeyboard() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow , object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide , object: nil)
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
    
    override var inputView: UIView? {
        return self.view
    }
    
    override var inputAccessoryView: UIView? {
        return self.view
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpKeyboard()
    }
    
}
