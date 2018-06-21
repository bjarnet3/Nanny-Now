//
//  UserLite.swift
//  NotificationMessageResponse
//
//  Created by Bjarne Tvedten on 21.06.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import MapKit
import CoreLocation

class UserLite : MKPointAnnotation {
    
    // Identification
    // --------------
    private(set) public var _userUID: String?
    
    // Personal information (Private)
    // ------------------------------
    private(set) public var _imageName: String?
    private(set) public var _firstName: String?
    private(set) public var _lastName: String?
    
    private(set) public var _birthday: String?
    private(set) public var _gender: String?
    
    private(set) public var _jobTitle: String?
    private(set) public var _policeAttest: Bool?
    
    private(set) public var _ratings: [String:Int]?
    private(set) public var _location: CLLocation?
    
    // Personal information (Public) - Testing Testing,
    // -----------------------------
    public var _locations: [String:CLLocation]?
    public var _distance: Double?
    public var _status: String?
    
    // Computed Properties
    // -------------------
    var userUID: String { return _userUID! }

    // -------------------
    var imageName: String { get { return _imageName! } set { _imageName = newValue } }
    var firstName: String { get { return _firstName! } set { _firstName = newValue } }
    var lastName: String { return _lastName! }
    
    var birthday: String { get { return _birthday! } set { _birthday = newValue } }
    var gender: String { get { return returnGender(_gender) } set { _gender = newValue } }
    var age: String { return calcAge(birthday: _birthday!) }
    
    var jobTitle: String { get { return _jobTitle! } set { _jobTitle = newValue } }
    var policeAttest: Bool { return _policeAttest! }
    
    var ratings: [String:Int]? { get { return _ratings } set { _ratings = newValue } }
    var ratingStar: String { return returnStarsStringFrom(returnAvrageRatings(ratings)) }
    var returnAvrage: Double { return returnAvrageRatings(ratings) }
    var returnDistance: String { return returnStringDistance(from: returnIntDistance) }
    var returnIntDistance: Int { return Int(_distance ?? 8888.0) }
    
    var location: CLLocation? { get { return _location! } set { _location = newValue } }
    
    // Options Configurations (set)
    // ----------------------------
    func setAnnotation() {
        self.title = self.firstName
        self.subtitle = self.jobTitle
        self.coordinate = (self.location?.coordinate)!
    }
    
    // Options Configurations (get)
    // ----------------------------
    func returnPinImage() -> String {
        switch _gender! {
        case "female":
            return "pin_pink"
        case "male":
            return "pin_orange"
        default:
            return "pin"
        }
    }
    
    // Have to remove this...
    func returnPinColor() -> UIColor {
        switch _gender! {
        case "female":
            return PINK_SOLID
        case "male":
            return ORANGE_SOLID
        default:
            return UIColor.black
        }
    }
    
    // Initializers
    // ------------
    init(userUID: String?, userFID: String? = nil, imageName: String?, firstName: String?, lastName: String?, birthDay: String?, gender: String?, jobTitle: String?, policeAttest: Bool? = nil, location: CLLocation?) {
        self._userUID = userUID
        self._imageName = imageName
        self._firstName = firstName
        self._lastName = lastName
        self._birthday = birthDay
        self._gender = gender
        self._jobTitle = jobTitle
        self._policeAttest = policeAttest
        self._location = location!
    }
    
    init(imageName: String?, firstName: String?, birthDay: String?, jobTitle: String?, ratings: [String:Int]) {
        self._imageName = imageName
        self._firstName = firstName
        self._birthday = birthDay
        self._jobTitle = jobTitle
        self._ratings = ratings
    }
    
    init(userUID: String?, imageName: String?, firstName: String?) {
        self._userUID = userUID
        self._imageName = imageName
        self._firstName = firstName
    }
    
    init(userUID: String) {
        self._userUID = userUID
    }
}

func createAnnotation(annotation: UserLite, mapScale: Double = 0.90) -> MKAnnotationView {
    // print("anView is nil")
    
    let anView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.userUID)
    anView.canShowCallout = true
    
    let userAnnotation = annotation
    let imageName = userAnnotation.imageName
    
    if userAnnotation._gender == nil {
        userAnnotation.gender = "other"
    }
    
    let pinName = userAnnotation.returnPinImage()
    let color = userAnnotation.returnPinColor().cgColor
    
    let imgWidth: Double = 25 * mapScale
    let imgHeight: Double = 25 * mapScale
    
    let pinWidth: Double = 31 * mapScale
    let pinHeight: Double = 44 * mapScale
    let pinXY: Double = 2.70 * mapScale
    
    let imageView = UIImageView()
    imageView.loadImageUsingCacheWith(urlString: imageName)
    
    imageView.frame = CGRect(x: pinXY, y: pinXY, width: imgWidth, height: imgHeight)
    imageView.layer.cornerRadius = imageView.frame.size.width / 2
    imageView.layer.borderWidth = 0.1
    imageView.layer.borderColor = color
    
    imageView.clipsToBounds = true
    
    let pinImageView = UIImageView(image: UIImage(named: pinName))
    pinImageView.frame = CGRect(x: 0, y: 0, width: pinWidth, height: pinHeight)
    
    anView.addSubview(pinImageView)
    anView.addSubview(imageView)
    
    return anView
}

