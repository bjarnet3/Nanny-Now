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
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.95, options: .curveEaseIn, animations: { () in
                self.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
                hapticButton(.selection)
            })
        }
        else {
            // var rollBack3D = CATransform3DIdentity
            UIView.animate(withDuration: 0.20, delay: 0.05, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.95, options: .curveEaseIn, animations: { () in
                self.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
            })
        }
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
    
    func setupView(with message: Message, animated: Bool = false) {
        if let user = message._remoteUser {
            func setLabels() {
                self.nameLabel.text = user.firstName
                self.messageLabel.text = message._message
                self.timeLabel.text = message._messageTime
            }
            if animated {
                animateView(direction: .enter)
                self.profileImage.loadImageUsingCacheWith(urlString: user.imageName, completion: {
                    let random = Double(arc4random_uniform((UInt32(1000))) / 3000) + 250
                    UIView.animate(withDuration: 0.6, delay: random, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                        self.animateView(direction: .exit)
                        setLabels()
                    })
                })
            } else {
                self.profileImage.loadImageUsingCacheWith(urlString: user.imageName)
                setLabels()
            }
        }
        
    }
    
}
