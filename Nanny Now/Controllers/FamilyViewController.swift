//
//  FamilyViewController.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 10.09.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit
import MapKit
import MapKitGoogleStyler
import Contacts
import Firebase
import SwiftKeychainWrapper
import UserNotifications
import RevealingSplashView

class FamilyViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - IBOutlet: Connection to View "storyboard"
    // ----------------------------------------
    @IBOutlet weak var familyTabBar: UITabBarItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var notifyTitle: CustomButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Array, Constants & Varables
    // -------------------------------------
    private var families = [Family]()
    private var user: User?
    private var remoteUser: User?
    
    private var users = [User]()
    
    private var lastRowSelected: IndexPath?
    private var exemptIDs = [String]()
    
    private var currentMapStyle:MapStyleForView = .blueAndGrayMap
    private var backgroundMapViewIsRendered = false
    private var index = 0
    
    private var mapStyle: [MapStyleForView] = [.blueAndGrayMap, .blackAndRegularMap, .dayMap, .pinkBlackMap, .pinkStinkMap, .pinkWhiteMap, .veryLightMap, .whiteAndBlackMap, .blackAndBlueGrayMap, .lightBlueGrayMap]
    
    // Property Observer
    // -----------------
    var familyBadge: Int = 0 {
        didSet {
            self.familyTabBar.badgeValue = self.familyBadge != 0 ? "\(self.familyBadge)" : nil
        }
    }

    // MARK: - Functions:
    // ----------------------------------------
    private func setUserSettings() {
        if let user = LocalService.instance.user {
            self.user = user
        }
    }
    
    // Changes the mapView background style
    // ------------------------------------
    private func changeMapStyle() {
        if index < mapStyle.count {
            setMapView(for: mapStyle[index])
            index += 1
        } else {
            index = 0
        }
    }
    
    // LocationManager  /   LocationService
    // -------------------------------------
    private var locationManager = CLLocationManager()
    private var activeLocations = [String:CLLocation]()
    
    private var activeLocationNames = [String]()
    private var activeLocationName = "current"
    
    private func enableLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        // locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private var currentLocation: CLLocation? {
        var location: CLLocation?
        if let currentLocation = locationManager.location {
            location = currentLocation
        } else if let userLocation = user?.location {
            location = userLocation
        } else {
            location = nil
        }
        return location
    }
    
    private var returnCurrentLocation: CLLocation {
        var location: CLLocation
        if let currentLocation = locationManager.location {
            location = currentLocation
        } else if let userLocation = user?.location {
            location = userLocation
        } else {
            location = CLLocation(latitude: 60.0436638, longitude: 5.5220319)
        }
        return location
    }
    
    private var returnActiveLocation: CLLocation {
        return self.user?.activeLocation ?? returnCurrentLocation
    }
    
    private func setActiveLocation() {
        let active = self.activeLocationName
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            var location: (latitude: Double?, longitude: Double?)
            // var longitude: Double?
            DataService.instance.REF_USERS_PRIVATE.child(userID).child("location").child(active).observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                    
                    for (key, val) in snapshot {
                        if let longitude = val as? Double, key == "longitude" {
                            location.longitude = longitude
                        }
                        
                        if let latitude = val as? Double, key == "latitude" {
                            location.latitude = latitude
                        }
                    }
                    if location.latitude != nil && location.longitude != nil {
                        self.user?.activeLocation = CLLocation(latitude: location.latitude!, longitude: location.longitude!)
                    }
                }
            })
        }
    }
    
    private func getLocationsFromUserInfo() {
        if let locations = userInfo["location"] as? [String: Any] {
            for (key, value) in locations {
                if key != "active" {
                    let locationkey = key
                    self.activeLocationNames.append(locationkey)
                } else if key == "active" {
                    if let active = value as? String {
                        self.activeLocationName = active
                        self.setActiveLocation()
                    }
                }
            }
        }
    }
    
    private func getUserSettings() {
        if let user = LocalService.instance.getUser() {
            self.user = user
            self.user?.location = returnCurrentLocation
            self.checkForBlocked(user.userUID)
        }
    }
    
    private func updateUserArrayAndAnnotation(_ user: User) {
        user.setAnnotation()
        user._distance = self.locationManager.location?.distance(from: user.location!)
        
        self.familyBadge += 1
        self.users.append(user)
        self.users.sort(by: { $0.returnIntDistance < $1.returnIntDistance })
        
        if !mapView.selectedAnnotations.isEmpty {
            for selectedAnnotation in mapView.selectedAnnotations {
                mapView.deselectAnnotation(selectedAnnotation, animated: true)
            }
        }
        self.mapView.showAnnotations(self.users, animated: lowPowerModeDisabled)
    }
    
    // ------------------------------------
    // ------------------------------------

    private func checkForBlocked(_ userID: String) {
        DataService.instance.REF_USERS_PUBLIC.child(userID).child("blocked").observeSingleEvent(of: .value, with: { snapshot in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    self.exemptIDs.append(snap.key)
                    print(snap.key)
                }
            }
        })
        
        DataService.instance.REF_USERS_PRIVATE.child(userID).child("blocked").observeSingleEvent(of: .value, with: { snapshot in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    self.exemptIDs.append(snap.key)
                    print(snap.key)
                }
            }
        })
    }
    
    private func displayOnTitle(displayMessage: String) {
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.25, options: .curveEaseOut, animations: {
            self.notifyTitle.alpha = 1.0
            self.notifyTitle.setTitle(displayMessage, for: .normal)
            self.notifyTitle.setTitleColor(UIColor.white, for: .normal)
            self.notifyTitle.backgroundColor = hexStringToUIColor("#FF1744")
        }, completion: { (_) in
            UIView.animate(withDuration: 0.7, delay: 1.6, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.38, options: .curveEaseOut, animations: {
                self.notifyTitle.alpha = 0.0
                self.notifyTitle.backgroundColor = UIColor.white
            }, completion: { (_) in
                self.notifyTitle.setTitle("", for: .normal)
                self.notifyTitle.setTitleColor(UIColor.black, for: .normal)
            })
        })
    }
    
    // ---- Temporary Functions
    // ------------------------
    private func setupDummyUsers() {
        
        let user0 = User(userUID: "RGG1KFpGfMSM5BEbzbsg0QlcgW33", imageName: "https://firebasestorage.googleapis.com/v0/b/nanny-now-d2596.appspot.com/o/profile-images%2FRGG1KFpGfMSM5BEbzbsg0QlcgW33%2FD5F95261-EEC9-43F4-A753-483E0BD9083B?alt=media&token=c1da5a37-1f83-4ec6-ac43-ef35aa6eb503", firstName: "Bjarne")
        user0.location = CLLocation(latitude: 60.26349810015857, longitude: 5.342045621209245)
        user0.jobTitle = "iOS Utvikler"
        updateUserArrayAndAnnotation(user0)
        self.users.append(user0)
        
        let user1 = User(userUID: "0kDX22RQmUSRSqFi85HYtGxesxe2", imageName: "https://firebasestorage.googleapis.com/v0/b/nanny-now-d2596.appspot.com/o/profile-images%2F0kDX22RQmUSRSqFi85HYtGxesxe2%2F1ABCCF16-57DD-452E-84D2-3AC67CDAF229?alt=media&token=53627f46-f985-4b94-b25a-dabdceafbe19", firstName: "Irina")
        user1.location = CLLocation(latitude: 60.20323780329263, longitude: 5.11111)
        user1.jobTitle = "Stripper"
        updateUserArrayAndAnnotation(user1)
        self.users.append(user1)
        
        
        let user2 = User(userUID: "vYQknBpgaGcEZiEpj2KG4VBR1pQ2", imageName: "https://firebasestorage.googleapis.com/v0/b/nanny-now-d2596.appspot.com/o/profile-images%2FvYQknBpgaGcEZiEpj2KG4VBR1pQ2%2F906D633F-FAE9-4D55-AFE8-A28839F603CC?alt=media&token=18df0ffe-aea4-4635-af9d-a8e2d93d41d1", firstName: "Glenn")
        user2.location = CLLocation(latitude: 60.3890508, longitude: 5.2652124)
        user2.jobTitle = "SpikerMann"
        updateUserArrayAndAnnotation(user2)
        self.users.append(user2)
        
        
        // TO NEXT TIME
        let family0 = Family()
        let family1 = Family()
        let family2 = Family()
    }
    
    // MARK: - Actions  /  Functions
    // -----------------------------
    @IBAction func addPlussButton(_ sender: UIButton) {
        
        changeMapStyle()
    }
    
    
    // MARK: - viewDidLoad  /   viewDidAppear
    // --------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Settings & Setup
        self.enableLocationServices()
        self.getLocationsFromUserInfo()
        self.getUserSettings()
        
        // TableView and MapView Delegate and Datasource
        self.mapView.alpha = 1
        self.mapView.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.setupDummyUsers()
        self.setMapBackgroundOverlay(mapName: .whiteAndBlackMap)
        
        self.setUserSettings()
        self.enableLocationServices()
        
        self.viewDidLoadAnimation()
        
        revealingSplashAnimation(self.view, type: SplashAnimationType.woobleAndZoomOut, duration: 1.90, delay: 0)
        
        self.familyTabBar.badgeValue = "2"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tab = self.tabBarController?.tabBar as! FrostyTabBar
        tab.setEffect(blurEffect: .light)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        hapticButton(.medium, lowPowerModeDisabled)
        self.familyBadge = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(" --- ")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.familyBadge = 0
    }
    
    func viewDidLoadAnimation() {
        self.centerMapOnLocation(calculateCenterPositionFromArrayOfLocations(self.users), regionRadius: AltitudeDistance.large, animated: false)
        self.mapView.showAnnotations(self.users, animated: lowPowerModeDisabled)
        hapticButton(.light, lowPowerModeDisabled)
    }
    
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension FamilyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.families.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}

