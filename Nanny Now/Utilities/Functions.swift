//
//  Functions.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 16.10.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import RevealingSplashView
import RAMAnimatedTabBarController

func createAnnotation(annotation: User, mapScale: Double = 0.90) -> MKAnnotationView {
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

public func returnGender(_ gender:String?) -> String {
    switch gender! {
    case "female":
        return "Kvinne"
    case "male":
        return "Mann"
    default:
        return "Annet"
    }
}

public func returnStringDistance(from: Int) -> String {
    let dist = Double(Double(from) / 1000.0)
    let formatedDistance = String(format: "%.1f", dist)
    
    switch from
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

public func returnStarsStringFrom(_ ratings: Double) -> String {
    switch ratings
    {
    case 0.5..<1.5:
        return "★☆☆☆☆"
    case 1.5..<2.5:
        return "★★✬☆☆"
    case 2.5..<3.5:
        return "★★★✬☆"
    case 3.5..<4.5:
        return "★★★★✬"
    case 4.5...5.0:
        return "★★★★★"
    default:
        return "★★★★★"
    }
}

public func returnAvrageRatings(_ ratings: [String:Int]?) -> Double {
    if ratings != nil {
        var count: Int = 0
        var total: Int = 0
        for (_, vote) in ratings! {
            count += 1
            total += vote
        }
        let result = Double(total) / Double(count)
        return result
    } else {
        return 0.0
    }
}

/**
 - DateFormat = "yyyy-MM-dd-HH:mm:ss"
 - TimeZone = TimeZone(secondsFromGMT: 86400)
 - Locale = Locale(identifier: "en_US_POSIX")
 
 - Returns: **yyyy-MM-dd-HH:mm:ss** ex: (**2017-12-31-17:40:59**)
 */
public func returnTimeStamp() -> String {
    let date = Date()
    let formatter = DateFormatter()
    
    formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
    formatter.timeZone = TimeZone(secondsFromGMT: 86400)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    
    return formatter.string(from: date)
}

/**
 - DateFormat = "yyyy-MM-dd"
 - TimeZone = TimeZone(secondsFromGMT: 86400)
 - Locale = Locale(identifier: "en_US_POSIX")
 
 - Returns: **yyyy-MM-dd** ex: (**2017-12-31**)
 */
public func returnDateStamp() -> String {
    let date = Date()
    let formatter = DateFormatter()
    
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(secondsFromGMT: 86400)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    
    return formatter.string(from: date)
}

/**
 DYRET lurer på om jeg klarer å kalkulere alder fra Dato eller årstall,,, muHAHAHA
 
 - Parameter birthday: **date** in format **"MM/dd/yyyy"**
 - Returns: **Age** in years as **String**
 
 */
public func calcAge(birthday: String) -> String {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "MM/dd/yyyy"
    if birthday.count <= 4 {
        dateFormater.dateFormat = "yyyy"
    }
    
    let birthdayDate = dateFormater.date(from: birthday)
    let calendar = Calendar(identifier: .gregorian)
    
    let now = Date()
    let calcAge = calendar.dateComponents([.year], from: birthdayDate!, to: now)
    let age = calcAge.year
    let ageAsString = String(describing: age!)
    return ageAsString
}

/**
 Argument String in format **MM/dd/yyyy** and returns a Date
 - example: **stringToDate("12/31/2017")**
 - Parameter dateString: **MM/dd/yyyy**
 - Returns: **Date**
 */
public func stringToDate(_ dateString: String) -> Date {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "MM/dd/yyyy"
    
    let stringToDateFormat = dateFormater.date(from: dateString)
    return stringToDateFormat!
}

/**
 - DateFormat = "yyyy-MM-dd-HH:mm:ss"
 - TimeZone = TimeZone(secondsFromGMT: 86400)
 - Locale = Locale(identifier: "en_US_POSIX")
 
 - Returns: **Date**
 */
public func stringToDateTime(_ dateTimeString: String) -> Date {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "yyyy-MM-dd-HH:mm:ss"
    
    let stringToDateTimeFormat = dateFormater.date(from: dateTimeString)
    return stringToDateTimeFormat!
}

/**
 - DateFormat = "yyyy-MM-dd"
 - TimeZone = TimeZone(secondsFromGMT: 86400)
 - Locale = Locale(identifier: "en_US_POSIX")
 
 - Returns: **yyyy-MM-dd** ex: (**2017-12-31**)
 */
public func dateToString(_ date: Date) -> String {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "MM/dd/yyyy"
    
    let stringFromDate = dateFormater.string(from: date)
    return stringFromDate
}

/**
 - DateFormat = "yyyy-MM-dd"
 - TimeZone = TimeZone(secondsFromGMT: 86400)
 - Locale = Locale(identifier: "en_US_POSIX")
 
 - Returns: **yyyy-MM-dd** ex: (**2017-12-31**)
 */
public func dateTimeToString(_ date: Date) -> String {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "yyyy-MM-dd-HH:mm:ss"
    
    let stringFromDateTime = dateFormater.string(from: date)
    return stringFromDateTime
}

/// This will be used when Nanny and Family Request are ready
public func returnDayTimeString(from date: Date, day: Bool = true) -> String {
    let todayDate = Date()
    let tomorrowDate = Date(timeInterval: 86400, since: todayDate)
    let yesterDayDate = Date(timeInterval: -86400, since: todayDate)
    
    let from = Calendar.current.component(.weekday, from: date)
    let today = Calendar.current.component(.weekday, from: todayDate)
    let tomorrow = Calendar.current.component(.weekday, from: tomorrowDate)
    let yesterDay = Calendar.current.component(.weekday, from: yesterDayDate)
    
    var returnString = ""
    
    if day {
        switch from {
        case 1:
            returnString = "Søndag"
        case 2:
            returnString = "Mandag"
        case 3:
            returnString = "Tirsdag"
        case 4:
            returnString = "Onsdag"
        case 5:
            returnString = "Torsdag"
        case 6:
            returnString = "Fredag"
        case 7:
            returnString = "Lørdag"
        default:
            print("returnDayTimeString: Error fetching dagNavn")
            returnString = "Dag"
        }
        
        if from == today {
            returnString = "i dag"
        } else if from == tomorrow {
            returnString = "i morgen"
        }
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    formatter.timeZone = TimeZone(secondsFromGMT: 86400)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    let tidspunkt = formatter.string(from: date)
    
    if from == yesterDay {
        returnString = "Dette var i går, sjekk tidspunktet på nytt!"
    } else {
        returnString = "kl: \(tidspunkt) \(returnString)"
    }
    return returnString
}

/// This will be used when Nanny and Family Request are ready
public func returnDayTimeString(from date: Date) -> String {
    let todayDate = Date()
    let tomorrowDate = Date(timeInterval: 86400, since: todayDate)
    let yesterdayDate = Date(timeInterval: -86400, since: todayDate)
    
    let weekday = Calendar.current.component(.weekday, from: date)
    // let today = Calendar.current.component(.weekday, from: todayDate)
    // let tomorrow = Calendar.current.component(.weekday, from: tomorrowDate)
    // let yesterDay = Calendar.current.component(.weekday, from: yesterDayDate)
    
    var returnString = ""
    
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 86400)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    
    formatter.dateFormat = "HH:mm"
    let klokken = formatter.string(from: date)
    
    formatter.dateFormat = "HH"
    let time = formatter.string(from: date)
    let timeInt = Int(time) ?? 12
    
    formatter.dateFormat = "dd/MM"
    let dato = formatter.string(from: date)
    
    formatter.dateFormat = "yyyy-MM-dd"
    let from = formatter.string(from: date)
    let today = formatter.string(from: todayDate)
    let tomorrow = formatter.string(from: tomorrowDate)
    let yesterday = formatter.string(from: yesterdayDate)
    
    
    var tidsPeriode = ""
    
    // https://forum.kvinneguiden.no/topic/359451-formiddag-ettermiddag/
    switch timeInt {
    case 0..<6:
        tidsPeriode = "natt"
    case 6..<9:
        tidsPeriode = from == tomorrow ? "tidlig" : "morgen"
    case 9..<12:
        tidsPeriode = "formiddag"
    case 12..<15:
        tidsPeriode = ""
    case 15..<18:
        tidsPeriode = "ettermiddag"
    default:
        tidsPeriode = "kveld"
    }
    
    switch weekday {
    case 1:
        returnString = "søndag"
    case 2:
        returnString = "mandag"
    case 3:
        returnString = "tirsdag"
    case 4:
        returnString = "onsdag"
    case 5:
        returnString = "torsdag"
    case 6:
        returnString = "fredag"
    case 7:
        returnString = "lørdag"
    default:
        returnString = dato
    }
    
    let nattEllerDag = timeInt < 5 ? "natt" : "dag"
    let tidspunkt = timeInt >= 18 ? "kveld" : nattEllerDag
    
    if from == today {
        returnString = "i \(tidspunkt)"
    } else if from == tomorrow {
        returnString = "i morgen \(tidsPeriode)"
    } else if from == yesterday {
        returnString = "i går"
    } else {
        returnString = dato
    }
    
    return "\(returnString)  \(klokken)"
}

/// argument **String** of **#HEX** returns **UIColor** value
public func hexStringToUIColor (_ hex:String, _ alpha: Float? = 1.0) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: (NSCharacterSet.whitespacesAndNewlines as NSCharacterSet) as CharacterSet).uppercased()
    
    if (cString.hasPrefix("#")) {
        // let index: String.Index = cString.index(cString.startIndex, offsetBy: 1)
        // cString = cString.substring(from: index) // "Stack"
        cString.removeFirst()// String(cString[index...cString.endIndex])
    }
    if ((cString.count) != 6) {
        return UIColor.gray
           }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(alpha!)
    )
}

