//
//  Message.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 26.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

struct MessageLite {
    // Personal information (Private)
    // ------------------------------
    private(set) public var _toUser: UserLite?
    private(set) public var _fromUser: UserLite?
    
    private(set) public var _toUID: String
    private(set) public var _fromUID: String
    
    private(set) public var _imageURL: String?
    
    // Service information (Request)
    // -----------------------------
    private(set) public var _message: String
    private(set) public var _messageID: String?
    private(set) public var _messageTime: String
    
    private(set) public var _highlighted: Bool = false
    
    var messageTime: Date {
        get {
            return stringToDateTime(_messageTime)
        } set {
            self._messageTime = dateTimeToTimeStampString(newValue)
        }
    }
    
    mutating func setMessage(message: String) {
        self._message = message
    }
    
    mutating func setTo(user: UserLite) {
        self._toUser = user
    }
    
    mutating func setFrom(user: UserLite) {
        self._fromUser = user
    }
    
    mutating func setImageUrl(imageURL: String) {
        self._imageURL = imageURL
    }
    
    init(from fromUser: UserLite, to toUser: UserLite, message: String, messageID: String? = nil) {
        self._toUser = toUser
        self._fromUser = fromUser
        
        self._toUID = toUser.userUID
        self._fromUID = fromUser.userUID
        
        self._imageURL = fromUser.imageName
        
        self._message = message
        self._messageID = messageID ?? nil
        self._messageTime = returnTimeStamp()
        self._highlighted = false
    }
    
    init(from fromUID: String, to toUID: String, messageID: String? = nil, message: String, messageTime: String, highlighted: Bool = true) {
        
        self._toUID = toUID
        self._fromUID = fromUID
        
        self._message = message
        self._messageID = messageID ?? nil
        self._messageTime = messageTime
        
        self._highlighted = highlighted
    }
    
}
