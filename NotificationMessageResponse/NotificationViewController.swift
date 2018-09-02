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
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    var user: UserLite?
    var remoteUser: UserLite?
    
    var messages = [MessageLite]()
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    // MARK: - IBAction: Methods connected to UI
    // ----------------------------------------
    
    // MARK: - Functions, Database & Animation
    // ----------------------------------------
    
    func didReceive(_ notification: UNNotification) {
        bestAttemptContent = (notification.request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let remoteID = AnyHashable("userID")
        let userID = AnyHashable("remoteID")
        
        let remoteURL = AnyHashable("userURL")
        let userURL = AnyHashable("remoteURL")
        
        if let bestAttemptContent = bestAttemptContent {

            let remoteMessage = bestAttemptContent.body
            let userInfo = bestAttemptContent.userInfo
            
            guard let userUID = userInfo[userID] as? String else { return }
            let user = UserLite(userUID: userUID)
            
            guard let remoteUID = userInfo[remoteID] as? String else { return }
            let remoteUser = UserLite(userUID: remoteUID)
            
            guard let userImage = userInfo[userURL] as? String else { return }
            user.imageName = userImage
            
            self.user = user
            
            guard let remoteImage = userInfo[remoteURL] as? String else { return }
            remoteUser.imageName = remoteImage
            
            self.remoteUser = remoteUser
            let message = MessageLite(from: remoteUser, to: user, message: remoteMessage)
            
            self.messages.append(message)
            self.tableView.reloadData()
        }
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {

        guard let user = self.user else { return }
        guard let remoteUser = self.remoteUser else { return }
        
        if response.actionIdentifier == "messageResponse" {
            if let textResponse = response as? UNTextInputNotificationResponse {
                
                let toMessage = MessageLite(from: user, to: remoteUser, message: textResponse.userText)
                
                self.messages.append(toMessage)
                self.tableView.reloadData()
                
                // Animate cell exept the first cell
                var cells = tableView.visibleCells
                cells.remove(at: 0)
                
                animate(cells: cells, in: self.tableView, true, delay: 0.01)
                // animateCells(in: self.tableView, true, delay: 0.01)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // this is the best delay
                    completion(.dismissAndForwardAction)
                }
            }
        } else if response.actionIdentifier == "messageAccept" {
            completion(.dismissAndForwardAction)
        } else {
            completion(.dismiss)
        }
    }

    // Return something before time expires.
    func serviceExtensionTimeWillExpire() {
        
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}

// MARK: - ViewDidLoad, ViewWillLoad etc...
// ----------------------------------------
extension NotificationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.alpha = 0
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.scrollsToTop = true
        
        tableView.contentInset.top = 65
        tableView.contentInset.bottom = 45
        
        // Reverse "mirror" TableView
        // tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        animateCells(in: self.tableView, delay: 0.15)
    }
}

extension NotificationViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mainBoundsWidth = self.view.frame.width - 106
        
        let firstRowHeight: CGFloat = 54.5 // 51.0 // UIFont(name: "Avenir-Book", size: 12.0)
        let extraRowHeight: CGFloat = 20.0 // 18.0 // UIFont(name: "Avenir-Book", size: 12.0)
        
        // let firstRow: CGFloat = indexPath.row == 0 ? extraRowHeight : 0.0
        let addedRow: CGFloat = 20.0
        
        let messageText = self.messages[indexPath.row]._message
        let messageTextRows = messageText.linesFor(font: UIFont(name: "Avenir-Book", size: 14.0)!, width: mainBoundsWidth)
        
        let rowHeight: CGFloat = firstRowHeight - extraRowHeight + CGFloat(Double(messageTextRows) * Double(extraRowHeight)) + addedRow
        return rowHeight // 55.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let leftIdentifier = "NotificationLeftDateCell"
        let rightIdentifier = "NotificationRightDateCell"

        if indexPath.row == 0 {
            // guard let user = self.user else { return NotificationTableCell(style: .default, reuseIdentifier: leftIdentifier) }
            if let leftCell = tableView.dequeueReusableCell(withIdentifier: leftIdentifier, for: indexPath) as? NotificationTableCell {
                leftCell.setupView(with: self.messages[indexPath.row], to: self.remoteUser!)
                return leftCell
            }
        } else {
            // guard let remoteUser = self.remoteUser else { return NotificationTableCell(style: .default, reuseIdentifier: rightIdentifier) }
            if let rightCell = tableView.dequeueReusableCell(withIdentifier: rightIdentifier, for: indexPath) as? NotificationTableCell {
                rightCell.setupView(with: self.messages[indexPath.row], to: self.user!)
                return rightCell
            }
        }
        return NotificationTableCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
}