// Not in use - Struct with Constants is Used
// Static CLLocationDistance in Meters as Double ;-)
public enum locationAltitude : CLLocationDistance {
    case tiny = 600, XSmall = 900, small = 2500, normal = 5500, medium = 6500, large = 11200, XLarge = 20000, XXLarge = 200000
}

// Altitude that uses locationAltitude Enum
public func setAltitude (_ altitude: locationAltitude) -> CLLocationDistance {
    return altitude.rawValue
}

// First understandable and usefull enum - (enum here used for typo arguments)
public enum HapticEngineTypes {
    case error, success, warning, light, medium, heavy, selection
}

/// haptic engine effect when pressing buttons - Parameter: Hello
public func hapticButton(_ types: HapticEngineTypes,_ fire: Bool = true) {
    if fire {
        switch types {
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        default:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
}

/// animate imageView or View (parallax Effect)
public func addParallaxEffectOnView<T>(_ view: T, _ relativeMotionValue: Int) {
    let relativeMotionValue = relativeMotionValue
    let verticalMotionEffect : UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
                                                                                         type: .tiltAlongVerticalAxis)
    verticalMotionEffect.minimumRelativeValue = -relativeMotionValue
    verticalMotionEffect.maximumRelativeValue = relativeMotionValue
    
    let horizontalMotionEffect : UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                                                           type: .tiltAlongHorizontalAxis)
    horizontalMotionEffect.minimumRelativeValue = -relativeMotionValue
    horizontalMotionEffect.maximumRelativeValue = relativeMotionValue
    
    let group : UIMotionEffectGroup = UIMotionEffectGroup()
    group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
    
    if let view = view as? UIView {
        view.addMotionEffect(group)
    } else {
        print("unable to add parallax Effect on View / ImageView")
    }
    
}

