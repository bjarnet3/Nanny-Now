//
//  Family.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 14.09.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

// Changed from Foundation to UIKit
import UIKit
import MapKit

class Family: MKPointAnnotation {
    
    // Identification
    // --------------
    private(set) public var _familyID: String?
    
    // Family information (Private)
    // ----------------------------
    private(set) public var _familyName: String?
    private(set) public var _members: [User]?
    private(set) public var _unregistered: [Unregistered]?
    private(set) public var _kids: [String:Int]?
    
    // Feedback
    // --------
    private(set) public var _ratings: [String:Int]?
    
    // Location
    // --------
    private(set) public var _location: CLLocation?
    private(set) public var _locations: [String:CLLocation]?
    private(set) public var _distance: Double?
    
    // Computed Properties
    // -------------------
    var familyID: String { return _familyID! }
    var familyName: String { get { return _familyName! } set { _familyName = newValue } }
    
    var ratings: [String:Int]? { get { return _ratings } set { _ratings = newValue } }
    var ratingStar: String { return returnStarsStringFrom(returnAvrageRatings(ratings)) }
    var returnAvrage: Double { return returnAvrageRatings(ratings) }
    var returnDistance: String { return returnStringDistance(from: returnIntDistance) }
    var returnIntDistance: Int { return Int(_distance ?? 8888.0) }
    
    var location: CLLocation? { get { return _location! } set { _location = newValue } }
    var distance: Double { get { return _distance! } set { _distance = newValue } }
    
    // Options Configurations
    // ----------------------
    func setAnnotation() {
        self.title = self._familyName
        self.subtitle = self.ratingStar
        self.coordinate = (self.location?.coordinate)!
    }
    // Initializers
    // ------------
    
    
}

// Unregistered & Temporary / Users
class Unregistered {
    private var _userName: String
    private var _firstName: String?
    private var _lastName: String?
    private var _gender: String?
    private var _imageName: String?
    private var _jobTitle: String?
    
    init(userName: String) {
        self._userName = userName
    }
}

struct Friends {
    var name: String = ""
    var userUID: String = ""
    var imageURL: String = ""
}
