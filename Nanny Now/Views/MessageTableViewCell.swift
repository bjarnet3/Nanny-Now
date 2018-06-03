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
    
    @IBOutlet weak var userStatusLbl: UILabel!
    @IBOutlet weak var userIndicatorLbl: UILabel!

    var cellImageLoaded = false
    
    func returnUserIndicator(from date: Date) {
        let now = Date()
        let timeSince = now.timeIntervalSince(date)
        
        let minutes = Int(timeSince) / 60
        let hours = minutes % 60
        // let days = hours % 24
        
        switch minutes {
        case 0 ..< 30:
            self.userStatusLbl.text = " \(minutes) min "
            self.userIndicatorLbl.textColor = UIColor.green
        case 30 ..< 90:
            self.userStatusLbl.text = " \(minutes) min siden "
            self.userIndicatorLbl.textColor = UIColor.yellow
        case 90 ..< 120:
            self.userStatusLbl.text = " 1,5 time siden "
            self.userIndicatorLbl.textColor = UIColor.orange
        case 120 ..< 300:
            self.userStatusLbl.text = " \(hours) timer siden "
            self.userIndicatorLbl.textColor = UIColor.orange
        case 300 ..< 1440:
            self.userStatusLbl.text = " flere timer siden "
            self.userIndicatorLbl.textColor = UIColor.orange
        case 1440 ..< 2880:
            self.userStatusLbl.text = " < 2 dager side "
            self.userIndicatorLbl.textColor = UIColor.red
        default:
            self.userStatusLbl.text = " flere dager siden "
            self.userIndicatorLbl.textColor = UIColor.gray
        }
        print(minutes)
    }
    
    var time: Date? {
        didSet {
            if let time = self.time {
                self.timeLabel.text = returnDayTimeString(from: time)
            }
        }
    }
    
    var userStatus: Date? {
        didSet {
            if let userStatus = self.userStatus {
                self.returnUserIndicator(from: userStatus)
            }
        }
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.userStatusLbl.layer.cornerRadius = self.userStatusLbl.frame.height / 2
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
                        self.time = stringToDateTime(message._messageTime)
                        self.userStatus = message.userStatus
                    })
                } else {
                    self.nameLabel.text = user.firstName
                    self.messageLabel.text = message._message
                    self.time = stringToDateTime(message._messageTime)
                    self.userStatus = message.userStatus
                }
                self.cellImageLoaded = true
            })
        }
    }
    
}