/// removes motionEffects (on view), if any
public func removeParallaxEffectOnView(_ view: UIView) {
    let motionEffects = view.motionEffects
    for motion in motionEffects {
        view.removeMotionEffect(motion)
    }
}

public enum Fade {
    public enum State {
        case In
        case Out
    }
    public enum Direction {
        case Right
        case Left
    }
}

public func fadeView(_ view: UIView, direction: Fade.Direction = .Left, distance: CGFloat = 25.0, duration: TimeInterval = 0.51, delay: TimeInterval = 0.151) {
    view.alpha = 0.0
    // Basic Ternary Operator "distance = -distance "if direction == Right"
    let distance = direction == .Left ? distance : -distance
    view.frame = view.frame.offsetBy(dx: distance, dy: 0)
    
    UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.95, options: .curveEaseIn, animations: {
        view.alpha = 1
        view.frame = CGRect(x: 0.0, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
    })
}

/// animate tableView Cells (Very generic) #Swift_3.0 - Animation Base
public func animateTable(_ tableView: UITableView,_ animated: Bool = true,_ mapView: MKMapView? = nil) {
    tableView.reloadData()
    if animated && lowPowerModeDisabled {
        guard let mapView = mapView else {
            return
        }
        // set cells in tableView to use
        let cells = tableView.visibleCells
        
        for cell in cells {
            cell.alpha = 0
        }
        
        tableView.alpha = 1
        
        // set transition height
        let tableHeight: CGFloat = tableView.bounds.size.height / 2
        
        var index = 0
        
        for cell in cells {
            // set "start" transition point
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
            // init of animation SORRY animate function of UIView
            
            // LOL "Love it" when you use delay 0.200 // 0.050
            UIView.animate(withDuration: 0.945, delay: 0.050 * Double(index), usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: .allowAnimatedContent, animations: {
                mapView.alpha = 0.95
                cell.alpha = 1
                // sett "end" transition point
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: { (true) in
                // print("animateTable completion")
                // mapView.frame = CGRect(x: 0, y: 0, width: 375, height: 340)
            })
            index += 1
        }
    } else {
        tableView.alpha = 1
    }
}

public func animateTable(_ tableView: UITableView, delay: Double, animated: Bool = true, mapView: MKMapView? = nil) {
    
    let delayInSeconds = delay
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
        animateTable(tableView, animated, mapView)
    }
}

