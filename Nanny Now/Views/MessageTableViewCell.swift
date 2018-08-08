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
    
    @IBOutlet weak var brandingLabel: UILabel!
    
    @IBOutlet weak var userStatusLbl: UILabel!
    @IBOutlet weak var userIndicatorLbl: UILabel!

    public var cellImageLoaded = false
    public var hasSelected = false
    public var hasOpened = false
    
    private func returnUserIndicator(from date: Date) {
        let now = Date()
        let timeSince = now.timeIntervalSince(date)
        
        let minutes = Int(timeSince) / 60
        let hours = minutes / 60
        let days = hours / 24
        
        switch minutes {
        case 0 ..< 30:
            self.userStatusLbl.text = " \(minutes) min   "
            self.userIndicatorLbl.textColor = UIColor.green
        case 30 ..< 60:
            self.userStatusLbl.text = " \(minutes) min siden   "
            self.userIndicatorLbl.textColor = UIColor.yellow
        case 60 ..< 100:
            self.userStatusLbl.text = " 1 time siden   "
            self.userIndicatorLbl.textColor = UIColor.orange
        case 100 ..< 1440:
            self.userStatusLbl.text = " \(hours) timer siden   "
            self.userIndicatorLbl.textColor = UIColor.orange
        case 1440 ..< 2880:
            self.userStatusLbl.text = " 1 dag siden   "
            self.userIndicatorLbl.textColor = UIColor.red
        default:
            self.userStatusLbl.text = " \(days) dager siden   "
            self.userIndicatorLbl.textColor = UIColor.gray
        }
    }
    
    private var time: Date? {
        didSet {
            if let time = self.time {
                self.timeLabel.text = returnDayTimeString(from: time)
            }
        }
    }
    
    private var userStatus: Date? {
        didSet {
            if let userStatus = self.userStatus {
                self.returnUserIndicator(from: userStatus)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.profileImage.layer.borderColor = UIColor.white.cgColor
        self.profileImage.layer.cornerRadius = self.profileImage.layer.bounds.height / 2
        self.profileImage.layer.borderWidth = 0.85
        self.profileImage.layer.masksToBounds = true
        self.profileImage.layer.addShadow()
        
        self.userStatusLbl.layer.cornerRadius = self.userStatusLbl.frame.height / 2
        
        self.brandingLabel.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.brandingLabel.layer.cornerRadius = self.brandingLabel.frame.height / 2
        self.brandingLabel.clipsToBounds = true
    }
    
    public enum Direction {
        case enter
        case exit
    }
    
    private func setHighlightedOnTextAnd(highlighted: Bool = false) {
        self.nameLabel.textColor = BLACK_SOLID
        self.nameLabel.highlightedTextColor = UIColor.darkGray
        self.nameLabel.isHighlighted = highlighted
        
        self.messageLabel.textColor = PINK_DARK_SHARP
        self.messageLabel.highlightedTextColor = PINK_TABBAR_UNSELECTED
        self.messageLabel.isHighlighted = highlighted
        
        self.timeLabel.textColor = UIColor.darkGray
        self.timeLabel.highlightedTextColor = UIColor.lightGray
        self.timeLabel.isHighlighted = highlighted
    }
    
    private func animateView( direction: Direction) {
        if direction == .enter {
            self.contentView.alpha = 0
            // self.setNeedsDisplay(profileImage.frame)
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
                    self.hasOpened = message._highlighted
                    
                    self.nameLabel.text = user.firstName
                    self.messageLabel.text = message._message
                    self.time = stringToDateTime(message._messageTime)
                    self.userStatus = message.userStatus
                }
                self.setHighlightedOnTextAnd(highlighted: message._highlighted)
                self.cellImageLoaded = true
            })
        }
    }
    
}
