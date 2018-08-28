//
//  Notifications.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 30.05.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

// var sendNotifications = Notifications.instance.sendNotifications

/// Library / Sounds / ....
public enum SoundLibrary: String  {
    /// Notificaiton Request Default Sound
    case notification11 = "notification11.wav"
    /// Notification Message Request Sound
    case notification48 = "notification48.wav"
    case notification50 = "notification50.wav"
    /// Notificaiton Send From Chat Confirmation
    case success_notification = "success_notification.wav"
    /// Notification - Can be suitable as Recieve Sound compared to Success
    case falure_notification = "failure_notification.wav"
    /// Sounds like a SMS Recieving Sound from a phone Company
    case sundarbans = "sundarbans.mp3"
    /// Sharp Short Notification Sound
    case simple_notification = "simple_notification.mp3"
    /// Short Notification Sound
    case short_notification = "short_notification.mp3"
    /// Notification Sound "DUO Notificaiton is a proper name"
    case duo_notification = "duo_notification.mp3"
    /// Notificaiton Sound "With a funny twist in the end"
    case csd_notification_01 = "csd_notification_01.mp3"
}

public func returnSoundFromLibrary(soundName: SoundLibrary) -> String {
    return soundName.rawValue
}

// INCOMPLETE FUNCTION
public func returnFilenameAndExtensionFromSound(soundName: SoundLibrary) -> (String, String) {
    var soundfileName = returnSoundFromLibrary(soundName: soundName)
    let audioExtension = soundfileName.suffix(3)
    soundfileName.removeLast(4)
    return (soundfileName, String(audioExtension))
}

/// Defination of category types will come here !!
public enum NotificationCategory : String {
    case nannyRequest = "nannyRequest"
    case nannyMapRequest = "nannyMapRequest"
    case nannyConfirm = "nannyConfirm"
    
    case familyRequest = "familyRequest"
    case familyMapRequest = "familyMapRequest"
    case familyConfirm = "familyConfirm"
    
    case messageRequest = "messageRequest"
    case messageConfirm = "messageConfirm"
    
    case defaultCategory = "defaultCategory"
}

public enum NotificationAction: String {
    case nannyAccept = "nannyAccept"
    case nannyReject = "nannyReject"
    case nannyResponse = "nannyResponse"
    
    case familyAccept = "familyAccept"
    case familyReject = "familyReject"
    case familyResponse = "familyResponse"
    
    case messageAccept = "messageAccept"
    case messageReject = "messageReject"
    case messageResponse = "messageResponse"
    
    case defaultAccept = "defaultAccept"
    case defaultReject = "defaultReject"
    case defaultRemind = "defaultRemind"
    
    case defaultAction = "defaultAction"
}

public func notificationRequest(category: String) -> NotificationCategory {
    guard let notificaitonCategory = NotificationCategory(rawValue: category) else { return NotificationCategory.defaultCategory }
    return notificaitonCategory
}

public func notificationRequest(action: String) -> NotificationAction {
    guard let notificaitonAction = NotificationAction(rawValue: action) else { return NotificationAction.defaultAction }
    return notificaitonAction
}

/// Notification Singleton / with sendNotification() and sendNotificationResponse() function
class Notifications {
    
    // Create singleton of Notification Class "itself"
    static let instance = Notifications()
    
    // Send Notification using Message Object
    // --------------------------------------
    func sendNotification(with message: Message) {
        
        guard let userID = KeychainWrapper.standard.string(forKey: KEY_UID) else { return }
        let remoteID = message._toUser?.userUID ?? message._toUID
        let messageText = message._message
        let messageID = message._messageID
        let category = message._requestCategory
        
        var tokens = [String]()
        let tokenREF = DataService.instance.REF_USERS_PRIVATE.child(remoteID).child("tokens")
        
        tokenREF.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let snapValue = snap.value as? [String: String] {
                        for (key,val) in snapValue {
                            if key == "token" {
                                tokens.append(val)
                            }
                        }
                    }
                }
                
                var badge = 0
                let badgeRef = DataService.instance.REF_USERS_PRIVATE.child(remoteID).child("badge")
                badgeRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if !snapshot.exists() { return }
                    if snapshot.key == "badge" {
                        
                        badge = snapshot.value as! Int
                        badge += 1
                        
                        badgeRef.setValue(badge)
                    }
                    
                    // Get tokens from Database
                    let registration_ids = tokens
                    
                    // Name / Username
                    let userName = message._fromUser?.firstName ?? "_fromUser"
                    let remoteName = message._toUser?.firstName ?? "_toUser"
                    
                    // ImageName / ProfileImage
                    let remoteURL = message._toUser?.imageName ?? "_remoteURL"
                    let userURL = message._fromUser?.imageName ?? "_userURL"
                    