public enum TableViewCellAnimation {
    case fade(() -> Void)
    case scale(() -> Void)
    case tilt3D(() -> Void)
    case blur(() -> Void)
}

public func animateCells(in tableView: UITableView,_ animated: Bool = true, completion: Completion? = nil) {
    if animated && lowPowerModeDisabled {
        let cells = tableView.visibleCells
        
        for cell in cells { cell.alpha = 0 }
        
        tableView.alpha = 1
        
        var index = 0
        for cell in cells {
            
            cell.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            
            UIView.animate(withDuration: 0.905, delay: 0.050 * Double(index), usingSpringWithDamping: 1.3, initialSpringVelocity: 0.5, options: .allowAnimatedContent, animations: {
                cell.alpha = 1
                // sett "end" transition point
                cell.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { (true) in
                
            })
            index += 1
        }
        completion?()
    } else {
        tableView.alpha = 1
    }
}

public func animateCellsWithProgress(in tableView: UITableView,_ animated: Bool = true, progress: UIProgressView, completion: Completion? = nil) {
    if animated && lowPowerModeDisabled {
        let cells = tableView.visibleCells
        progress.setProgress(0.05, animated: true)
        for cell in cells { cell.alpha = 0 }
        tableView.alpha = 1
        var index = 0
        for cell in cells {
            // cell.layer.transform = CATransform3DMakeRotation(CGFloat.pi / 4, 1, 0, 0)
            cell.transform = CGAffineTransform(scaleX: 0.89, y: 0.89)
            UIView.animate(withDuration: 0.800, delay: 0.040 * Double(index), usingSpringWithDamping: 0.75, initialSpringVelocity: 0.65, options: .curveEaseOut, animations: {
                cell.alpha = 1
                // sett "end" transition point
                let value = (Float(index)/(Float(cells.count))) * (0.3 + Float(index)/100.0)
                progress.progress = value
                // cell.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
                cell.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { (true) in
                
            })
            index += 1
            if index == cells.count {
                print("index and cells.count is equal")
                UIView.animate(withDuration: 0.60, delay: 0.75, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    progress.setProgress(1.0, animated: true)
                    progress.alpha = 0.0
                })
            }
        }
    } else {
        tableView.alpha = 1
    }
}

public func animateCells(in tableView: UITableView,_ animated: Bool = true, delay: Double) {
    let delayInSeconds = delay
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
        animateCells(in: tableView)
    }
}

