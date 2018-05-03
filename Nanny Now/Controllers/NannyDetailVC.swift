//
//  NannyDetailVC.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 19.09.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class NannyDetailVC: UIViewController {
    
    // MARK: - IBOutlet: Connection to Storyboard
    // ----------------------------------------
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: CustomImageView!
    
    @IBOutlet weak var nameAgeLbl: UILabel!
    @IBOutlet weak var yrkeLbl: UILabel!
    @IBOutlet weak var ratingsLbl: UILabel!
    @IBOutlet weak var transportSeg: UISegmentedControl!
    
    // MARK: - Properties: Array and Varables
    // -------------------------------------
    var nannyImage: UIImage!
    
    // The "Nanny" Object from Nanny ViewController
    var user: User?
    var nanny: Nanny?
    
    var headerTitles = ["Felles Forbindelser", "Tilbakemelding"]
    var cellHeight: [CGFloat] = [100.0, 125.0]
    var rowsInSection = [2,2,1]
    
    // var mutualFriends = [String:String]()
    
    var reviews = [Review]()
    var friends = [Friends]()
    
    let regionRadius: CLLocationDistance = 30000
    
    // MARK: - IBAction: Methods connected to UI
    // ----------------------------------------
    @IBAction func changeTransportType(_ sender: UISegmentedControl) {
        // Remove overlays
        self.mapView.removeOverlays(mapView.overlays)
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.showRouteOnMap(transportType: .walking)
        case 1:
            self.showRouteOnMap(transportType: .transit)
        case 2:
            self.showRouteOnMap(transportType: .automobile)
        default:
            self.showRouteOnMap(transportType: .automobile)
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions:
    // ----------------------------------------
    func initData(forImage image: UIImage, nanny: Nanny, user: User, myLocation: CLLocation) {
        self.nanny = nanny
        self.user = user
        
        self.nanny?.setAnnotation()
        self.user?.setAnnotation()
        
        checkMutualFriends(nanny: nanny, user: user)
        getReviewsAndRatings(nanny: nanny)
        self.nannyImage = image
    }
    
    func checkMutualFriends(nanny: Nanny, user: User) {
        // FIXME: - This need to be fixed to REF_USERS_PUBLIC
        DataService.instance.REF_USERS_PUBLIC.child(nanny.userUID).child("friends").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
            print(snapshot.childrenCount)
            var nannyFriends = [String:String]()
            if let snap = snapshot.value as? [String:String] {
                nannyFriends = snap
            }
            DataService.instance.REF_USERS_PUBLIC.child(user.userUID).child("friends").observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() { return }
                if let snap = snapshot.value as? [String:String] {
                    for (uid, name) in nannyFriends {
                        print(" -- ")
                        if snap.index(forKey: uid) != nil {
                            
                            DataService.instance.REF_USERS_PRIVATE.child(uid).child("imageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
                                
                                if let imageURL = snapshot.value as? String {
                                    // self.mutualFriends.updateValue(val, forKey: imageVal)
                                    let friend = Friends(name: name, userUID: uid, imageURL: imageURL)
                                    self.friends.append(friend)
                                    self.tableView.reloadData()
                                }
                            })
                            
                        } else {
                            self.tableView.reloadData()
                            print("snap.index is nil")
                        }
                    }
                }
                
            })
        })
    }

    func getReviewsAndRatings(nanny: Nanny) {
        DataService.instance.REF_USERS_PUBLIC.child(nanny.userUID).child("reviews").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() { return }
            if let snap = snapshot.value as? [String:Any] {
                for (key,val) in snap {
                    if snap.index(forKey: key) != nil {
                        // self.userReviews.updateValue(val, forKey: key)
                        self.setReviewsAndRatings(key: key, value: val)
                        
                    }
                }
            }
        })
    }
    
    func setReviewsAndRatings(key: String, value: Any) {
        let userUID = key
        if let value = value as? [String:Any] {
            print(value)
            DataService.instance.REF_USERS_PRIVATE.child(userUID).child("imageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
                if let userImage = snapshot.value as? String {
                    
                    if let requestID = value["requestID"] as? String {
                        if let requestDate = value["requestDate"] as? String {
                            
                            if let reviewRating = value["reviewRating"] as? Int {
                                if let reviewMessage = value["reviewMessage"] as? String {
                                    
                                    if let userName = value["userName"] as? String {
                                        
                                        let review = Review(requestID: requestID, requestDate: requestDate, reviewRating: returnStarsStringFrom(Double(reviewRating)), reviewMessage: reviewMessage, userUID: userUID, userName: userName, userImage: userImage)
                                        
                                        self.reviews.append(review)
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    // MARK: - ViewDidLoad, ViewWillLoad etc...
    // ----------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // getReviewsAndRatings(nanny: nanny!)
        self.tableView.reloadData()
        
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        // Set the estimatedRowHeight to a non-0 value to enable auto layout.
        tableView.estimatedRowHeight = 160
        
        transportSeg.layer.cornerRadius = transportSeg.frame.height / 2
        transportSeg.layer.borderColor = UIColor.white.cgColor
        transportSeg.layer.borderWidth = 1.0
        transportSeg.layer.masksToBounds = true
        
        profileImage.image = nannyImage
        nameAgeLbl.text = "\(nanny!.firstName) (\(nanny!.age) år)"
        yrkeLbl.text = "\(nanny?.jobTitle ?? "")"
        ratingsLbl.text = "\(nanny!.ratingStar)"
        
        mapView.addAnnotation(user!)
        mapView.addAnnotation(nanny!)
        
        centerMapOnLocation(location: calculateCenterPositionFromArrayOfLocations(mapView.annotations))
        showRouteOnMap()
    }
    
    override func viewDidLayoutSubviews() {
        print(self.reviews.count)
        
    }
}

// MARK: - MKMapView, showRouteOnMap...
// ----------------------------------------
extension NannyDetailVC: MKMapViewDelegate {
    
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
                    
                    print("Det vil ta \(self.nanny!.firstName) ca \(routeMinutes) minutter \(transportTypeString) til deg")
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
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

// MARK: - TableView & TableViewDelegate...
// ----------------------------------------
extension NannyDetailVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row % 2 == 0 ? 55 : self.cellHeight[indexPath.section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsInSection[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // let isMutualFriends = mutualFriends.count > 0 ? 1 : 0
        let isFriends = friends.count > 0 ? 1 : 0
        let isReviews = reviews.count > 0 ? 1 : 0
        return isFriends + isReviews
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as? HeaderTableViewCell, indexPath.row % 2 == 0 {
            cell.updateTitle(headerTitles[indexPath.section])
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as? FriendsTableViewCell, indexPath.section <= 0 && friends.count > 0 {
            // cell.updateData(mutualFriends: self.mutualFriends)
            cell.updateData(friends: self.friends)
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell") as? ReviewTableViewCell {
            cell.updateData(reviews: self.reviews)
            return cell
        }
        return ReviewTableViewCell()
    }
    
    
}

// MARK: - Preview Action - Peak and Pop
// ----------------------------------------
extension NannyDetailVC {
    // This is the "Peak & Pop" method
    override var previewActionItems: [UIPreviewActionItem] {
        let send = UIPreviewAction(title: "Send Forespørsel",
                                   style: .default,
                                   handler: { previewAction, viewController in
                                    // sendNotification((self.nanny?.userID)!,"message",.nannyRequest, "")
                                    Notifications.instance.sendNotification(to: (self.nanny?.userUID)!, text: "message", categoryRequest: .nannyRequest)
        })
        
        let avbryt = UIPreviewAction(title: "Avbryt",
                                     style: .destructive,
                                     handler: { previewAction, viewController in
        })
        
        let selected = UIPreviewAction(title: "Selected",
                                       style: .selected,
                                       handler: { previewAction, viewController in
        })
        
        let groupActions = UIPreviewActionGroup(title: "Instillinger...",
                                                style: .default,
                                                actions: [selected, avbryt])
        return [send, avbryt, groupActions]
    }
}
