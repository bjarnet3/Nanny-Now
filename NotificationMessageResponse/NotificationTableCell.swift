//
//  MessageDetailTableCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 13.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class NotificationTableCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: NannyImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextContraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    
    var dateTime: Date? {
        didSet {
            if self.hasDateTime {
                if let dateTime = self.dateTime {
                    self.dateLabel.text = dateTimeToString(from: dateTime)
                }
            }
        }
    }
    
    var hasDateTime: Bool = false
    
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
    
    func setupView(with message: MessageLite, to user: UserLite, animated: Bool = true, hasDateTime: Bool = false) {
        self.animateView(direction: .enter)
        
        self.hasDateTime = hasDateTime
        
        if let font = messageTextView.font {
            let mainBoundsWith = self.frame.width
            
            let messageText = message._message
            let messageTextWidth = mainBoundsWith - 106.0
            
            let linesForText = messageText.linesFor(font: font, width: messageTextWidth)
            let widthForText = messageText.widthFor(font: font)
            
            let constraintMin: CGFloat = 48.0
            let constraintMax: CGFloat = mainBoundsWith - 75.0
            
            print("widthForText \(widthForText), linesForText \(linesForText)")
            self.messageTextContraint.constant = linesForText == 1 ? constraintMax - widthForText : constraintMin
            
            self.profileImage.loadImageUsingCacheWith(urlString: user.imageName, completion: {
                if animated {
                    let random = Double(arc4random_uniform((UInt32(1000))) / 3000) + 250
                    UIView.animate(withDuration: 0.6, delay: random, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                        self.messageTextView.text = messageText
                        self.dateTime = message.messageTime
                    })
                    self.animateView(direction: .exit)
                } else {
                    self.messageTextView.text = messageText
                    self.dateTime = message.messageTime
                    self.animateView(direction: .exit)
                }
            })
        }
    }
    
}