// @available(iOS, deprecated, message: "Use animateCells3d() method instead.")
public func animateCells3d(in tableView: UITableView,_ animated: Bool = true) {
    if animated && lowPowerModeDisabled {
        let cells = tableView.visibleCells
        
        for cell in cells { cell.alpha = 0 }
        tableView.alpha = 1
        
        var index = 0
        for cell in cells {
            cell.layer.transform = CATransform3DMakeRotation(CGFloat.pi / 4, 0, 1, 0)
            
            UIView.animate(withDuration: 0.805, delay: 0.048 * Double(index), usingSpringWithDamping: 1.3, initialSpringVelocity: 0.4, options: .allowAnimatedContent, animations: {
                cell.alpha = 1
                // sett "end" transition point
                cell.layer.transform = CATransform3DMakeRotation(0, 0, 1, 0)
            }, completion: { (true) in
                // print("animateTable completion")
            })
            index += 1
            
        }
    } else {
        tableView.alpha = 1
    }
}

public func animateCells3d(in tableView: UITableView,_ animated: Bool = true, delay: Double) {
    let delayInSeconds = delay
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
        animateCells3d(in: tableView)
    }
}

/// Splash Animations of type SplashAnimationType with default value of nil
public func revealingSplashAnimation(_ view: UIView, type: SplashAnimationType? = nil, completion: SplashAnimatableCompletion? = nil) {
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "logo_1024_cornered")!,iconInitialSize: CGSize(width: 120, height: 120), backgroundColor: UIColor(red:255, green:255, blue:255, alpha:1.0))
    
    // SplashAnimationType, if nil "Twitter" first anmimation
    if type != nil {
        revealingSplashView.animationType = type!
    }
    
    // This is just a test...
    revealingSplashView.duration = 1.9
    
    //Adds the revealing splash view as a sub view
    view.addSubview(revealingSplashView)
    
    //Starts animation
    revealingSplashView.startAnimation(completion)
}

public func revealingSplashAnimation(_ view: UIView, type: SplashAnimationType? = nil, duration: Double, delay: Double, completion: SplashAnimatableCompletion? = nil) {
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "logo_1024_cornered")!,iconInitialSize: CGSize(width: 120, height: 120), backgroundColor: UIColor(red:255, green:255, blue:255, alpha:1.0))
    
    // SplashAnimationType, if nil "Twitter" first anmimation
    if type != nil {
        revealingSplashView.animationType = type!
    }
    
    // This is just a test...
    revealingSplashView.duration = duration
    revealingSplashView.delay = delay
    
    //Adds the revealing splash view as a sub view
    view.addSubview(revealingSplashView)
    
    //Starts animation
    revealingSplashView.startAnimation(completion)
}

/**
 Calculate Center Position From Array Of Locations
 
 - Parameter array: latitude and longitude from [Nanny]
 - Returns : CLLoaction (latitude and longitude)
 
 */
public func calculateCenterPositionFromArrayOfLocations(_ array: [AnyObject]) -> CLLocation {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    for locations in array {
        latitude += (locations.coordinate.latitude)
        longitude += (locations.coordinate.longitude)
    }
    latitude /= Double(array.count)
    longitude /= Double(array.count)
    
    return CLLocation(latitude: latitude, longitude: longitude)
}

