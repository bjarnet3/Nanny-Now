//
//  NannyTableViewCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 14.09.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit
import Firebase

class NannyTableViewCell: UITableViewCell {
    
    // IBOutlet
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var yrkeLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var vandelLabel: UILabel!
    @IBOutlet weak var profilImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gender = genderLabel.text {
            if gender.first == Character("M") {
                profilImage.layer.borderWidth = 1.6
                profilImage.layer.borderColor = ORANGE_SOLID.cgColor
            } else if gender.first == Character("K") {
                profilImage.layer.borderWidth = 1.6
                profilImage.layer.borderColor = PINK_SOLID.cgColor
            } else {
                profilImage.layer.borderWidth = 1.6
                profilImage.layer.borderColor = BLACK_SOLID.cgColor
            }
        } else {
            profilImage.layer.borderWidth = 1.6
            profilImage.layer.borderColor = BLACK_SOLID.cgColor
        }
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
    
    func hasPoliceAttest(checked: Bool) {
        if checked {
            self.vandelLabel.text = "Godkjent Vandel"
            self.vandelLabel.textColor = UIColor.gray
        } else {
            self.vandelLabel.text = "Ikke levert Vandel"
            self.vandelLabel.textColor = UIColor.red
        }
    }
    
    func setupView(nanny: Nanny) {
        self.nameLabel.text = nanny.firstName
        self.ageLabel.text = "\(nanny.age) år"
        self.genderLabel.text = nanny.gender
        self.yrkeLabel.text = nanny.jobTitle
        self.profilImage.loadImageUsingCacheWith(urlString: nanny.imageName)
        
        // This must fixed
        if let distance = nanny._distance {
            distanceChecker(Int(distance))
        } else {
            distanceChecker(1000)
        }
        ratingsChecker(nanny.returnAvrage)
        hasPoliceAttest(checked: nanny.policeAttest)
    }
}
