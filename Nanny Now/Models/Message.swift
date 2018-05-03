//
//  Message.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 26.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import Foundation
import Firebase

struct Message {
    // Personal information (Private)
    // ------------------------------
    private(set) public var _toUser: User
    private(set) public var _fromUser: User
    
    // Service information (Request)
    // -----------------------------
    private(set) public var _messageID: String
    private(set) public var _messageTime: String
    private(set) public var _message: String
    
    private(set) public var _highlighted: Bool = false
    
    init(from fromUser: User, to toUser: User, message: String) {
        self._toUser = toUser
        self._fromUser = fromUser
        self._message = message
        self._messageID = DataService.instance.REF_MESSAGES.childByAutoId().key
        self._messageTime = returnTimeStamp()
        self._highlighted = false
    }
    
}
