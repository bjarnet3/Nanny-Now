//
//  NotificationViewController.swift
//  NotificationContentExtensions
//
//  Created by Bjarne Tvedten on 07.02.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import MapKit
import MapKitGoogleStyler
import Contacts
import UserNotifications
import UserNotificationsUI

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
 - http://nsdateformatter.com/
 
 - DateFormat = "E d MMMM h:mm"
 - TimeZone = TimeZone(secondsFromGMT: 86400)
 - Locale = Locale(identifier: "nb_NO")
 
 - Returns: **E d MMMM h:mm** ex: (**tir. 5 juni 9:04**)
 */
public func dateTimeToString(from date: Date, with locale:String = "nb_NO", dateFormat:String = "E d MMMM H:mm") -> String {
    let dateFormater = DateFormatter()
    
    dateFormater.dateFormat = dateFormat
    dateFormater.timeZone = TimeZone(secondsFromGMT: 86400)
    dateFormater.locale = Locale(identifier: locale)
    
    let dateTimeToString = dateFormater.string(from: date)
    return dateTimeToString
}


class FrostyView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func layoutSubviews() {
        setEffect()
    }
}

extension FrostyView {
    func setEffect(blurEffect: UIBlurEffect.Style = .extraLight) {
        for view in subviews {
            if view is UIVisualEffectView {
                print(view.description)
                view.removeFromSuperview()
            }
        }
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: blurEffect))
        frost.frame = bounds
        frost.autoresizingMask = .flexibleWidth
        
        self.layer.borderWidth = 0.4
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        insertSubview(frost, at: 0)
    }
}

class NotificationViewController: UIViewController, UNNotificationContentExtension, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var maskingView: UIView!
    
    @IBOutlet weak var remoteImageView: UIImageView!
    @IBOutlet weak var yourImageView: UIImageView!
    
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceTimeLabel: UILabel!
    
    @IBOutlet weak var requestName: UILabel!
    @IBOutlet weak var requestTime: UILabel!
    @IBOutlet weak var requestTimeTo: UILabel!
    
    let regionRadius: CLLocationDistance = 20000
    // var locationManager: CLLocationManager!
    var backgroundMapViewIsRendered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // The solution to not drawing polyline
        mapView.delegate = self
        self.setMapBackgroundOverlay(mapName: .veryLightMap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addCirleMaskWithFrostOn(self.maskingView)
    }
    
    func didReceive(_ notification: UNNotification) {
        guard notification.request.content.categoryIdentifier == "nannyMapRequest" else { return }
        
        let remoteURL = AnyHashable("userURL")
        let userURL = AnyHashable("remoteURL")
        
        // let title = notification.request.content.title
        let subtitle = notification.request.content.body
        let userInfo = notification.request.content.userInfo
        
        guard let yourImageUrl = userInfo[userURL] as? String else { return }
        guard let remoteImageUrl = userInfo[remoteURL] as? String else { return }
        
        self.yourImageView.loadImageUsingCacheWith(urlString:yourImageUrl)
        self.remoteImageView.loadImageUsingCacheWith(urlString: remoteImageUrl)
        
        // Message Text
        // -----------
        let remoteName = userInfo["remoteName"] as? String ?? ""
        self.requestName?.text = "\(remoteName)"
        
        // Location
        // --------
        let remoteLatitude = userInfo["userLat"] as? String ?? "60.0001"  // Åsane Senter
        let remoteLongitude = userInfo["userLong"] as? String ?? "5.0001"
        
        let userLatitude = userInfo["remoteLat"] as? String ?? "60.1001" // Laksevåg Senter
        let userLongitude = userInfo["remoteLong"] as? String ?? "5.10000"
        
        let yourLocation = CLLocationCoordinate2D(latitude: Double(userLatitude)!, longitude: Double(userLongitude)!)
        let remoteLocation = CLLocationCoordinate2D(latitude: Double(remoteLatitude)!, longitude: Double(remoteLongitude)!)
        
        self.renderedMap(remoteName, subtitle: subtitle, remoteLocation: remoteLocation, yourLocation: yourLocation)
        
        // Data Time Format
        // ----------------
        let timeStringFrom = userInfo["timeFrom"] as? String
        let timeStringTo = userInfo["timeTo"] as? String
        
        let timeFrom = stringToDateTime(timeStringFrom!)
        let timeTo = stringToDateTime(timeStringTo!)
        
        let timeStringFormatFrom = dateTimeToString(from: timeFrom, dateFormat: "E d MMM H:mm")
        let timeStringFormatTo = dateTimeToString(from: timeTo, dateFormat: "d MMM H:mm")
        
        self.requestTime?.text = "\(timeStringFormatFrom) "
        self.requestTimeTo.text = "\(timeStringFormatTo) "
    }
    
    private func addCirleMaskWithFrostOn(_ subView: UIView) {
        // Create the view
        let blurEffect = UIBlurEffect(style: .extraLight)
        let maskView = UIVisualEffectView(effect: blurEffect)
        maskView.frame = subView.bounds
        
        // Choose the smales distance - width / height
        let subViewBounds: CGFloat = subView.bounds.width < subView.bounds.height ? subView.bounds.width : subView.bounds.height
        // Set the radius to 1/3 of the screen width
        let radius : CGFloat = subViewBounds/2.40
        // Create a path with the rectangle in it.
        let path = UIBezierPath(rect: subView.bounds)
        // Put a circle path in the middle
        path.addArc(withCenter: subView.center, radius: radius, startAngle: 0.0, endAngle: CGFloat(2*CGFloat.pi), clockwise: true)
        
        // Create the shapeLayer
        let shapeLayer = CAShapeLayer()
        // set arc to shapeLayer
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        // Create the boarderLayer
        let boarderLayer = CAShapeLayer()
        boarderLayer.path = UIBezierPath(arcCenter: subView.center, radius: radius, startAngle: 0.0, endAngle: CGFloat(2*CGFloat.pi), clockwise: true).cgPath
        boarderLayer.lineWidth = 3.0
        boarderLayer.strokeColor = UIColor.white.cgColor
        boarderLayer.fillColor = nil
        
        // add shapeLayer to maskView
        maskView.layer.mask = shapeLayer
        
        // set properties
        maskView.clipsToBounds = true
        maskView.layer.borderColor = UIColor.gray.cgColor
        maskView.backgroundColor = nil
        maskView.layer.addSublayer(boarderLayer)
        self.maskingView.addSubview(maskView)
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
}

