//
//  NotificationService.swift
//  NotificationServiceExtensions
//
//  Created by Bjarne Tvedten on 05.05.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    let remoteURL = AnyHashable("userURL")

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        bestAttemptContent?.categoryIdentifier = bestAttemptContent?.userInfo["category"] as! String
        
        if let remoteUrl = request.content.userInfo[remoteURL] as? String {
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: URL(string: remoteUrl)!, completionHandler: { [weak self] (data, response, error) in
                if let data = data {
                    do {
                        let writePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("remoteImage.png")
                        try data.write(to: writePath)
                        guard let wself = self else {
                            return
                        }
                        if let bestAttemptContent = wself.bestAttemptContent {
                            // Can this be the Notification Content Extension :-o :-o
                            // With identifier
                            let attachment = try UNNotificationAttachment(identifier: "remoteImage", url: writePath, options: nil)
                            bestAttemptContent.attachments = [attachment]
                            
                            contentHandler(bestAttemptContent)
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        
                        guard let wself = self else {
                            return
                        }
                        if let bestAttemptContent = wself.bestAttemptContent {
                            contentHandler(bestAttemptContent)
                        }
                    }
                } else if let error = error {
                    print(error.localizedDescription)
                }
            })
            task.resume()
        } else {
            if let bestAttemptContent = bestAttemptContent {
                contentHandler(bestAttemptContent)
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
