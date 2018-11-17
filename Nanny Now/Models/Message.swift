//
//  Message.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 26.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
// import Firebase

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

class Message {
    // Personal information (Private)
    // ------------------------------
    private(set) public var _toUser: User?
    private(set) public var _fromUser: User?
    
    private(set) public var _toUID: String
    private(set) public var _fromUID: String
    
    private(set) public var _imageURL: String?
    private(set) public var _userStatus: Date?
    
    // Service information (Request)
    // -----------------------------
    private(set) public var _messageID: String
    private(set) public var _messageTime: String
    private(set) public var _message: String
    
    private(set) public var _timeBreak: Bool = false
    
    private(set) public var _requestCategory: NotificationCategory = .messageRequest
    private(set) public var _highlighted: Bool = false
    
    var userStatus: Date {
        get {
            guard let userDate = _userStatus else { return stringToDateTime(_messageTime) }
            return userDate
        }
        set {
            self._userStatus = newValue
        }
    }
    
    var messageTime: Date {
        get {
            return stringToDateTime(_messageTime)
        } set {
            self._messageTime = dateTimeToTimeStampString(newValue)
        }
    }
    
    func setMessageID(messageID: String) {
        self._messageID = messageID // DataService.instance.REF_MESSAGES.childByAutoId().key
    }
    
    func setMessage(message: String) {
        self._message = message
    }
    
    func setTo(user: User) {
        self._toUser = user
    }
    
    func setFrom(user: User) {
        self._fromUser = user
    }
    
    func setImageUrl(imageURL: String) {
        self._imageURL = imageURL
    }
    
    func setTimeBreak(timeBreak: Bool) {
        self._timeBreak = timeBreak
    }
    
    func setCategory(category: NotificationCategory) {
        self._requestCategory = category
    }
    
    func setHighlighted(highlighted: Bool) {
        self._highlighted = highlighted
    }
    
    init(from fromUser: User, to toUser: User, message: String, messageID: String? = nil) {
        self._toUser = toUser
        self._fromUser = fromUser
        
        self._toUID = toUser.userUID
        self._fromUID = fromUser.userUID
        
        self._imageURL = fromUser.imageName
        
        self._message = message
        self._messageID = messageID ?? "" // ?? DataService.instance.REF_MESSAGES.childByAutoId().key
        self._messageTime = returnTimeStamp()
        self._highlighted = false
    }
    
    init(from fromUID: String, to toUID: String, messageID: String? = nil, message: String, messageTime: String, highlighted: Bool = true, requestCategory: NotificationCategory? = nil) {
        
        self._toUID = toUID
        self._fromUID = fromUID
        
        self._message = message
        self._messageID = messageID ?? "" //  ?? DataService.instance.REF_MESSAGES.childByAutoId().key
        self._messageTime = messageTime
        
        self._highlighted = highlighted
        self._requestCategory = requestCategory ?? .messageRequest
    }
}

/*
struct MessageStruct {
    // Personal information (Private)
    // ------------------------------
    private(set) public var _toUser: User?
    private(set) public var _fromUser: User?
    
    private(set) public var _toUID: String
    private(set) public var _fromUID: String
    
    private(set) public var _imageURL: String?
    private(set) public var _userStatus: Date?
    
    // Service information (Request)
    // -----------------------------
    private(set) public var _messageID: String
    private(set) public var _messageTime: String
    private(set) public var _message: String
    
    private(set) public var _timeBreak: Bool = false
    
    private(set) public var _requestCategory: NotificationCategory = .messageRequest
    private(set) public var _highlighted: Bool = false
    
    var userStatus: Date {
        get {
            guard let userDate = _userStatus else { return stringToDateTime(_messageTime) }
            return userDate
        }
        set {
            self._userStatus = newValue
        }
    }
    
    var messageTime: Date {
        get {
            return stringToDateTime(_messageTime)
        } set {
            self._messageTime = dateTimeToTimeStampString(newValue)
        }
    }
    
    mutating func setMessageID() {
        self._messageID = DataService.instance.REF_MESSAGES.childByAutoId().key
    }
    
    mutating func setMessage(message: String) {
        self._message = message
    }
    
    mutating func setTo(user: User) {
        self._toUser = user
    }
    
    mutating func setFrom(user: User) {
        self._fromUser = user
    }
    
    mutating func setImageUrl(imageURL: String) {
        self._imageURL = imageURL
    }
    
    mutating func setTimeBreak(timeBreak: Bool) {
        self._timeBreak = timeBreak
    }
    
    mutating func setCategory(category: NotificationCategory) {
        self._requestCategory = category
    }
    
    mutating func setHighlighted(highlighted: Bool) {
        self._highlighted = highlighted
    }
    
    init(from fromUser: User, to toUser: User, message: String, messageID: String? = nil) {
        self._toUser = toUser
        self._fromUser = fromUser
        
        self._toUID = toUser.userUID
        self._fromUID = fromUser.userUID
        
        self._imageURL = fromUser.imageName
        
        self._message = message
        self._messageID = messageID ?? DataService.instance.REF_MESSAGES.childByAutoId().key
        self._messageTime = returnTimeStamp()
        self._highlighted = false
    }
    
    init(from fromUID: String, to toUID: String, messageID: String? = nil, message: String, messageTime: String, highlighted: Bool = true, requestCategory: NotificationCategory? = nil) {
        
        self._toUID = toUID
        self._fromUID = fromUID
        
        self._message = message
        self._messageID = messageID ?? DataService.instance.REF_MESSAGES.childByAutoId().key
        self._messageTime = messageTime
        
        self._highlighted = highlighted
        self._requestCategory = requestCategory ?? .messageRequest
    }
    
}
*/

