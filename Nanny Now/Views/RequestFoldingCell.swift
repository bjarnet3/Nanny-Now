//
//  RequestFoldingCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 07.09.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import MapKit

class RequestFoldingCell: UXFoldingCell {
    // MARK: - IBOutlet: Connection to View "storyboard"
    // -------------------------------------------------
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cellImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userStatusLbl: UILabel!
    @IBOutlet weak var userIndicatorLbl: UILabel!
    
    @IBOutlet weak var requestStatusLbl: UILabel!
    @IBOutlet weak var requestIndicatorLbl: UILabel!
    
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var timeFromLbl: UILabel!
    @IBOutlet weak var timeToLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    
    // MARK: - Properties: Array, Constants and Varables
    // -------------------------------------------------
    private var _distance: String?
    private var _familyLocation: CLLocation?
    private var _nannyLocation: CLLocation?
    private var _image: UIImage?
    
    var twoLocations = [AnyObject]()
    let regionRadius: CLLocationDistance = 4000
    
    var cellImageLoaded = false
    var hasSelected = false
    // var hasOpened = false
    
    func returnRequestIndicator(status: RequestStatus = .pending) {
        switch status {
        case .accepted:
            self.requestIndicatorLbl.textColor = UIColor.green
            self.requestIndicatorLbl.text = "•"
        case .complete:
            self.requestIndicatorLbl.textColor = PINK_TABBAR_UNSELECTED
            self.requestIndicatorLbl.text = "•"
        case .pending:
            self.requestIndicatorLbl.textColor = UIColor.orange
            self.requestIndicatorLbl.text = "•"
        case .rejected:
            self.requestIndicatorLbl.textColor = UIColor.red
            self.requestIndicatorLbl.text = "•"
        default:
            self.requestIndicatorLbl.textColor = ORANGE_NANNY_LOGO
            self.requestIndicatorLbl.text = "•"
        }
    }
    
    func returnUserIndicator(from date: Date) {
        let now = Date()
        let timeSince = now.timeIntervalSince(date)
        
        let minutes = Int(timeSince) / 60
        let hours = minutes / 60
        let days = hours / 24
        
        switch minutes {
        case 0 ..< 30:
            self.userStatusLbl.text = "\(minutes) min"
            self.userIndicatorLbl.textColor = UIColor.green
        case 30 ..< 90:
            self.userStatusLbl.text = "\(minutes) min"
            self.userIndicatorLbl.textColor = UIColor.yellow
        case 90 ..< 120:
            self.userStatusLbl.text = "1,5 time"
            self.userIndicatorLbl.textColor = UIColor.orange
        case 120 ..< 1440:
            self.userStatusLbl.text = "\(hours) timer"
            self.userIndicatorLbl.textColor = UIColor.orange
        case 1440 ..< 2880:
            self.userStatusLbl.text = " 1 døgn siden"
            self.userIndicatorLbl.textColor = UIColor.red
        default:
            self.userStatusLbl.text = "\(days) dager"
            self.userIndicatorLbl.textColor = UIColor.gray
        }
        print(minutes)
    }
    
    var requestStatus: RequestStatus? {
        didSet {
            if let requestStatus = self.requestStatus {
                self.requestStatusLbl.text = requestStatus.rawValue
                returnRequestIndicator(status: requestStatus)
            }
        }
    }
    
    var userStatus: Date? {
        didSet {
            if let userStatus = self.userStatus {
                self.userStatusLbl.text = userStatus.description
                self.returnUserIndicator(from: userStatus)
            }
        }
    }
    
    var timeFrom: Date? {
        didSet {
            if let timeFrom = self.timeFrom {
                self.timeFromLbl.text = returnDayTimeString(from: timeFrom)
            }
        }
    }
    
    var timeTo: Date? {
        didSet {
            if let timeTo = self.timeTo {
                self.timeToLbl.text = returnDayTimeString(from: timeTo)
            }
        }
    }
    
    func setProfileImage() {
        self.cellImageView.clipsToBounds = true
        self.cellImageView.layer.cornerRadius = self.cellImageView.layer.bounds.height / 2
        self.cellImageView.layer.borderColor = UIColor.white.cgColor
        self.cellImageView.layer.borderWidth = 0.85
        
        self.cellImageView.layer.addShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setProfileImage()
        self.amountLbl.layer.cornerRadius = self.amountLbl.frame.height / 2
    }
    
    public enum Direction {
        case enter
        case exit
    }
    
    func animateView( direction: Direction) {
        if direction == .enter {
            self.contentView.alpha = 0
            self.contentView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        } else {
            setProfileImage()
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
        }
    }
    
    func setupView(request: Request, animated: Bool = true) {
        self.cellImageLoaded = false
        self.cellImageView.loadImageUsingCacheWith(urlString: request.imageName, completion: {
            if animated {
                self.animateView(direction: .enter)
                let random = Double(arc4random_uniform(UInt32(1000))) / 3000
                UIView.animate(withDuration: 0.6, delay: random, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.animateView(direction: .exit)
                    
                    self._distance = request.family.returnDistance
                    self._familyLocation = request.family.location
                    self._nannyLocation = request.user.location
                    
                    self.nameLabel.text = request.firstName
                    self.messageLbl.text = request.message
                    
                    self.requestStatus = requestStatusString(request: request.requestStatus)
                    self.userStatus = request.userStatus
                    
                    self.timeFrom = stringToDateTime(request.timeFrom)
                    self.timeTo = stringToDateTime(request.timeTo)
                    self.amountLbl.text = " \(request.amount) kr   "
                })
            } else {
                self.animateView(direction: .exit)
                self.nameLabel.text = request.firstName
                self.messageLbl.text = request.message
                
                self.requestStatus = requestStatusString(request: request.requestStatus)
                self.userStatus = request.userStatus
                
                self.timeFrom = stringToDateTime(request.timeFrom)
                self.timeTo = stringToDateTime(request.timeTo)
                self.amountLbl.text = " \(request.amount) kr   "
            }
            self.cellImageLoaded = true
        })
    }
    
    // MARK: - awakeFromNib, setSelected and animationDuration
    // -------------------------------------------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.8).cgColor
        self.contentView.layer.shadowOpacity = 0.5
        self.contentView.layer.shadowRadius = 10.0
        self.contentView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
        self.foregroundView.layer.cornerRadius = 10
        self.foregroundView.layer.masksToBounds = true
        self.containerView.layer.cornerRadius = 10
        self.containerView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.mapView.delegate = self
            twoLocations.append(_familyLocation!)
            twoLocations.append(_nannyLocation!)
            centerMapOnLocation(location: calculateCenterPositionFromArrayOfLocations(twoLocations))
            setRoute(from: nil)
        }
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type: RequestFoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
}

// MARK: - MKMapView, centerMapOnLocation & setRoute
// -------------------------------------------------
extension RequestFoldingCell: MKMapViewDelegate {
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.purple
        renderer.lineWidth = 5
        return renderer
    }
    
    func setRoute(from annotations: [MKPointAnnotation]?) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: (_nannyLocation?.coordinate)!, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: (_familyLocation?.coordinate)!, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        // let annotation = annotations.last as! Family
        // let arrivaleDate = annotation.requestStart  // 3600 One Hour from Date()
        // request.arrivalDate = arrivaleDate
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                if route == unwrappedResponse.routes.last {
                    // https://stackoverflow.com/questions/23127795/how-to-offset-properly-an-mkmaprect
                    let mapRect = route.polyline.boundingMapRect
                    self.mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 15,left: 10,bottom: 15,right: 10), animated: true)
                }
            }
        }
    }
    
}

