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
    private(set) public var _members: [String:String]?
    private(set) public var _member: [User]?
    private(set) public var _kids: [String:Int]?
    
    // Feedback
    // --------
    private(set) public var _ratings: [String:Int]?
    
    // Location
    // --------
    private(set) public var _location: CLLocation?
    
    // Family information (Public)
    // ---------------------------
    public var _locations: [String:CLLocation]?
    public var _distance: Double?
    
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
    
    // Options Configurations
    // ----------------------
    func setAnnotation() {
        self.title = self._familyName
        self.subtitle = self.ratingStar
        self.coordinate = (self.location?.coordinate)!
    }
    
    // NOT TESTED YET
    func setMembers() {
        for (uid, name) in _members! {
            let userREF = DataService.instance.REF_USERS_PRIVATE.child(uid)
            userREF.observeSingleEvent(of: .value) { snapshot in
                if let imageURL = snapshot.value as? String {
                    print(imageURL)
                    let user = User(userUID: uid, imageName: imageURL, firstName: name)
                    self._member?.append(user)
                }
            }
        }
    }
    
    // Initializers
    // ------------
}

@available(iOS, deprecated, message: "Use Family Class instead")
class Families : MKPointAnnotation {
    
    // Personal information (Private)
    private var _imageName: String?
    private var _userName: String?
    private var _firstName: String? // first_name from Facebook
    private var _lastName: String?
    private var _gender: String?
    private var _birthday: String?
    private var _yrke: String?
    
    private var _hasPoliceAttest: Bool?
    private var _familyMembers: [User]?
    
    private var _location: CLLocation? // Latitude , Longitude
    private var _distance: Double?
    private var _userID: String?
    private var _ratings: [String:Int]?
    
    private var _requestStart: Date?
    private var _requestStartString: String?
    private var _requestStop: Date?
    private var _requestAmount: Int?
    
    // Computed Properties
    var userName: String { return _userName! }
    var firstName: String { return _firstName! }
    var lastName: String { return _lastName! }
    var location: CLLocation { get { return _location! } set { _location = newValue } }
    var distance: Double { get { return _distance ?? 0 } set { _distance = newValue } }
    var imageName: String { get { return _imageName! } set { _imageName = newValue } }
    var gender: String {
        switch _gender! {
        case "female":
            return "Kvinne"
        case "male":
            return "Mann"
        default:
            return "Annet"
        }
    }
    
    var genderImage: String {
        switch _gender! {
        case "female":
            return "pin_f.png"
        case "male":
            return "pin_m.png"
        default:
            return "pin_f.png"
        }
    }
    
    var hasPoliceAttest: Bool { return _hasPoliceAttest! }
    var userID: String { return _userID! }
    // var activateNanny: Bool { get { return _activateNanny! } set { _activateNanny = newValue } }

    var requestStart: String {
        return (_requestStartString)!
    }
    
    var requestAmount: String {
        if _requestAmount != nil {
            return String(describing: _requestAmount!)
        } else {
            return "Not set"
        }
    }
    
    var intDistance: Int {
        if _distance == nil {
            return 8888
        } else {
            return Int(_distance!)
        }
    }
    
    func returnDistanceString() -> String {
        let dist = Double(Double(intDistance) / 1000.0)
        let formatedDistance = String(format: "%.1f", dist)
        
        switch intDistance
        {
        case 0..<50:
            return "50 m"
        case 50..<100:
            return "100 m"
        case 100..<250:
            return "250 m"
        case 250..<500:
            return "500 m"
        case 500..<750:
            return "750 m"
        case 750..<950:
            return "950 m"
        default:
            return "\(formatedDistance) km"
        }
    }
    
    func calculateRatings() -> Double {
        if _ratings != nil {
            var count: Int = 0
            var total: Int = 0
            for (_, vote) in _ratings! {
                count += 1
                total += vote
            }
            let result = Double(total) / Double(count)
            return result
        } else {
            return 0.0
        }
    }
    
    var ratingStar: String {
        return returnStarsStringFrom(calculateRatings())
    }
    
    var age: String {
        return calcAge(birthday: _birthday!)
    }
    
    // Initializers
    init(imageName: String?, birthday: String?, userName: String?, firstName: String?, lastName: String?, genderImage: String?, gender: String?, yrke: String?, isApproved: Bool?, latitude: Double?, longitude: Double?, /* activateNanny: Bool?, */ userID: String, ratings: [String:Int]? = nil, start: String, amount: Int) {
        _imageName = imageName
        _birthday = birthday
        _userName = userName
        _firstName = firstName
        _lastName = lastName
        _gender = gender
        _yrke = yrke
        _hasPoliceAttest = isApproved
        _location = CLLocation(latitude: latitude!, longitude: longitude!)
        _userID = userID
        _ratings = ratings
        _requestStartString = start
        _requestAmount = amount
    }
    
    init(user: User) {
        _imageName = user.imageName
        _birthday = user.birthday
        _userName = user.firstName
        _firstName = user.firstName
        _ratings = user._ratings
        _gender = "male"
        _yrke = user.jobTitle
        _hasPoliceAttest = false
    }
}

