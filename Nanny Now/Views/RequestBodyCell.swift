//
//  MessageBodyCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 14.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import QuartzCore

class RequestBodyCell: UITableViewCell {
    
    @IBOutlet weak var cellImageView: CustomImageView!
    
    @IBOutlet weak var welcomeTitleLabel: UILabel!
    @IBOutlet weak var welcomeMsgLabel: UILabel!
    
    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var acceptedLabel: UILabel!
    @IBOutlet weak var completeLabel: UILabel!
    
    var user: User?
    
    // Property Observer
    var pendingCount: Int = 0 {
        didSet {
            self.pendingLabel.text = "\(pendingCount) pending"
        }
    }
    
    var acceptedCount: Int = 0 {
        didSet {
            self.acceptedLabel.text = "\(acceptedCount) accepted"
        }
    }
    
    var completeCount: Int = 0 {
        didSet {
            self.completeLabel.text = "\(completeCount) complete"
        }
    }
    
    public enum Direction {
        case enter
        case exit
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // cellImageView.layer.cornerRadius = cellImageView.layer.frame.height / 2
        
    }
    
    func animateView( direction: Direction) {
        if direction == .enter {
            self.contentView.alpha = 0
            // self.setNeedsDisplay(profileView.frame)
            self.contentView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            // self.layer.transform = CATransform3DMakeRotation(CGFloat.pi / 16, 1, 0, 0)
        } else {
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
            // self.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
        }
    }
    
    // MARK: - Update View
    func setupView(user: User, animated: Bool = false) {
        animateView(direction: .enter)
        self.cellImageView.loadImageUsingCacheWith(urlString: user.imageName, completion: {
            if animated {
                let random = Double(arc4random_uniform(UInt32(1000))) / 2000 
                UIView.animate(withDuration: 0.6, delay: random * 1.5, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.animateView(direction: .exit)
                })
            } else {
                self.animateView(direction: .exit)
            }
            self.welcomeTitleLabel.text = "Hello, \(user.firstName)..."
            self.welcomeMsgLabel.text = "Prepare yourself for your next appointment."
            self.user = user
        })
        
    }
}
