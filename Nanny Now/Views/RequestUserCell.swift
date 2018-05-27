//
//  RequestTableViewCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 13.12.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit

class RequestUserCell: UITableViewCell {
    
    @IBOutlet weak var progressIndicatior: UIProgressView!
    @IBOutlet weak var cellImageView: NannyImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeFromLabel: UILabel!
    @IBOutlet weak var timeToLabel: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    var cellImageLoaded = false
    var hasSelected = false
    var hasOpened = false
    
    var timeFrom: Date? {
        didSet {
            if let timeFrom = self.timeFrom {
                self.timeFromLabel.text = returnDayTimeString(from: timeFrom)
            }
            
        }
    }
    
    var timeTo: Date? {
        didSet {
            if let timeTo = self.timeTo {
                self.timeToLabel.text = returnDayTimeString(from: timeTo)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.amount.layer.cornerRadius = 8.0
    }
    
    // MARK: - CATransform3DRotate
    // Thanx to - http://www.programering.com/a/MDN3YzMwATE.html
    // Recommend isHighlithed() insted of touchesBegan()
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.95, options: .curveEaseIn, animations: { () in
                self.hasSelected = true
                
                self.messageLabel.isHighlighted = true
                self.nameLabel.isHighlighted = true
                self.timeFromLabel.isHighlighted = true
                self.amount.isHighlighted = true
                self.timeToLabel.isHighlighted = true
                self.cellImageView.isHighlighted = true
                self.cellImageView.alpha = 1.0
            })
        }
        else {
            UIView.animate(withDuration: 0.20, delay: 0.05, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.95, options: .curveEaseIn, animations: { () in
                
                
            })
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.95, options: .curveEaseIn, animations: { () in
                
                self.messageLabel.isHighlighted = false
                self.nameLabel.isHighlighted = false
                self.timeFromLabel.isHighlighted = false
                self.amount.isHighlighted = false
                self.timeToLabel.isHighlighted = false
                self.cellImageView.isHighlighted = false
                self.cellImageView.alpha = 0.9
                
                self.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
                hapticButton(.selection)
            })
        }
        else {
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
            self.setNeedsDisplay(cellImageView.frame)
            self.contentView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            // self.layer.transform = CATransform3DMakeRotation(CGFloat.pi / 16, 0, 1, 0)
        } else {
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
            // self.layer.transform = CATransform3DMakeRotation(0, 0, 1, 0)
        }
    }
    
    func setupView(request: Request, animated: Bool = true) {
        if animated {
            animateView(direction: .enter)
            self.cellImageView.loadImageUsingCacheWith(urlString: request.imageName, completion: {
                let random = Double(arc4random_uniform(UInt32(1000))) / 3000
                UIView.animate(withDuration: 0.6, delay: random, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.animateView(direction: .exit)
                    
                    self.nameLabel.text = request.firstName
                    self.messageLabel.text = request.message
                    // self.timeFromLabel.text = request.timeFrom.description
                    self.timeFrom = stringToDateTime(request.timeFrom.description)
                    // self.timeToLabel.text = request.timeTo.description
                    self.timeTo = stringToDateTime(request.timeTo.description)
                    self.amount.text = " \(request.amount.description) kr  "
                })
                self.cellImageLoaded = true
            })
        } else {
            self.nameLabel.text = request.firstName
            self.messageLabel.text = request.message
            // self.timeFromLabel.text = request.timeFrom.description
            self.timeFrom = stringToDateTime(request.timeFrom.description)
            // self.timeToLabel.text = request.timeTo.description
            self.timeTo = stringToDateTime(request.timeTo.description)
            self.amount.text = " \(request.amount.description) kr  "
        }
    }
}
