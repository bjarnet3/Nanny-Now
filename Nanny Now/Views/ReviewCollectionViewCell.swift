//
//  ReviewCollectionViewCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 13.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class ReviewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var userReview: UILabel!
    @IBOutlet weak var userRating: UILabel!
    
    var cellImageLoaded = false
    
    public enum Direction {
        case enter
        case exit
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func animateView( direction: Direction) {
        if direction == .enter {
            self.contentView.alpha = 0
            self.setNeedsDisplay(profileImage.frame)
            self.contentView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            // self.layer.transform = CATransform3DMakeRotation(CGFloat.pi / 16, 0, 1, 0)
        } else {
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
            // self.layer.transform = CATransform3DMakeRotation(0, 0, 1, 0)
        }
    }
    
    func updateView(review: Review, animated: Bool = true) {
        animateView(direction: .enter)
        
        let reviews = review
        
        self.profileImage.loadImageUsingCacheWith(urlString: reviews.userImage, completion: {
            if animated {
                let random = Double(arc4random_uniform((UInt32(1000))) / 3000) + 250
                UIView.animate(withDuration: 0.6, delay: random, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    
                    self.animateView(direction: .exit)
                    
                    self.profileName.text = review.userName
                    self.userReview.text = review.reviewMessage
                    self.userRating.text = review.reviewRating
                    
                })
            } else {
                self.animateView(direction: .exit)
            }
            self.cellImageLoaded = true
        })
    }
}