extension FamilyViewController: MKMapViewDelegate {
    
    // MARK: - Functions, Database & Animation
    // ---------------------------------------
    func setMapView(for mapStyleForView: MapStyleForView) {
        self.backgroundMapViewIsRendered = false
        self.mapView.removeOverlays(mapView.overlays)
        
        switch mapStyleForView {
        case .blueAndGrayMap:
            self.setMapBackgroundOverlay(mapName: .blueAndGrayMap)
        case .blackAndRegularMap:
            self.setMapBackgroundOverlay(mapName: .blackAndRegularMap)
        case .dayMap:
            self.setMapBackgroundOverlay(mapName: .dayMap)
        case .pinkBlackMap:
            self.setMapBackgroundOverlay(mapName: .pinkBlackMap)
        case .pinkStinkMap:
            self.setMapBackgroundOverlay(mapName: .pinkStinkMap)
        case .pinkWhiteMap:
            self.setMapBackgroundOverlay(mapName: .pinkWhiteMap)
        case .veryLightMap:
            self.setMapBackgroundOverlay(mapName: .veryLightMap)
        case .whiteAndBlackMap:
            self.setMapBackgroundOverlay(mapName: .whiteAndBlackMap)
        case .blackAndBlueGrayMap:
            self.setMapBackgroundOverlay(mapName: .blackAndBlueGrayMap)
        case .lightBlueGrayMap:
            self.setMapBackgroundOverlay(mapName: .lightBlueGrayMap)
        }
        displayOnTitle(displayMessage: "Map Title  \(mapStyleForView.rawValue)")
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
        mapView.add(tileOverlay)
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
    
    // MapView & Annotation (functions)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is User) { return nil }
        
        let userAnnotation = annotation as! User
        let reuseId = userAnnotation.userUID
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if anView == nil {
            // Public createAnnotation Function
            // --------------------------------
            anView = createAnnotation(annotation: userAnnotation)
        } else {
            anView!.annotation = annotation
        }
        
        anView?.centerOffset = CGPoint(x: -12.1, y: -40.4)
        return anView
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
        request.transportType = transportType
        
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
                    
                    print("Det vil ta \(self.user!.firstName) ca \(routeMinutes) minutter \(transportTypeString) til deg")
                    print("Avstanden er \(routeDistance) km")
                    
                    // https://stackoverflow.com/questions/23127795/how-to-offset-properly-an-mkmaprect
                    let mapRect = route.polyline.boundingMapRect
                    self.mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsetsMake(35, 10, 20, 10), animated: true)
                    
                    // let mapCamera = MKMapCamera(lookingAtCenter: (self.nanny?.location.coordinate)!, fromEyeCoordinate: (self.user?.location.coordinate)!, eyeAltitude: 400.0)
                    // mapCamera.heading = 80 // rotation
                    // self.mapView.setCamera(mapCamera, animated: true)
                }
            }
        }
    }
    
    // Center Map On Location Function : mapView.setRegion()
    func centerMapOnLocation(_ location: CLLocation, regionRadius: CLLocationDistance, animated: Bool) {
        let coordinateRadius = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.2, regionRadius * 2.2)
        mapView.setRegion(coordinateRadius, animated: animated)
    }
    
}
