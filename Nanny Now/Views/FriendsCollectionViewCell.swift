//
//  FriendsCollectionViewCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 29.12.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit

class FriendsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    
    private enum Direction {
        case enter
        case exit
    }

    private func animateView( direction: Direction) {
        if direction == .enter {
            self.contentView.alpha = 0
            self.setNeedsDisplay(profileImageView.frame)
            self.contentView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            // self.layer.transform = CATransform3DMakeRotation(CGFloat.pi / 16, 0, 1, 0)
        } else {
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
            // self.layer.transform = CATransform3DMakeRotation(0, 0, 1, 0)
        }
    }
    
    func setupView(friend: Friends, animated: Bool = true) {
        animateView(direction: .enter)
        
        let userName = friend.name
        let imageName = friend.imageURL
        
        self.profileImageView.loadImageUsingCacheWith(urlString: imageName, completion: {
            if animated {
                let random = Double(arc4random_uniform((UInt32(1000))) / 3000) + 250
                UIView.animate(withDuration: 0.6, delay: random, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.profileNameLabel.text = userName
                    self.animateView(direction: .exit)
                })
            } else {
                self.profileNameLabel.text = userName
                self.animateView(direction: .exit)
            }
        })
    }
    
}
