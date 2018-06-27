//
//  FirstTableViewCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 25.11.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit

class StartTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var backMiddleView: CustomImageView!
    @IBOutlet weak var profileImageView: CustomImageView!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var yrkeLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!

    func setupView(user: User) {
        profileImageView.loadImageUsingCacheWith(urlString: user.imageName)
        let age = calcAge(birthday: user.birthday)
        nameLbl.text = "\(user.firstName) (\(age) år)"
        yrkeLbl.text = "\(user.jobTitle)"
        descriptionLbl.text = "\(user.ratingStar)"
    }
}