                    // Title
                    var title = "\(userName)"
                    
                    switch category {
                    case .messageRequest:
                        title = "Melding fra \(userName):"
                        DataService.instance.postToMessage(recieveUserID: remoteID, message: "\(messageText)")
                    default:
                        //.messageReponse:
                        title = "Beskjed fra \(userName)"
                        DataService.instance.postToMessage(recieveUserID: remoteID, message: "\(messageText)")
                    }
                    
                    let taskDictionary =
                        ["data":
                            [ "category": category.rawValue,
                              "messageID": messageID,
                              
                              "remoteURL": remoteURL,
                              "userURL": userURL,
                              
                              "remoteID": remoteID,
                              "userID"  : userID,
                              
                              "remoteName": remoteName,
                              "userName" : userName
                            ],
                         "registration_ids" : registration_ids,
                         "notification":
                            ["title" : title,
                             "body"  : messageText,
                             "sound" : "notification48.wav",
                             "badge" : badge],
                         "priority":10,
                         "mutable_content": true,
                         "category" : category.rawValue
                            ] as [String : Any]
                    
                    self.performPOST(with: taskDictionary)
                })
            }
        })

    }
    
    func performPOST(with taskDictionary : [String:Any] ) {
        if let url = URL(string:"https://fcm.googleapis.com/fcm/send"){
            
            let serverKey = "AAAAd-nNctg:APA91bGhfGrYaRg-QOHx0LlfTyqU9cwOECMvm6jGHMZaeLGsToNPJtgV0y-EfcmMVFZbfbxdkF3ubJ8NC94-B-I74lV-UG2f-kuvjLtOnG_wbHecjdBc93Y59tv7XCJCEXEW3hTKH4oC"
            
            var request = URLRequest(url:url)
            request.allHTTPHeaderFields = ["Content-Type":"application/json","Authorization":"key=\(serverKey)"]
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: taskDictionary, options: .sortedKeys)
            request.cachePolicy = .reloadIgnoringCacheData
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data, urlresponse, error) in
                if error != nil{
                    print(error!)
                }
            }).resume()
        }
    }
    
    // Send Notification using Request Object
    // --------------------------------------
    func sendNotification(with request: Request) {
        DataService.instance.updateUserStatus(with: .active)
        
        let requestID = request.requestID ?? DataService.instance.REF_REQUESTS.childByAutoId().key
        let message = request.message
        let remoteID = request.nannyID
        let categoryRequest = NotificationCategory(rawValue: request.requestCategory)!
        
        guard let user = request._user else { return }
        guard let remote = request._nanny else { return }
        // guard let activeLocation = user.activeLocation ?? user.location else { return }
        guard let userUID = KeychainWrapper.standard.string(forKey: KEY_UID) else { return }
        
        let url = NSURL(string: "https://fcm.googleapis.com/fcm/send")!
        let session = URLSession.shared
        
        let urlRequest = NSMutableURLRequest(url: url as URL)
        urlRequest.httpMethod = "POST"
        urlRequest.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        let nameRef = DataService.instance.REF_USERS_PRIVATE.child(userUID).child("first_name")
        nameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if !snapshot.exists() { return }
            
            if snapshot.key == "first_name" {
                let firstName = snapshot.value as! String
                
                let idRef = DataService.instance.REF_USERS_PRIVATE.child(userUID).child("fid")
                idRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if !snapshot.exists() { return }
                    
                    if snapshot.key == "fid" {
                        // let id = snapshot.value as! String
                        
                        var tokens = [String]()
                        var tokenRef = DataService.instance.REF_USERS_PRIVATE.child(remoteID).child("tokens")
                        
                        switch categoryRequest {
                        case .nannyRequest, .nannyMapRequest:
                            tokenRef = DataService.instance.REF_NANNIES_ACTIVE.child(remoteID).child("tokens")
                        default:
                            tokenRef = DataService.instance.REF_USERS_PRIVATE.child(remoteID).child("tokens")
                        }
                        tokenRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            if !snapshot.exists() { return }
                            
                            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                                for snap in snapshot {
                                    if let snapValue = snap.value as? [String: String] {
                                        for (key,val) in snapValue {
                                            if key == "token" {
                                                tokens.append(val)
                                            }
                                        }
                                    }
                                }
                                
                                var badge = 0
                                let badgeRef = DataService.instance.REF_USERS_PRIVATE.child(remoteID).child("badge")
                                badgeRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                    
                                    if !snapshot.exists() { return }
                                    if snapshot.key == "badge" {
                                        
                                        badge = snapshot.value as! Int
                                        badge += 1
                                        
                                        badgeRef.setValue(badge)
                                    }
                                    
                                    guard let userLat = user.activeLocation?.coordinate.latitude else { return }// ?? 60.12424245
                                    guard let userLong = user.activeLocation?.coordinate.longitude else { return } // ?? 5.4343453
                                    
                                    guard let remoteLat = remote.location?.coordinate.latitude else { return } // ?? 60.1890322
                                    guard let remoteLong = remote.location?.coordinate.longitude else { return } // ?? 5.9254423
                                    
                                    // Get tokens from Database
                                    let registration_ids = tokens
                                    let message = message
                                    var title = "\(firstName)"
                                    // let contentAvailable = false
                                    
                                    // For Advanced Rich Notificaiton Setup
                                    let remoteURL = remote.imageName
                                    let userURL = user.imageName
                                    
                                    // MARK: - Change this to display different Notificaiton Categories
                                    let category = categoryRequest.rawValue // "messageRequest"

                                    switch categoryRequest {
                                    case .nannyRequest, .nannyMapRequest:
                                        title = "Forespørsel fra \(firstName):"
                                        
                                        self.nannyRequest(userUID: userUID, remoteUID: remoteID, request: request)
                                    case .nannyConfirm:
                                        title = "Barnevakten \(firstName):"
                                        
                                        let publicRequest = DataService.instance.REF_REQUESTS.child("public").child(requestID)
                                        publicRequest.child("nannyID").removeValue()
                                    case .familyRequest:
                                        print("familyRequest")
                                    case .familyMapRequest:
                                        print("familyMapAccept")
                                    case .familyConfirm:
                                        print("familyConfirmed")
                                    default:
                                        title = "\(firstName)"
                                    }

                                    let dictionary =
                                        ["data":
                                            [ "category": category,
                                              "requestID": requestID,
                                              
                                              "remoteID": remoteID,
                                              "remoteURL": remoteURL,
                                              "remoteLat": String(remoteLat),
                                              "remoteLong": String(remoteLong),
                                              
                                              "userID"  : userUID,
                                              "userURL": userURL,
                                              "userLat": String(userLat),
                                              "userLong": String(userLong)
                                            ],
                                         "registration_ids" : registration_ids,
                                         "notification":
                                            ["title" : title,
                                             "body"  : message,
                                             "sound" : returnSoundFromLibrary(soundName: .notification11),
                                             "badge" : badge],
                                         "priority":10,
                                            // "content_available": contentAvailable,
                                            "mutable_content": true,
                                            "category" : category
                                            ] as [String : Any]
                                    
                                    do {
                                        try urlRequest.httpBody = JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
                                    }
                                    catch {}
                                    
                                    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                    urlRequest.addValue("key=AAAAd-nNctg:APA91bGhfGrYaRg-QOHx0LlfTyqU9cwOECMvm6jGHMZaeLGsToNPJtgV0y-EfcmMVFZbfbxdkF3ubJ8NC94-B-I74lV-UG2f-kuvjLtOnG_wbHecjdBc93Y59tv7XCJCEXEW3hTKH4oC", forHTTPHeaderField: "Authorization")
                                    
                                    let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: {data, response, error -> Void in
                                        _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                                        var json = NSDictionary()
                                        do { json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary } catch {}
                                        let parseJSON = json
                                        _ = parseJSON["success"] as? Int
                                    })
                                    task.resume()
                                })
                            }
                        })
                    }
                })
            }
        })

    }
    
    func nannyRequest(userUID: String, remoteUID: String, request: Request) {
        let requestREFID = DataService.instance.REF_REQUESTS.childByAutoId()
        let requestID = request.requestID ?? requestREFID.key // maybe add requestID argument
        
        // let publicRequest = DataService.instance.REF_REQUESTS.child("public").child(remoteUID).child(requestID)
        let publicRequest = DataService.instance.REF_REQUESTS.child("public").child(remoteUID).child(requestID)
        let setUserID = ["userID" : userUID,
                         "requestID": requestID ]
        
        DataService.instance.postToRequest(with: request, reference: publicRequest)
        publicRequest.updateChildValues(setUserID)
        
        let setRemoteID = ["userID" : remoteUID,
                           "requestID": requestID
        ]
        let privateRequest = DataService.instance.REF_REQUESTS.child("private").child(userUID).child("requests").child(requestID)
        DataService.instance.postToRequest(with: request, reference: privateRequest)
        privateRequest.updateChildValues(setRemoteID)
    }
    
}

