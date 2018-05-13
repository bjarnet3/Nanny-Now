//
//  FamilyTableViewCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 07.12.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit
import MapKit

/// UITableViewCell with folding animation
class FamilyTableViewCell: FoldingCell {
    
    // MARK: - IBOutlet: Connection to View "storyboard"
    // -------------------------------------------------
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var closeNumberLabel: UILabel!
    @IBOutlet weak var openNumberLabel: UILabel!
    
    @IBOutlet weak var familyName: UILabel!
    @IBOutlet weak var firstNames: UILabel!
    
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    
    // @IBOutlet weak var profileImage1: CustomImageView!
    @IBOutlet weak var profileImage2: CustomImageView!
    
    // MARK: - Properties: Array, Constants and Varables
    // -------------------------------------------------
    private var _distance: String?
    private var _familyLocation: CLLocation?
    private var _nannyLocation: CLLocation?
    private var _image: UIImage?
    
    var twoLocations = [AnyObject]()
    let regionRadius: CLLocationDistance = 4000

    var number: Int = 0 {
        didSet {
            closeNumberLabel.text = String(number)
            openNumberLabel.text = String(number)
        }
    }

    // MARK: - Functions, initData and updateView
    // ------------------------------------------
    func initData(for image: UIImage) {
        self._image = image
    }
    
    func setupView(family: Families, user: User) {
        self.familyName.text = family.lastName
        self.firstNames.text = family.firstName
        self.timeLbl.text = family.requestStart
        self.amountLbl.text = family.requestAmount
        // self.profileImage1.loadImageUsingCacheWith(urlString: family.imageName)
        self.profileImage2.loadImageUsingCacheWith(urlString: family.imageName)
        self._distance = family.returnDistanceString()
        self._familyLocation = family.location
        self._nannyLocation = user.location
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
    
    override func animationDuration(_ itemIndex: NSInteger, type: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
}

// MARK: - MKMapView, centerMapOnLocation & setRoute
// -------------------------------------------------
extension FamilyTableViewCell: MKMapViewDelegate {
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.purple
        renderer.lineWidth = 5
        return renderer
    }
    
    func setRoute(from annotations: [MKPointAnnotation]?) {
        let request = MKDirectionsRequest()
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
                self.mapView.add(route.polyline)
                if route == unwrappedResponse.routes.last {
                    // https://stackoverflow.com/questions/23127795/how-to-offset-properly-an-mkmaprect
                    let mapRect = route.polyline.boundingMapRect
                    self.mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 15,left: 10,bottom: 15,right: 10), animated: true)
                }
            }
        }
    }
    
}

