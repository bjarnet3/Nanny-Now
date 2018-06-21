//
//  NotificationViewController.swift
//  NotificationContentExtensions
//
//  Created by Bjarne Tvedten on 07.02.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import MapKit
import Contacts
import UserNotifications
import UserNotificationsUI

// Completion Typealias
public typealias Completion = () -> Void

extension UIImageView {
    /**
     Load Image from Catch or Get from URL function
     
     [Tutorial on YouTube]:
     https://www.youtube.com/watch?v=GX4mcOOUrWQ "Click to Go"
     
     [Tutorial on YouTube] made by **Brian Voong**
     
     - parameter urlString: URL to the image
     */
    func loadImageUsingCacheWith(urlString: String, completion: Completion? = nil) {
        // If not,, download with dispatchqueue
        let url = URL(string: urlString)
        // URL Request
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            // Run on its own threads with DispatchQueue
            DispatchQueue.main.async(execute: { () -> Void in
                if let downloadedImage = UIImage(data: data!) {
                    self.image = downloadedImage
                    completion?()
                }
            })
        }).resume( )
    }
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
    func setEffect(blurEffect: UIBlurEffectStyle = .extraLight) {
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

    @IBOutlet var displayView: FrostyView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var remoteImageView: UIImageView!
    @IBOutlet weak var yourImageView: UIImageView!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    let regionRadius: CLLocationDistance = 20000
    // var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // The solution to not drawing polyline
        mapView.delegate = self
    }
    
    func didReceive(_ notification: UNNotification) {
        
        guard notification.request.content.categoryIdentifier == "nannyMapRequest" else { return }
        
        let remoteURL = AnyHashable("userURL")
        let userURL = AnyHashable("remoteURL")
        
        let title = notification.request.content.title
        let subtitle = notification.request.content.body
        
        let userInfo = notification.request.content.userInfo
        
        guard let yourImageUrl = userInfo[userURL] as? String else { return }
        guard let remoteImageUrl = userInfo[remoteURL] as? String else { return }
        
        self.yourImageView.loadImageUsingCacheWith(urlString:yourImageUrl)
        self.remoteImageView.loadImageUsingCacheWith(urlString: remoteImageUrl)
        
        let remoteLatitude = userInfo["userLat"] as? String ?? "60.0001"  // Åsane Senter
        let remoteLongitude = userInfo["userLong"] as? String ?? "5.0001"
        
        let userLatitude = userInfo["remoteLat"] as? String ?? "60.1001" // Laksevåg Senter
        let userLongitude = userInfo["remoteLong"] as? String ?? "5.10000"
        
        let yourLocation = CLLocationCoordinate2D(latitude: Double(userLatitude)!, longitude: Double(userLongitude)!)
        let remoteLocation = CLLocationCoordinate2D(latitude: Double(remoteLatitude)!, longitude: Double(remoteLongitude)!)
        
        self.renderedMap(title, subtitle: subtitle, remoteLocation: remoteLocation, yourLocation: yourLocation)
        
        let message = "\(notification.request.content.title): \(notification.request.content.body) "
        // let message = "\(remoteLatitude): \(remoteLongitude)  -  \(userLatitude):\(userLongitude)"
        self.messageLabel?.text = message
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
        
        let yourArt = Artwork(title: "Dette er deg",
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
    
    // Thank You : https://stackoverflow.com/questions/29319643/how-to-draw-a-route-between-two-locations-using-mapkit-in-swift
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.purple
        renderer.lineWidth = 5
        return renderer
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
        
        let request = MKDirectionsRequest()
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
                self.mapView.add(route.polyline)
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
                    
                    self.timeLabel.text = routeTimeMessage
                    self.distanceLabel.text = routeDistanceMessage
                    
                    // https://stackoverflow.com/questions/23127795/how-to-offset-properly-an-mkmaprect
                    let mapRect = route.polyline.boundingMapRect
                    self.mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsetsMake(40, 20, 85, 40), animated: true)
                    
                    // let mapCamera = MKMapCamera(lookingAtCenter: (self.userLocation), fromEyeCoordinate: (self.yourLocation), eyeAltitude: 400.0)
                    // mapCamera.heading = 80 // rotation
                    // self.mapView.setCamera(mapCamera, animated: true)
                }
            }
        }
    }
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: false)
    }
}