class Artwork: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    // When clicking on annotation pin
    // Annotation right callout accessory opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}

/// MapViewRendered -> NotificationViewController Extension
///
/// The `MKMapViewDelegate` protocol defines a set of optional methods that you can use to
/// receive map-related update messages
///
extension NotificationViewController : MKMapViewDelegate {
    
    /// Rendered MapView with coordinates
    ///
    fileprivate func renderedMap(_ title:String, subtitle:String, remoteLocation: CLLocationCoordinate2D, yourLocation: CLLocationCoordinate2D) {

        // show artwork on map
        let remoteArt = Artwork(title: title,
                              locationName: "Adressen",
                              discipline: "(nanny?.returnDistanceString())!",
                              coordinate: remoteLocation)
        
        mapView.addAnnotation(remoteArt)
        
        let yourArt = Artwork(title: "YOU",
                              locationName: "",
                              discipline: "",
                              coordinate: yourLocation)
        
        mapView.addAnnotation(yourArt)
        
        centerMapOnLocation(location: calculateCenterPositionFromArrayOfLocations(mapView.annotations))
        showRouteOnMap()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? Artwork else { return nil }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Artwork
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    private func setMapBackgroundOverlay(mapName: MapStyleForView) {
        // We first need to have the path of the overlay configuration JSON
        guard let overlayFileURLString = Bundle.main.path(forResource: mapName.rawValue, ofType: "json") else {
            return
        }
        let overlayFileURL = URL(fileURLWithPath: overlayFileURLString)
        
        // After that, you can create the tile overlay using MapKitGoogleStyler
        guard let tileOverlay = try? MapKitGoogleStyler.buildOverlay(with: overlayFileURL) else {
            return
        }
        // And finally add it to your MKMapView
        mapView.addOverlay(tileOverlay)
        self.backgroundMapViewIsRendered = true
    }
    
    // https://github.com/fmo91/MapKitGoogleStyler
    func mkOverlayRender(_ overlay: MKOverlay) -> MKOverlayRenderer {
        // This is the final step. This code can be copied and pasted into your project
        // without thinking on it so much. It simply instantiates a MKTileOverlayRenderer
        // for displaying the tile overlay.
        if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    func mkPolyLineRender(_ overlay: MKOverlay) -> MKPolylineRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.purple
        renderer.lineWidth = 5
        return renderer
    }
    
    // Thank You : https://stackoverflow.com/questions/29319643/how-to-draw-a-route-between-two-locations-using-mapkit-in-swift
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if !backgroundMapViewIsRendered {
            return mkOverlayRender(overlay)
        } else {
            return mkPolyLineRender(overlay)
        }
    }
    
    func showRouteOnMap(transportType: MKDirectionsTransportType = .automobile) {
        let annotation1 = mapView.annotations[0]
        let annotation2 = mapView.annotations[1]
        
        var transportTypeString = "å fly"
        switch transportType {
        case .automobile:
            transportTypeString = "å kjøre"
        case .walking:
            transportTypeString = "å gå"
        case .transit:
            transportTypeString = "å ta buss"
        default:
            transportTypeString = "komme"
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: annotation1.coordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: annotation2.coordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        /* - DEPARTURE AND ARRIVAL
         let arrivaleDate = Date(timeInterval: 3600, since: Date())  // 3600 One Hour from Date()
         request.arrivalDate = arrivaleDate
         */
        
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                if route == unwrappedResponse.routes.last {
                    let routeSeconds = route.expectedTravelTime
                    let routeMinutes = Int(routeSeconds) % 60
                    let routeDistance = Int(route.distance / 1000)
                    
                    /* - DEPARTURE AND ARRIVAL PRINT
                     let departureDate = Date(timeInterval: -routeSeconds, since: request.arrivalDate!)
                     let departure = returnDayTimeString(from: departureDate, day: false)
                     let arrival = returnDayTimeString(from: arrivaleDate)
                     print("Skal du være der \(String(describing: arrival)), så må du reise før \(departure)")
                     */
                    
                    // guard let reciverName = annotation1.title ?? "familien" else { return }

                    let routeTimeMessage = "Det tar ca \(routeMinutes) minutter \(transportTypeString)"
                    let routeDistanceMessage = "Avstanden er \(routeDistance) km"
                    
                    self.distanceTimeLabel.text = routeTimeMessage
                    self.distanceLabel.text = routeDistanceMessage
                    
                    // https://stackoverflow.com/questions/23127795/how-to-offset-properly-an-mkmaprect
                    let mapRect = route.polyline.boundingMapRect
                    self.mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 100, left: 60, bottom: 85, right: 60), animated: true)
                    
                    // let mapCamera = MKMapCamera(lookingAtCenter: (self.userLocation), fromEyeCoordinate: (self.yourLocation), eyeAltitude: 400.0)
                    // mapCamera.heading = 80 // rotation
                    // self.mapView.setCamera(mapCamera, animated: true)
                }
            }
        }
    }
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: false)
    }
}
