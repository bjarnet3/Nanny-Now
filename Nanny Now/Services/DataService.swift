//
//  DataService.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 20.10.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit
import MapKit
// Firebase Part 3
import Firebase
// Facebook Part 4
import FBSDKCoreKit
import FBSDKLoginKit
// KeychainWrapper
import SwiftKeychainWrapper

let DB_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()

public enum Service {
    case Facebook
    case Firebase
    case All
}

public enum State: String {
    case active = "active"
    case inactive = "inactive"
    case foreground = "foreground"
    case background = "background"
    case terminate = "terminate"
}

public func returnState(state: String) -> State? {
    return State(rawValue: state)
}

/// DataService Singleton / Database and Datastorage References to Firebase
class DataService {
    static let instance = DataService()
    
    // DB references // ROOT
    private var _REF_BASE = DB_BASE
    
    // DB child references // Base "folders"
    private var _REF_AI = DB_BASE.child("AI")
    
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_FRIENDS = DB_BASE.child("friends")
    
    private var _REF_NANNIES = DB_BASE.child("nannies")
    private var _REF_FAMILIES = DB_BASE.child("families")
    
    private var _REF_REQUESTS = DB_BASE.child("requests")
    private var _REF_MESSAGES = DB_BASE.child("messages")
    
    // Storage references
    private var _REF_PROFILE_IMAGES = STORAGE_BASE.child("profile-images")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    // REF AI
    var REF_AI: DatabaseReference {
        return _REF_AI
    }
    
    // REF USERS
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_USERS_PRIVATE: DatabaseReference {
        return _REF_USERS.child("private")
    }
    
    var REF_USERS_PUBLIC: DatabaseReference {
        return _REF_USERS.child("public")
    }
    
    // REF FRIENDS
    var REF_FRIENDS: DatabaseReference {
        return _REF_FRIENDS
    }
    
    var REF_NANNIES: DatabaseReference {
        return _REF_NANNIES
    }
    
    var REF_NANNIES_ACTIVE: DatabaseReference {
        return _REF_NANNIES.child("active")
    }
    
    var REF_FAMILIES: DatabaseReference {
        return _REF_FAMILIES
    }
    
    var REF_FAMILIESACTIVE: DatabaseReference {
        return _REF_FAMILIES.child("active")
    }
    
    // REF REQUESTS / MESSAGES
    var REF_REQUESTS: DatabaseReference {
        return _REF_REQUESTS
    }
    
    var REF_MESSAGES: DatabaseReference {
        return _REF_MESSAGES
    }
    
