//
//  RequestTableViewCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 13.12.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit

class RequestUserCell: UITableViewCell {
    
    @IBOutlet weak var imageName: NannyImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var timeFromLabel: UILabel!
    @IBOutlet weak var timeToLabel: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    var cellImageLoaded = false
    var hasSelected = false
    var hasOpened = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /*
        self.backgroundColor = WHITE_SOLID
        self.profileImage.layer.borderColor = PINK_NANNY_LOGO.cgColor
        self.profileImage.layer.borderWidth = 0.9
        
        self.nameLbl.textColor = UIColor.darkText
        self.textLbl.textColor = PINK_TABBAR_SELECTED
        self.timeFromLbl.textColor = UIColor.darkText
        self.timeToLbl.textColor = UIColor.darkGray
        self.amountLbl.textColor = UIColor.darkGray
        */
        // self.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        // self.layer.frame = self.layer.frame.offsetBy(dx: -(self.frame.width / 2), dy: 0)
    }
    
    // MARK: - CATransform3DRotate
    // Thanx to - http://www.programering.com/a/MDN3YzMwATE.html
    // Recommend isHighlithed() insted of touchesBegan()

    /*
    //Touches Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        if let touch = touches.first {
            let position = touch.location(in: nil)
            
            let scaleLenght = self.frame.width / 2
            
            let maxPosition = (CGFloat.pi/2.0)
            let minPosition = maxPosition / scaleLenght
            
            let currentPosition = minPosition * (position.x - scaleLenght)
            
            // Nice ternary operator
            // let transformRadius = position.x < self.frame.width / 2 ? -currentPosition : currentPosition
            var transform3D = CATransform3DIdentity
            
            UIView.animate(withDuration: 0.20, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.10, options: .curveEaseIn, animations: { () in
                
                transform3D.m34 = -1.0 / 400.0
                transform3D = CATransform3DRotate(transform3D, currentPosition, 0, 1, 0)
                
                self.layer.transform = transform3D
                hapticButton(.heavy)
            })
        }
    }
    // Touches Ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("toucheEnded")
        var rollBack3D = CATransform3DIdentity
        
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.175, options: .curveEaseOut, animations: { () in
            
            rollBack3D.m34 = -1.0 / 400.0
            rollBack3D = CATransform3DRotate(rollBack3D, 0, 0, 1, 0)
            
            self.layer.transform = rollBack3D
            hapticButton(.selection)
        })
    }
    
    // Dont repeat yourself,, yea yea...
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchCancelled")
        
        var rollBack3D = CATransform3DIdentity
        
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.175, options: .curveEaseOut, animations: { () in
            
            rollBack3D.m34 = -1.0 / 400.0
            rollBack3D = CATransform3DRotate(rollBack3D, 0, 0, 1, 0)
            
            self.layer.transform = rollBack3D
            hapticButton(.selection)
        })
        
        /*
        var rollBack3D = CATransform3DIdentity
        
        UIView.animate(withDuration: 0.30, delay: 0.05, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.11, options: .curveEaseIn, animations: { () in
            
            rollBack3D.m34 = -1.0 / 400.0
            rollBack3D = CATransform3DRotate(rollBack3D, 0, 0, 1, 0)
            
            self.layer.transform = rollBack3D
            hapticButton(.warning)
        })
        */
    }
    
    /*
    // MARK: - Set Selected and Set Highlighted
    /*
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.layer.backgroundColor = PINK_DARK_SOLID.cgColor
            self.profileImage.layer.borderColor = WHITE_ALPHA.cgColor
            self.nameLbl.textColor = WHITE_SOLID
            self.textLbl.textColor = WHITE_SOLID
            self.timeFromLbl.textColor = WHITE_SOLID
            self.timeToLbl.textColor = WHITE_SOLID
            self.amountLbl.textColor = WHITE_SOLID
        } else {
            self.backgroundColor = WHITE_SOLID
            self.profileImage.layer.borderColor = WHITE_ALPHA.cgColor
            self.nameLbl.textColor = UIColor.darkText
            self.textLbl.textColor = PINK_TABBAR_SELECTED
            self.timeFromLbl.textColor = UIColor.darkText
            self.timeToLbl.textColor = UIColor.darkGray
            self.amountLbl.textColor = UIColor.darkGray
        }
    }
     
    */
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            // Nice ternary operator
            let transformRadius = (CGFloat.pi/20.0)
            var transform3D = CATransform3DIdentity
            
            UIView.animate(withDuration: 0.20, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.10, options: .curveEaseIn, animations: { () in
                
                transform3D.m34 = -1.0 / 500.0
                transform3D = CATransform3DRotate(transform3D, transformRadius, 0, 1, 0)
                
                // self.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
                // self.layer.frame = self.layer.frame.offsetBy(dx: -(self.frame.width / 2), dy: 0)
                self.layer.transform = transform3D
                
                hapticButton(.heavy)
            })
        }
        else {
            var rollBack3D = CATransform3DIdentity
            
            UIView.animate(withDuration: 0.30, delay: 0.05, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.11, options: .curveEaseIn, animations: { () in
                
                rollBack3D.m34 = -1.0 / 500.0
                rollBack3D = CATransform3DRotate(rollBack3D, 0, 0, 1, 0)
                
                self.layer.transform = rollBack3D
                hapticButton(.warning)
            })
        }
    }
     */
    */
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            // Nice ternary operator
            // let transformRadius = (CGFloat.pi/10.0)
            // var transform3D = CATransform3DIdentity
            
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.95, options: .curveEaseIn, animations: { () in
                
                // transform3D.m34 = -1.0 / 500.0
                // transform3D = CATransform3DRotate(transform3D, transformRadius, 1, 0, 0)
                
                // self.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
                // self.layer.frame = self.layer.frame.offsetBy(dx: -(self.frame.width / 2), dy: 0)
                // self.layer.transform = transform3D
                
                self.transform = CGAffineTransform(scaleX: 1.10, y: 1.10)
                
                hapticButton(.selection)
            })
        }
        else {
            // var rollBack3D = CATransform3DIdentity
            
            UIView.animate(withDuration: 0.20, delay: 0.05, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.95, options: .curveEaseIn, animations: { () in
                
                // rollBack3D.m34 = -1.0 / 500.0
                // rollBack3D = CATransform3DRotate(rollBack3D, 0, 1, 0, 0)
                
                // self.layer.transform = rollBack3D
                
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
            self.setNeedsDisplay(imageName.frame)
            self.contentView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            // self.layer.transform = CATransform3DMakeRotation(CGFloat.pi / 16, 0, 1, 0)
        } else {
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
            // self.layer.transform = CATransform3DMakeRotation(0, 0, 1, 0)
        }
    }
    
    func updateView(request: Request, animated: Bool = true) {
        animateView(direction: .enter)
        
        self.imageName.loadImageUsingCacheWith(urlString: request.imageName, completion: {
            if animated {
                
                let random = Double(arc4random_uniform(UInt32(1000))) / 3000
                UIView.animate(withDuration: 0.6, delay: random, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    
                    self.animateView(direction: .exit)
                    
                    self.nameLabel.text = request.firstName
                    self.messageLabel.text = request.message
                    self.timeFromLabel.text = request.timeFrom.description
                    self.timeToLabel.text = request.timeTo.description
                    self.amount.text = "\(request.amount.description) kr / time"
                    
                    // self.setNeedsDisplay()
                    // self.layoutIfNeeded()
                })
            } else {
                self.animateView(direction: .exit)
                
                self.nameLabel.text = request.firstName
                self.messageLabel.text = request.message
                self.timeFromLabel.text = request.timeRequested.description
                self.timeToLabel.text = request.timeTo.description
                self.amount.text = "\(request.amount.description) kr / time"
            }
            self.cellImageLoaded = true
        })
    }

    // MARK: - Update View
    func updateView(request: Request) {
        self.setNeedsLayout()
        self.imageName.loadImageUsingCacheWith(urlString: request.imageName)
        self.nameLabel.text = request.firstName
        self.messageLabel.text = request.message
        self.timeFromLabel.text = request.timeFrom.description
        self.timeToLabel.text = request.timeTo.description
        self.amount.text = "\(request.amount.description) kr / time"
        // self.setHighlighted(request.highlighted, animated: true)
    }
}
