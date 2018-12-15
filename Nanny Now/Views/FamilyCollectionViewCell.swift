//
//  NannyTableViewCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 14.09.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit
import Firebase

class FamilyCollectionViewCell: UICollectionViewCell {
    
    // IBOutlet
    @IBOutlet weak var familyLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var profilImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func ratingsChecker(_ rating: Double) {
        switch rating
        {
        case 0.5..<1.5:
            self.ratingLabel.text = "★☆☆☆☆"
        case 1.5..<2.5:
            self.ratingLabel.text = "★★☆☆☆"
        case 2.5..<3.5:
            self.ratingLabel.text = "★★★☆☆"
        case 3.5..<4.5:
            self.ratingLabel.text = "★★★★☆"
        case 4.5...5.0:
            self.ratingLabel.text = "★★★★★"
        default:
            self.ratingLabel.text = "★★★★★"
            self.ratingLabel.isEnabled = false
        }
    }

    func distanceChecker(_ distance: Int) {
        let dist = Double(Double(distance) / 1000.0)
        let formatedDistance = String(format: "%.1f", dist)
        
        switch distance
        {
        case 0..<50:
            self.distanceLabel.text = "50 m"
        case 50..<100:
            self.distanceLabel.text = "100 m"
        case 100..<250:
            self.distanceLabel.text = "250 m"
        case 0..<500:
            self.distanceLabel.text = "500 m"
        case 500..<750:
            self.distanceLabel.text = "750 m"
        case 750..<950:
            self.distanceLabel.text = "950 m"
        default:
            self.distanceLabel.text = "\(formatedDistance) km"
        }
    }
    
    func setupView(family: Family) {
        self.familyLabel.text = family.familyName
        self.profilImage.loadImageUsingCacheWith(urlString: family.imageName)
        
        // This must fixed
        if let distance = family._distance {
            distanceChecker(Int(distance))
        } else {
            distanceChecker(1000)
        }
        
        ratingsChecker(family.returnAvrage)
    }
}
