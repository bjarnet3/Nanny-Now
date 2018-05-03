//
//  Message.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 26.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import Foundation

struct Message {
    // Personal information (Private)
    // ------------------------------
    private(set) public var _fromUID: String
    private(set) public var _toUID: String
    
    private(set) public var _highlighted: Bool = false
    
    // Service information (Request)
    // -----------------------------
    private(set) public var _messageID: String
    private(set) public var _messageDate: Date
    private(set) public var _message: String = ""
}