    var REF_USER_CURRENT: DatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS_PRIVATE.child(uid!)
        return user
    }
    
    var REF_PROFILE_IMAGES: StorageReference {
        return _REF_PROFILE_IMAGES
    }
    
    func createFirbaseDBUser(uid: String, userData: [String:String]) {
        // Create or Update "Users / UID / Values"
        REF_USERS_PRIVATE.child(uid).updateChildValues(userData)
    }
    
    func updateUserChildValues(uid: String, userData: [String:Any]) {
        REF_USERS_PRIVATE.child(uid).updateChildValues(userData)
    }
    
    func updatePublicUserChildValues(uid: String, userData: [String:Any]) {
        REF_USERS_PUBLIC.child(uid).updateChildValues(userData)
    }
    
    func updateNannyChildValues(uid: String, userData: [String:Any]) {
        REF_NANNIES_ACTIVE.child(uid).updateChildValues(userData)
    }
    
    func updateUserStatus(with state: State) {
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            let time = returnTimeStamp()
            let state: [String: String] = [
                "state": state.rawValue,
                "status" : time
            ]
            let publicREF = REF_USERS_PUBLIC
            publicREF.child(userID).child("status").updateChildValues(state)
            
            let privateREF = REF_USERS_PRIVATE
            privateREF.child(userID).updateChildValues(state)
        }
    }
    
    func removeUserChildValues(uid: String) {
        REF_USERS_PRIVATE.child(uid).removeValue()
    }

    func removeReferenceChildValues(uid: String, reference: DatabaseReference) {
        reference.child(uid).removeValue()
    }

    func clearBadge() {
        DispatchQueue.main.async(execute: {
            UIApplication.shared.applicationIconBadgeNumber = 0
        })
        updateBadge(for: 0)
    }
    
    func updateBadge(for value: Int) {
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            let badge = ["badge" : value]
            updateUserChildValues(uid: userID, userData: badge)
        } else {
            printDebug(object: "clearBadge couldn't get userID from KeychainWrapper")
        }
    }

    func updateLocationAndPostcodeOnUser(from location: CLLocation, userID: String) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            guard let postalCode = placemarks?[0].postalCode else {
                return
            }
            if let postCode = Int(postalCode) {
                let post: [String:Any] = [
                    "longitude" : location.coordinate.longitude,
                    "latitude"  : location.coordinate.latitude,
                    "zip" : postCode
                ]
                DataService.instance.REF_USERS_PRIVATE.child(userID).child("location").child("current").updateChildValues(post)
            }
        })
    }
    
    /**
     Calculate Center Position From Array Of Locations
     
     - Parameter fid: Facebook ID
     - Parameter size: Facebook Size
     - Return : Facebook Image
     
     */
    @available(iOS, deprecated, message: "Use imageView.loadFacebookImageUsingCache() instead")
    func getFacebookProfilePicture(_ fid: String, _ size: PictureSize) -> UIImage {
        var facebookImage = UIImage(named: "40B52118-FA0A-4978-8A6F-47A5E2137F95")
        if (fid != "") {
            // let imgURLString = "https://graph.facebook.com/10157516443970641/picture?type=large"
            let imgURLString = "https://graph.facebook.com/" + fid + "/picture?type=\(size)"
            
            let imgURL = NSURL(string: imgURLString)
            let imageData = NSData(contentsOf: imgURL! as URL)
            if let image = UIImage(data: imageData! as Data) {
                facebookImage = image
            }
        }
        return facebookImage!
    }

    func getFacebookProfilePictureURL(_ fid: String, _ size: PictureSize) -> String {
        return "https://graph.facebook.com/" + fid + "/picture?type=\(size)"
    }
    
    func postToMessage(with message: Message) {
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            let remoteID = message._toUser?.userUID ?? message._toUID
            let messageREF = DataService.instance.REF_MESSAGES
            let messageID = message._messageID
            
            let baseFirebase = messageREF.child("private").child(remoteID)
            let reciFirebase = messageREF.child("private").child(userID)
            
            let timeStamp = returnTimeStamp()
            
            let base : [String : Any] = [
                "message"   : message,
                "messageID" : messageID,
                "messageTime": timeStamp,
                "toUID"     : remoteID,
                "fromUID"   : userID,
                "highlighted" : false
            ]
            
            baseFirebase.child("last").child(userID).updateChildValues(base)
            reciFirebase.child("last").child(remoteID).updateChildValues(base)
            
            let all : [String : Any] = [
                messageID : base
            ]
            
            baseFirebase.child("all").updateChildValues(all)
            reciFirebase.child("all").updateChildValues(all)
        }
    }
    
    // MARK: - NEW - BUT NEED TO BE IMPROVED
    func postToMessage(recieveUserID: String, message: String) {
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            
            let messageREF = DataService.instance.REF_MESSAGES
            let messageID = messageREF.childByAutoId().key
            
            let baseFirebase = messageREF.child("private").child(userID)
            let reciFirebase = messageREF.child("private").child(recieveUserID)
            
            let timeStamp = returnTimeStamp()
            
            let base : [String : Any] = [
                "message"   : message,
                "messageID" : messageID,
                "messageTime": timeStamp,
                "toUID"     : recieveUserID,
                "fromUID"   : userID,
                "highlighted" : true
            ]
            
            let myBase : [String : Any] = [
                "message"   : "Du: \(message)",
                "messageID" : messageID,
                "messageTime": timeStamp,
                "toUID"     : recieveUserID,
                "fromUID"   : userID,
                "highlighted" : true
            ]
            
            let all : [String : Any] = [
                messageID : base
            ]
            
            if userID == recieveUserID {
                baseFirebase.child("last").child(recieveUserID).updateChildValues(myBase)
                baseFirebase.child("all").updateChildValues(all)
            } else {
                baseFirebase.child("last").child(recieveUserID).updateChildValues(myBase)
                reciFirebase.child("last").child(userID).updateChildValues(base)
                
                baseFirebase.child("all").updateChildValues(all)
                reciFirebase.child("all").updateChildValues(all)
            }
        }
    }
    
    func postToRequest(with request: Request, reference: DatabaseReference) {
            let requestREF = reference
            let requestID = request.requestID ?? reference.childByAutoId().key
            
            let requestValues : [String : Any] = [
                "highlighted" : request.highlighted,
                "familyID": request.familyID,
                "nannyID" : request.nannyID,
                "requestAmount" : request.amount,
                "requestCategory" : request.requestCategory,
                "requestDate" : request.timeRequested,
                "requestID": requestID,
                "requestMessage" : request.message,
                "requestStatus" : request.requestStatus,
                "requestType" : request.requestCategory,
                "timeFrom" : request.timeFrom,
                "timeTo": request.timeTo
            ]
        requestREF.updateChildValues(requestValues)
    }
    
    // MARK: - Post to Request
    func postToTheRequest(recieveUserID: String, requestID: String, message: String, status: String, reference: DatabaseReference) {
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            
            let timeStamp = returnTimeStamp()
            let request = reference
            
            let requestValues : [String : Any] = [
                "highlighted" : true,
                "familyID": userID,
                "nannyID" : recieveUserID,
                "requestAmount" : "250",
                "requestDate" : timeStamp,
                "requestID": requestID,
                "requestMessage" : message,
                "requestStatus" : status,
                "requestType" : "Nanny",
                "timeFrom" : "fromTime",
                "timeTo": "toTime"
            ]
            request.updateChildValues(requestValues)
        }
    }
    
    func postToTheRequest(recieveUserID: String, requestID: String, timeFrom: Date, timeTo: Date, message: String, status: String, reference: DatabaseReference) {
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            
            let timeFrom = returnDayTimeString(from: timeFrom)
            let timeTo = returnDayTimeString(from: timeTo, day: true)
            
            let timeStamp = returnTimeStamp()
            let request = reference
            
            let requestValues : [String : Any] = [
                "highlighted" : true,
                "familyID": userID,
                "nannyID" : recieveUserID,
                "requestAmount" : "250",
                "requestDate" : timeStamp,
                "requestID": requestID,
                "requestMessage" : message,
                "requestStatus" : status,
                "requestType" : "Nanny",
                "timeFrom" : timeFrom,
                "timeTo": timeTo
            ]
            request.updateChildValues(requestValues)
        }
    }
    
    func block(userID blockedUserID: String, blockedName: String) {
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            
            // Add To Private Blocklist - My list of blocked (I cannot see User)
            let blockedUser = [blockedUserID:blockedName]
            let privateREF = DataService.instance.REF_USERS_PRIVATE.child(userID).child("blocked")
            privateREF.updateChildValues(blockedUser)
            
            // Add to Public Blocklist - Public list of blocked (User cannot see me)
            let timeStamp = returnTimeStamp()
            let publicBlocked = [userID:timeStamp]
            let publicREF = DataService.instance.REF_USERS_PUBLIC.child(blockedUserID).child("blocked")
            publicREF.updateChildValues(publicBlocked)
        }
    }
    
    func unBlock(userID blockedUserID: String) {
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            let privateREF = DataService.instance.REF_USERS_PRIVATE.child(userID).child("blocked").child(blockedUserID)
            privateREF.removeValue()
            let publicREF = DataService.instance.REF_USERS_PUBLIC.child(blockedUserID).child("blocked").child(userID)
            publicREF.removeValue()
        }
    }
    
    // MARK: - Add Friends To Database
    func addFriendsToDatabase(friends: [String:String]) {
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            
            var userName: String = ""
            var userUID: String = ""
            var userFID: String = ""
            
            var friendsFIDs: [String] = []
            var friendsUserIDs: [String] = []
            
            var uidFriends: [String:String] = [:]
            
            for keys in friends.keys {
                friendsFIDs.append(keys)
            }
            
            DataService.instance.REF_USERS_PRIVATE.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if let userBase = snap.value as? [String: AnyObject] {
                            if let fid = userBase["fid"] as? String {
                                if let friendUID = userBase["userID"] as? String {
                                    if let name = userBase["first_name"] as? String {
                                        if friendUID == userID {
                                            userUID = friendUID
                                            userFID = fid
                                            userName = name
                                        }
                                        if friendsFIDs.contains(fid) {
                                            friendsUserIDs.append(friendUID)
                                            uidFriends[friendUID] = name
                                            print("\(friendUID) - \(name)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    for uid in friendsUserIDs {
                        let userPrivateFID = DataService.instance.REF_USERS_PRIVATE.child(uid).child("friends")
                        userPrivateFID.updateChildValues([userFID:userName])
                        
                        let userPublicUID = DataService.instance.REF_USERS_PUBLIC.child(uid).child("friends")
                        userPublicUID.updateChildValues([userUID:userName])
                    }
                }
                print(uidFriends)
                let uidFirebase = DataService.instance.REF_USERS_PUBLIC.child(userID).child("friends")
                uidFirebase.updateChildValues(uidFriends)
            })
            print(friends)
            let fidFirebase = DataService.instance.REF_USERS_PRIVATE.child(userID).child("friends")
            fidFirebase.updateChildValues(friends)
        }
    }
    
    /*
    func addOldTokenToDatabase(for userID: String) {
        if let refreshedToken = InstanceID.instanceID().token() {
            
            let deviceName = UIDevice.current.name
            // You will get multiple UUID if you have different versions of the application, even with the same phone
            // Unique ID generated from App1 + Device1 = Unique
            let deviceUUID = UIDevice.current.identifierForVendor!.uuidString
            // let deviceNSUUID = NSUUID().description
            // let deviceVendorID = UIDevice.current.identifierForVendor?.description
            
            let tokenUUID = [
                "name"      :   deviceName,
                "token"     :   refreshedToken,
                "date"      :   returnDateStamp()
                // "NSUUID"    :   deviceNSUUID,
                // "VendorID"  :   deviceVendorID
            ]
            
            let tokenREF = DataService.instance.REF_USERS_PRIVATE.child(userID).child("tokens")
            tokenREF.observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() { tokenREF.child(deviceUUID).updateChildValues(tokenUUID) }
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if let userBase = snap.value as? [String: AnyObject] {
                            if let token = userBase["token"] as? String {
                                if token != refreshedToken {
                                    print("token is not equal")
                                    if let device = userBase["name"] as? String, device == deviceName {
                                        print("device name is equal")
                                        tokenREF.child(snap.key).removeValue()
                                        print("removed equel token")
                                    }
                                    print("update Token")
                                    tokenREF.child(deviceUUID).updateChildValues(tokenUUID)
                                }
                            } else {
                                tokenREF.child(snap.key).removeValue()
                                print("no token for \(snap.key)")
                                print(snap.key)
                                tokenREF.child(deviceUUID).updateChildValues(tokenUUID)
                            }
                            
                        }
                    }
                }
                
            })
        }
    }
    */
    
    // Add Token To OldNannies - REMOVE
    func addTokenToDatabase(for userID: String) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let refreshedToken = result?.token {
                print("Remote instance ID token: \(refreshedToken)")
                
                let deviceName = UIDevice.current.name
                // You will get multiple UUID if you have different versions of the application, even with the same phone
                // Unique ID generated from App1 + Device1 = Unique
                let deviceUUID = UIDevice.current.identifierForVendor!.uuidString
                // let deviceNSUUID = NSUUID().description
                // let deviceVendorID = UIDevice.current.identifierForVendor?.description
                
                let tokenUUID = [
                    "name"      :   deviceName,
                    "token"     :   refreshedToken,
                    "date"      :   returnDateStamp()
                    // "NSUUID"    :   deviceNSUUID,
                    // "VendorID"  :   deviceVendorID
                ]
                
                let tokenREF = DataService.instance.REF_USERS_PRIVATE.child(userID).child("tokens")
                tokenREF.observeSingleEvent(of: .value, with: { (snapshot) in
                    if !snapshot.exists() { tokenREF.child(deviceUUID).updateChildValues(tokenUUID) }
                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshot {
                            if let userBase = snap.value as? [String: AnyObject] {
                                if let token = userBase["token"] as? String {
                                    if token != refreshedToken {
                                        print("token is not equal")
                                        if let device = userBase["name"] as? String, device == deviceName {
                                            print("device name is equal")
                                            tokenREF.child(snap.key).removeValue()
                                            print("removed equel token")
                                        }
                                        print("update Token")
                                        tokenREF.child(deviceUUID).updateChildValues(tokenUUID)
                                    }
                                } else {
                                    tokenREF.child(snap.key).removeValue()
                                    print("no token for \(snap.key)")
                                    print(snap.key)
                                    tokenREF.child(deviceUUID).updateChildValues(tokenUUID)
                                }
                                
                            }
                        }
                    }
                    
                })
                
            }
        }
        
    }

    func copyTokenToREF(for userID: String, reference: DatabaseReference) {
        DataService.instance.REF_USERS_PRIVATE.child(userID).child("tokens").observeSingleEvent(of: .value, with: { snapshot in
            let snapshotChildValues = snapshot.value as? [AnyHashable : Any] ?? [:]
            reference.child(userID).child("tokens").updateChildValues(snapshotChildValues)
        })
    }
    
    func copyLocationToREF(for userID: String, fromLocation: String = "current", reference: DatabaseReference) {
        DataService.instance.REF_USERS_PRIVATE.child(userID).child("location").child(fromLocation).observeSingleEvent(of: .value, with: { snapshot in
            let snapshotChildValues = snapshot.value as? [AnyHashable : Any] ?? [:]
            reference.child(userID).updateChildValues(snapshotChildValues)
        })
    }
    
    func copyValuesFromRefToRef(for userID: String, fromReference: DatabaseReference, toReference: DatabaseReference) {
        let from = fromReference.child(userID)
        from.observeSingleEvent(of: .value, with: { snapshot in
            let snapshotChildValues = snapshot.value as? [AnyHashable : Any] ?? [:]
            toReference.child(userID).updateChildValues(snapshotChildValues)
        })
    }
    
    func copyValuesFromRefToRef(fromReference: DatabaseReference, toReference: DatabaseReference) {
        let from = fromReference
        from.observeSingleEvent(of: .value, with: { snapshot in
            let snapshotChildValues = snapshot.value as? [AnyHashable : Any] ?? [:]
            toReference.updateChildValues(snapshotChildValues)
        })
    }
    
    func moveValuesFromRefToRef(fromReference: DatabaseReference, toReference: DatabaseReference) {
        let from = fromReference
        from.observeSingleEvent(of: .value, with: { snapshot in
            let snapshotChildValues = snapshot.value as? [AnyHashable : Any] ?? [:]
            toReference.updateChildValues(snapshotChildValues)
            from.removeValue()
        })
    }
    // ------------------------------------
}
