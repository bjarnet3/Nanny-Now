//
//  Request.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 13.12.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

// This should be used in Notifications.swift
public enum RequestStatus : String {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
    case running = "running"
    case complete = "complete"
}

public func requestStatusString(request: String) -> RequestStatus? {
    return RequestStatus(rawValue: request)
}

struct Request {
    
    // Personal information (Private)
    // ------------------------------
    private(set) public var _nannyID: String
    private(set) public var _userID: String
    private(set) public var _familyID: String?
    
    private(set) public var _nanny: Nanny?
    private(set) public var _user: User?
    private(set) public var _family: Family?
    
    private(set) public var _imageName: String?
    private(set) public var _firstName: String?
    
    private(set) public var _highlighted: Bool = false
    
    // Service information (Request)
    // -----------------------------
    private(set) public var _requestID: String?
    private(set) public var _requestREF: DatabaseReference
    private(set) public var _requestStatus: RequestStatus = .pending
    private(set) public var _requestCategory: NotificationCategory = .nannyRequest
    
    private(set) public var _timeRequested: Date
    private(set) public var _timeFrom: Date
    private(set) public var _timeTo: Date
    
    private(set) public var _amount: Int = 100
    private(set) public var _amountTotal: Int = 0
    private(set) public var _worktime: Int = 0
    private(set) public var _message: String = ""
    
    // Computed Properties
    // -------------------
    var requestID: String? {
        get { return _requestID }
            set { self._requestID = newValue} }
    
    var requestStatus: String {
        get { return _requestStatus.rawValue }
            set { if let request = requestStatusString(request: newValue) {
                self._requestStatus = request } } }
    
    var requestCategory: String {
        get { return _requestCategory.rawValue }
            set {
                let request = notificationRequest(category: newValue)
                self._requestCategory = request  } }
    
    var highlighted: Bool {
        get { return _highlighted }
            set { self.highlighted = newValue } }
    
    // Personal Information
    // --------------------
    var firstName: String {
        get { guard let name = _firstName else { return "Anonymous" }
            return name
        }
        set {
            self._firstName = newValue
        }
    }
    
    var imageName: String {
        get { guard let imageUrl = _imageName else { return "" }
            return imageUrl
        }
        set {
            self._imageName = newValue
        }
    }
    
    // Identifications
    // ---------------
    var nannyID: String {
        get { return _nannyID }
            set { self._nannyID = newValue } }
    
    var userID: String {
        get { return _userID }
            set { self._userID = newValue } }
    
    var familyID: String {
        get { if let famID = _familyID {
                return famID
            } else {
                return userID } }
        set { self._familyID = newValue } }
    
    // Users & Groups
    // --------------
    var user: User {
        get { return _user! }
        set { self._user = newValue }
    }
    
    var nanny: Nanny {
        get { return _nanny! }
        set { self.nanny = newValue }
    }
    
    var family: Family {
        get { return _family! }
        set { self._family = newValue }
    }
    
    // Time & Date
    // -----------
    var timeRequested: String {
        get { return dateTimeToString(_timeRequested) }
            set { self._timeRequested = stringToDateTime(newValue) } }
    
    var timeFrom: String {
        get { return dateTimeToString(_timeFrom) }
            set { self._timeFrom = stringToDateTime(newValue) } }
    
    var timeTo: String {
        get { return dateTimeToString(_timeTo)  }
            set { self._timeTo = stringToDateTime(newValue) } }
    
    // Price & Money
    // -------------
    var amount: Int {
        get { return _amount }
            set { self._amount = newValue } }
    
    var message: String {
        get {return _message}
            set {self._message = newValue} }
    
    // Initializers
    // ------------
    init(nanny: Nanny, user: User, timeFrom: Date, timeTo: Date, message: String?) {
        self._requestREF = DataService.instance.REF_REQUESTS.childByAutoId()
        self._requestID = self._requestREF.key
        
        self._nanny = nanny
        self._user = user
        
        self._nannyID = nanny.userUID
        self._userID = user.userUID
        self._familyID = user.userUID
        
        self._timeRequested = Date()
        self._timeFrom = timeFrom
        self._timeTo = timeTo
        self._message = message == nil ? "Kan du stille som barnevakt mellom" : message!
    }
    
    init(nannyID: String, userID: String, familyID: String, timeFrom: String, timeTo: String, message: String? ) {
        self._requestREF = DataService.instance.REF_REQUESTS.childByAutoId()
        self._requestID = self._requestREF.key
        
        self._nannyID = nannyID
        self._userID = userID
        // self._familyID = userID
        self._familyID = familyID
        
        self._timeRequested = Date()
        self._timeFrom = stringToDateTime(timeFrom)
        self._timeTo = stringToDateTime(timeTo)
        self._message = message == nil ? "Kan du stille som barnevakt mellom" : message!
    }
    
    init(requestID: String, nannyID: String, userID: String, familyID: String, highlighted: Bool, timeRequested: String, timeFrom: String, timeTo: String, message: String?, requestAmount: Int, requestStatus: String, requestCategory: String, requestREF: DatabaseReference) {
        
        self._requestREF = requestREF   // DataService.instance.REF_REQUESTS.childByAutoId()
        self._requestID = requestID     // self._requestREF.key
        
        self._nannyID = nannyID
        self._userID = userID
        // self._familyID = userID
        self._familyID = familyID
        
        self._highlighted = highlighted
        
        self._timeRequested = stringToDateTime(timeRequested) // stringToDate(timeRequested)
        self._timeFrom = stringToDateTime(timeFrom) // stringToDate(timeFrom)
        self._timeTo = stringToDateTime(timeTo)

        self._message = message == nil ? "Kan du stille som barnevakt mellom" : message!
        self._amount = requestAmount
        self._requestStatus = requestStatusString(request: requestStatus)!
        self._requestCategory = notificationRequest(category: requestCategory)
    }
    
    
}