/* Testing av Notifications med Curl in Terminal
 
 // Irina with nannyCategory
 curl -H "Content-type: application/json" -H "Authorization:key=AAAAd-nNctg:APA91bGhfGrYaRg-QOHx0LlfTyqU9cwOECMvm6jGHMZaeLGsToNPJtgV0y-EfcmMVFZbfbxdkF3ubJ8NC94-B-I74lV-UG2f-kuvjLtOnG_wbHecjdBc93Y59tv7XCJCEXEW3hTKH4oC"  -X POST -d '{ "data": { "category": "nannyRequest","mediaUrl": "https://video-images.vice.com/articles/58dbd4fdd229e46c744447aa/lede/1490802358036-Sovereign-Syre-by-Richard-Avery-2.jpeg?crop=0.9491787439613527xw:1xh;center,center&resize=525:*"},"registration_ids" : ["fgeEPLe_WC8:APA91bHCGbXHYkF8FLlzu63HefA5yoTJTr2SwJNJ_kfyUdCUBuPZdeRUtT0cVFvsp8AAgWqByWHigElq98GNV-kCu1gZCK9Nut3WyEn4xgchUZ3fT8uGExdN12iUexkkRwUhmYVPWb2S", "ccDJKeFfbXI:APA91bHJWgGUmBzGv1mQ4Kny7VRf5EnF4GHYMSKE95TqKJsrLSp0djopYmJ4lAXm-jfQZBfIXs_mMWtp75Ov0uhzNPbLMfck_EExWnvwRDvUXmWIaFyiJuOPbOsoXwilHBojak9Lb93E"],"notification":{"title":"Irina kan stille som barnevakt","body":"14:00 - 22:00 i morgen","sound":"bingbong.aiff","badge":1},"priority":10, "content_available": true, "mutable_content": true }' https://fcm.googleapis.com/fcm/send
 
 // Irina with nannyAccept
 curl -H "Content-type: application/json" -H "Authorization:key=AAAAd-nNctg:APA91bGhfGrYaRg-QOHx0LlfTyqU9cwOECMvm6jGHMZaeLGsToNPJtgV0y-EfcmMVFZbfbxdkF3ubJ8NC94-B-I74lV-UG2f-kuvjLtOnG_wbHecjdBc93Y59tv7XCJCEXEW3hTKH4oC"  -X POST -d '{ "data": { "category": "nannyAccept","mediaUrl": "https://video-images.vice.com/articles/58dbd4fdd229e46c744447aa/lede/1490802358036-Sovereign-Syre-by-Richard-Avery-2.jpeg?crop=0.9491787439613527xw:1xh;center,center&resize=525:*"},"registration_ids" : ["fgeEPLe_WC8:APA91bHCGbXHYkF8FLlzu63HefA5yoTJTr2SwJNJ_kfyUdCUBuPZdeRUtT0cVFvsp8AAgWqByWHigElq98GNV-kCu1gZCK9Nut3WyEn4xgchUZ3fT8uGExdN12iUexkkRwUhmYVPWb2S", "ccDJKeFfbXI:APA91bHJWgGUmBzGv1mQ4Kny7VRf5EnF4GHYMSKE95TqKJsrLSp0djopYmJ4lAXm-jfQZBfIXs_mMWtp75Ov0uhzNPbLMfck_EExWnvwRDvUXmWIaFyiJuOPbOsoXwilHBojak9Lb93E"],"notification":{"title":"Irina kan stille som barnevakt","body":"14:00 - 22:00 i morgen","sound":"bingbong.aiff","badge":1},"priority":10, "content_available": true, "mutable_content": true }' https://fcm.googleapis.com/fcm/send
 
 // Sender with messageRequest
 curl -H "Content-type: application/json" -H "Authorization:key=AAAAd-nNctg:APA91bGhfGrYaRg-QOHx0LlfTyqU9cwOECMvm6jGHMZaeLGsToNPJtgV0y-EfcmMVFZbfbxdkF3ubJ8NC94-B-I74lV-UG2f-kuvjLtOnG_wbHecjdBc93Y59tv7XCJCEXEW3hTKH4oC"  -X POST -d '{ "data": { "category": "messageRequest","mediaUrl": "https://graph.facebook.com/10157516443970641/picture?type=large"},"registration_ids" : ["fgeEPLe_WC8:APA91bHCGbXHYkF8FLlzu63HefA5yoTJTr2SwJNJ_kfyUdCUBuPZdeRUtT0cVFvsp8AAgWqByWHigElq98GNV-kCu1gZCK9Nut3WyEn4xgchUZ3fT8uGExdN12iUexkkRwUhmYVPWb2S", "ccDJKeFfbXI:APA91bHJWgGUmBzGv1mQ4Kny7VRf5EnF4GHYMSKE95TqKJsrLSp0djopYmJ4lAXm-jfQZBfIXs_mMWtp75Ov0uhzNPbLMfck_EExWnvwRDvUXmWIaFyiJuOPbOsoXwilHBojak9Lb93E"],"notification":{"title":"Bjarne Tvedten","body":"Nanny Now - Please","sound":"default","badge":1},"priority":10, "content_available": true, "mutable_content": true }' https://fcm.googleapis.com/fcm/send
 */
