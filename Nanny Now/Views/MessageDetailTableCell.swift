//
//  MessageDetailTableCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 13.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class MessageDetailTableCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: NannyImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public enum Direction {
        case enter
        case exit
    }
    
    func animateView( direction: Direction) {
        if direction == .enter {
            self.contentView.alpha = 0.0
            self.setNeedsDisplay(profileImage.frame)
            self.contentView.transform = CGAffineTransform(scaleX: 0.85, y: -0.85)
        } else {
            self.contentView.alpha = 1.0
            self.contentView.transform = CGAffineTransform(scaleX: 1.00, y: -1.00)
        }
    }
    
    func setupView(with message: Message, to user: User, animated: Bool = false) {
        self.animateView(direction: .enter)
        self.profileImage.loadImageUsingCacheWith(urlString: user.imageName, completion: {
            if animated {
                let random = Double(arc4random_uniform((UInt32(1000))) / 3000) + 250
                UIView.animate(withDuration: 0.6, delay: random, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    
                    self.messageLabel.text = message._message
                    self.animateView(direction: .exit)
                })
            } else {
                self.messageLabel.text = message._message
                self.animateView(direction: .exit)
            }
            print(user.imageName)
        })
    }
    
}
