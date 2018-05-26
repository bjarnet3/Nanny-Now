//
//  MessageAllCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 04.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var cellImageLoaded = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public enum Direction {
        case enter
        case exit
    }
    
    func animateView( direction: Direction) {
        if direction == .enter {
            self.contentView.alpha = 0
            self.setNeedsDisplay(profileImage.frame)
            self.contentView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        } else {
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
        }
    }
    
    func setupView(with message: Message, animated: Bool = true) {
        if let user = message._fromUser {
            self.cellImageLoaded = false
            self.profileImage.loadImageUsingCacheWith(urlString: user.imageName, completion: {
                if animated {
                    self.animateView(direction: .enter)
                    let random = Double(arc4random_uniform(UInt32(1000))) / 3000
                    UIView.animate(withDuration: 0.6, delay: random, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                        self.animateView(direction: .exit)
                        
                        self.nameLabel.text = user.firstName
                        self.messageLabel.text = message._message
                        self.timeLabel.text = message._messageTime
                    })
                } else {
                    self.nameLabel.text = user.firstName
                    self.messageLabel.text = message._message
                    self.timeLabel.text = message._messageTime
                }
                self.cellImageLoaded = true
            })
        }
    }
    
}
