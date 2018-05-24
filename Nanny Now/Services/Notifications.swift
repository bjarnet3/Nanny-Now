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

var sendNotification = Notifications.instance.sendNotification

/// Defination of category types will come here !!
public enum NotificationCategory : String {
    case nannyRequest = "nannyRequest"
    case nannyMapRequest = "nannyMapRequest"
    case nannyAccept = "nannyAccept"
    case nannyConfirmed = "nannyConfirmed"
    case nannyReject = "nannyReject"
    
    case familyRequest = "familyRequest"
    case familyAccept = "familyAccept"
    case familyMapAccept = "familyMapAccept"
    case familyConfirmed = "familyConfirmed"
    case familyReject = "familyReject"
    
    case messageRequest = "messageRequest"
    case messageAccept = "messageAccept"
    
    case defaultValue = "default"
}

public func notificationRequest(category: String) -> NotificationCategory {
    guard let notificaitonCategory = NotificationCategory(rawValue: category) else { return NotificationCategory.defaultValue }
    return notificaitonCategory
}

/// Notification Singleton / with sendNotification() and sendNotificationResponse() function
class Notifications {
    
    // Create singleton of Notification Class "itself"
    static let instance = Notifications()
    
    func sendNotifications(with message: Message) {
        let remoteID = message._toUser?.userUID ?? message._toUID
        let text = message._message
        let categoryRequest: NotificationCategory = message._requestCategory
        let requestID = message._messageID
        
        let url = NSURL(string: "https://fcm.googleapis.com/fcm/send")!
        let session = URLSession.shared
        
        let urlRequest = NSMutableURLRequest(url: url as URL)
        urlRequest.httpMethod = "POST"
        urlRequest.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        guard let userID = KeychainWrapper.standard.string(forKey: KEY_UID) else {
            return
        }
        
        let nameRef = DataService.instance.REF_USERS_PRIVATE.child(userID).child("first_name")
        nameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if !snapshot.exists() { return }
            
            if snapshot.key == "first_name" {
                let firstName = snapshot.value as! String
                // print(snapshot.value as! String)
                
                let fidREF = DataService.instance.REF_USERS_PRIVATE.child(userID).child("fid")
                fidREF.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if !snapshot.exists() { return }
                    
                    if snapshot.key == "fid" {
                        let id = snapshot.value as! String
                        
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
                                    let title = "\(firstName)"
                                    
                                    // MARK: - Change this to display different Notificaiton Categories
                                    let category = categoryRequest.rawValue // "messageRequest"
                                    
                                    switch categoryRequest {
                                    case .messageRequest:
                                        // title = "Melding fra \(firstName):"
                                        DataService.instance.postToMessage(recieveUserID: remoteID, message: "\(text)")
                                    case .messageAccept:
                                        // title = "Melding fra \(firstName):"
                                        DataService.instance.postToMessage(recieveUserID: remoteID, message: "\(text)")
                                    default:
                                        print("default")
                                    }
                                    // DataService.instance.postToMessage(with: message)
                                    
                                    // For Advanced Rich Notificaiton Setup
                                    let remoteURL = message._toUser?.imageName ?? getFacebookProfilePictureUrl(id, .large)
                                    let userURL = message._fromUser?.imageName ?? "userUrl"
                                    
                                    let dictionary =
                                        ["data":
                                            [ "category": category,
                                              "requestID": requestID,
                                              
                                              "remoteURL": remoteURL,
                                              "userURL": userURL,
                                              
                                              "remoteID": remoteID,
                                              "userID"  : userID ],
                                         "registration_ids" : registration_ids,
                                         "notification":
                                            ["title" : title,
                                             "body"  : text,
                                             "sound" : "notification48.wav",
                                             "badge" : badge],
                                         "priority":10,
                                         // "content_available": true,
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
    
    func sendNotifications(with request: Request) {
        let remoteID = request.nannyID
        let text = request.message
        let categoryRequest: NotificationCategory = NotificationCategory(rawValue: request.requestCategory)!
        let requestID = request.requestID
        
        let url = NSURL(string: "https://fcm.googleapis.com/fcm/send")!
        let session = URLSession.shared
        
        let urlRequest = NSMutableURLRequest(url: url as URL)
        urlRequest.httpMethod = "POST"
        urlRequest.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        guard let userID = KeychainWrapper.standard.string(forKey: KEY_UID) else {
            return
        }
        
        let nameRef = DataService.instance.REF_USERS_PRIVATE.child(userID).child("first_name")
        nameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if !snapshot.exists() { return }
            
            if snapshot.key == "first_name" {
                let firstName = snapshot.value as! String
                // print(snapshot.value as! String)
                
                let idRef = DataService.instance.REF_USERS_PRIVATE.child(userID).child("fid")
                idRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if !snapshot.exists() { return }
                    
                    if snapshot.key == "fid" {
                        let id = snapshot.value as! String
                        
                        var tokens = [String]()
                        var tokenRef = DataService.instance.REF_USERS_PRIVATE.child(remoteID).child("tokens")
                        
                        
                        switch categoryRequest {
                        case .nannyRequest:
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
                                    
                                    let remoteLat = 60.1890322
                                    let remoteLong = 5.9254423
                                    
                                    let userLat = 60.12424245
                                    let userLong = 5.4343453
                                    
                                    // Get tokens from Database
                                    let registration_ids = tokens
                                    let message = text
                                    var title = "\(firstName)"
                                    var requestID = requestID
                                    
                                    // MARK: - Change this to display different Notificaiton Categories
                                    let category = categoryRequest.rawValue // "messageRequest"
                                    
                                    switch categoryRequest {
                                    case .nannyRequest:
                                        title = "Forespørsel fra \(firstName):"
                                        
                                        let requestREFID = DataService.instance.REF_REQUESTS.childByAutoId()
                                        requestID = requestREFID.key
                                        
                                        let publicRequest = DataService.instance.REF_REQUESTS.child("public").child(remoteID).child(requestID)
                                        
                                        DataService.instance.postToRequest(with: request, reference: publicRequest)
                                        
                                        let setUserID = ["userID" : userID,
                                                         "requestID": requestID
                                                         ]
                                        publicRequest.updateChildValues(setUserID)
                                        
                                        let privateRequest = DataService.instance.REF_REQUESTS.child("private").child(userID).child("requests").child(requestID)
                                        
                                        DataService.instance.postToRequest(with: request, reference: privateRequest)
                                        
                                        let setRemoteID = ["userID" : remoteID,
                                                           "requestID": requestID
                                                           ]
                                        privateRequest.updateChildValues(setRemoteID)
                                        
                                        let familyPrivate = DataService.instance.REF_FAMILIES.child("private").child(userID)
                                        let familyStored = DataService.instance.REF_FAMILIES.child("stored").child(remoteID).child(userID)
                                        DataService.instance.copyValuesFromRefToRef(fromReference: familyPrivate, toReference: familyStored)
                                        
                                    case .nannyMapRequest:
                                        print("testing mapRequest")
                                        
                                    case .nannyAccept:
                                        title = "\(firstName)"
                                        // DataService.instance.postToMessage(recieveUserID: remoteID, message: "\(message)")
                                        // category = "default"
                                        
                                    case .nannyConfirmed:
                                        title = "Barnevakten \(firstName):"
                                        
                                        let publicRequest = DataService.instance.REF_REQUESTS.child("public").child(requestID)
                                        publicRequest.child("nannyID").removeValue()
                                        
                                    case .nannyReject:
                                        title = "\(firstName)"

                                    case .familyRequest:
                                        print("familyRequest")
                                    case .familyAccept:
                                        print("familyAccept")
                                    case .familyMapAccept:
                                        print("familyMapAccept")
                                    case .familyConfirmed:
                                        print("familyConfirmed")
                                    case .familyReject:
                                        print("familyReject")
                                        
                                    default:
                                        title = "\(firstName)"
                                        // DataService.instance.postToMessage(recieveUserID: remoteID, message: "\(title): \(message)")
                                    }
                                    
                                    // For Advanced Rich Notificaiton Setup
                                    let remoteURL = request._nanny?.imageName ?? getFacebookProfilePictureUrl(id, .large)
                                    guard let userURL = request._user?.imageName else { return }
                                    
                                    let dictionary =
                                        ["data":
                                            [ "category": category,
                                              "requestID": requestID,
                                              
                                              "remoteID": remoteID,
                                              "remoteURL": remoteURL,
                                              "remoteLat": remoteLat,
                                              "remoteLong": remoteLong,
                                              
                                              "userID"  : userID,
                                              "userURL": userURL,
                                              "userLat": userLat,
                                              "userLong": userLong ],
                                         "registration_ids" : registration_ids,
                                         "notification":
                                            ["title" : title,
                                             "body"  : message,
                                             "sound" : "notification11.wav",
                                             "badge" : badge],
                                         "priority":10,
                                         // "content_available": true,
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
    
    func sendNotification(to remoteID: String, text: String, categoryRequest: NotificationCategory,_ requestID: String = "") {
        
        let url = NSURL(string: "https://fcm.googleapis.com/fcm/send")!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        guard let userID = KeychainWrapper.standard.string(forKey: KEY_UID) else {
            return
        }
        
        let nameRef = DataService.instance.REF_USERS_PRIVATE.child(userID).child("first_name")
        nameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if !snapshot.exists() { return }
            
            if snapshot.key == "first_name" {
                let firstName = snapshot.value as! String
                // print(snapshot.value as! String)
                
                let idRef = DataService.instance.REF_USERS_PRIVATE.child(userID).child("fid")
                idRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if !snapshot.exists() { return }
                    
                    if snapshot.key == "fid" {
                        let id = snapshot.value as! String
                        
                        var tokens = [String]()
                        var tokenRef = DataService.instance.REF_USERS_PRIVATE.child(remoteID).child("tokens")
                        
                        switch categoryRequest {
                        case .nannyRequest:
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
                                    
                                    // Get tokens from Database
                                    let registration_ids = tokens
                                    let message = text
                                    var title = "\(firstName)"
                                    var requestID = requestID
                                    
                                    // MARK: - Change this to display different Notificaiton Categories
                                    let category = categoryRequest.rawValue // "messageRequest"
                                    
                                    switch categoryRequest {
                                    case .nannyRequest:
                                        title = "Forespørsel fra \(firstName):"
                                        
                                        let requestREFID = DataService.instance.REF_REQUESTS.childByAutoId()
                                        requestID = requestREFID.key
                                        
                                        let nannyRequest = DataService.instance.REF_REQUESTS.child("public").child(requestID)
                                        DataService.instance.postToTheRequest(recieveUserID: remoteID, requestID: requestID, message: message, status: "pending", reference: nannyRequest)
                                        
                                        let familyPrivate = DataService.instance.REF_FAMILIES.child("private").child(userID)
                                        let familyStored = DataService.instance.REF_FAMILIES.child("stored").child(remoteID).child(userID)
                                        DataService.instance.copyValuesFromRefToRef(fromReference: familyPrivate, toReference: familyStored)
                                        
                                        let privateUsers = DataService.instance.REF_REQUESTS.child("private").child(userID).child("users").child(remoteID)
                                        let privateRequest = DataService.instance.REF_REQUESTS.child("private").child(userID).child("requests").child(requestID)
                                        
                                        DataService.instance.copyValuesFromRefToRef(fromReference: nannyRequest, toReference: privateUsers)
                                        DataService.instance.copyValuesFromRefToRef(fromReference: nannyRequest, toReference: privateRequest)
                                        
                                        let nannyID = ["userID" : remoteID]
                                        privateRequest.updateChildValues(nannyID)
                                        privateUsers.updateChildValues(nannyID)
                                        
                                    case .nannyMapRequest:
                                        print("nannyMapRequest")
                                        
                                    case .nannyAccept:
                                        title = "\(firstName)"
                                        // DataService.instance.postToMessage(recieveUserID: remoteID, message: "\(message)")
                                    // category = "default"
                                    case .nannyConfirmed:
                                        title = "Barnevakten \(firstName):"
                                        
                                        let publicRequest = DataService.instance.REF_REQUESTS.child("public").child(requestID)
                                        publicRequest.child("nannyID").removeValue()
                                    
                                    case .nannyReject:
                                        print("nannyReject")
                                        
                                        
                                    case .messageRequest:
                                        title = "Melding fra \(firstName):"
                                        DataService.instance.postToMessage(recieveUserID: remoteID, message: "\(title) \(message)")
                                    
                                    case .messageAccept:
                                        title = "Melding fra \(firstName):"
                                        DataService.instance.postToMessage(recieveUserID: remoteID, message: "\(title) \(message)")

                                    default:
                                        title = "\(firstName)"
                                        // DataService.instance.postToMessage(recieveUserID: remoteID, message: "\(title): \(message)")
                                    }
                                    
                                    // For Advanced Rich Notificaiton Setup
                                    let remoteURL = getFacebookProfilePictureUrl(id, .large)
                                    
                                    let dictionary =
                                        ["data":
                                            [ "category": category,
                                              "remoteURL": remoteURL,
                                              "requestID": requestID,
                                              "remoteID": remoteID,
                                              "userID"  : userID ],
                                         "registration_ids" : registration_ids,
                                         "notification":
                                            ["title" : title,
                                             "body"  : message,
                                             "sound" : "notification11.wav",
                                             "badge" : badge],
                                         "priority":10,
                                         // "content_available": true,
                                            "mutable_content": true,
                                            "category" : category
                                            ] as [String : Any]
                                    
                                    do {
                                        try request.httpBody = JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
                                    }
                                    catch {}
                                    
                                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                    request.addValue("key=AAAAd-nNctg:APA91bGhfGrYaRg-QOHx0LlfTyqU9cwOECMvm6jGHMZaeLGsToNPJtgV0y-EfcmMVFZbfbxdkF3ubJ8NC94-B-I74lV-UG2f-kuvjLtOnG_wbHecjdBc93Y59tv7XCJCEXEW3hTKH4oC", forHTTPHeaderField: "Authorization")
                                    
                                    let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
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
    
    // SHIT THIS IS MESSY,, but it works: YAHOO
    func sendNotificationResponse(userID: String, remoteID: String, title: String, text: String, categoryRequest: NotificationCategory) {
        
        let url = NSURL(string: "https://fcm.googleapis.com/fcm/send")!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        let registration_ids = ["fgeEPLe_WC8:APA91bHCGbXHYkF8FLlzu63HefA5yoTJTr2SwJNJ_kfyUdCUBuPZdeRUtT0cVFvsp8AAgWqByWHigElq98GNV-kCu1gZCK9Nut3WyEn4xgchUZ3fT8uGExdN12iUexkkRwUhmYVPWb2S", "ccDJKeFfbXI:APA91bHJWgGUmBzGv1mQ4Kny7VRf5EnF4GHYMSKE95TqKJsrLSp0djopYmJ4lAXm-jfQZBfIXs_mMWtp75Ov0uhzNPbLMfck_EExWnvwRDvUXmWIaFyiJuOPbOsoXwilHBojak9Lb93E"]
        
        // MARK: - Change this to display different Notificaiton Categories
        let category = "nannyAccept" // "messageRequest"
        
        // For Advanced Rich Notificaiton Setup
        let remoteURL = getFacebookProfilePictureUrl("100753693854368", .large)
        
        let dictionary =
            ["data":
                [ "category": category,
                  "remoteURL": remoteURL,
                  "remoteID": remoteID,
                  "userID" : userID ],
             "registration_ids" : registration_ids,
             "notification":
                ["title":title,
                 "body":text,
                 "sound": "default",
                 "badge" : 1],
             "priority":10,
             // "content_available": true,
                "mutable_content": true,
                "category" : category
            ] as [String : Any]
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        }
        catch {}
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("key=AAAAd-nNctg:APA91bGhfGrYaRg-QOHx0LlfTyqU9cwOECMvm6jGHMZaeLGsToNPJtgV0y-EfcmMVFZbfbxdkF3ubJ8NC94-B-I74lV-UG2f-kuvjLtOnG_wbHecjdBc93Y59tv7XCJCEXEW3hTKH4oC", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var json = NSDictionary()
            do { json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary } catch {}
            let parseJSON = json
            _ = parseJSON["success"] as? Int
        })
        task.resume()
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
