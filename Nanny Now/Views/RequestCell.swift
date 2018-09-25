//
//  RequestCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 09.09.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//
import UIKit

class RequestCell: UITableViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var requestStatusLbl: UILabel!
    @IBOutlet weak var requestIndicatorLbl: UILabel!
    
    @IBOutlet weak var userStatusLbl: UILabel!
    @IBOutlet weak var userIndicatorLbl: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeFromLabel: UILabel!
    @IBOutlet weak var timeToLabel: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    var cellImageLoaded = false
    var hasSelected = false
    
    func returnRequestIndicator(status: RequestStatus = .pending) {
        switch status {
        case .accepted:
            self.requestIndicatorLbl.textColor = UIColor.green
            self.requestIndicatorLbl.text = "•"
        case .complete:
            self.requestIndicatorLbl.textColor = PINK_TABBAR_UNSELECTED
            self.requestIndicatorLbl.text = "•"
        case .pending:
            self.requestIndicatorLbl.textColor = UIColor.orange
            self.requestIndicatorLbl.text = "•"
        case .rejected:
            self.requestIndicatorLbl.textColor = UIColor.red
            self.requestIndicatorLbl.text = "•"
        default:
            self.requestIndicatorLbl.textColor = ORANGE_NANNY_LOGO
            self.requestIndicatorLbl.text = "•"
        }
    }
    
    func returnUserIndicator(from date: Date) {
        let now = Date()
        let timeSince = now.timeIntervalSince(date)
        
        let minutes = Int(timeSince) / 60
        let hours = minutes / 60
        let days = hours / 24
        
        switch minutes {
        case 0 ..< 30:
            self.userStatusLbl.text = "\(minutes) min"
            self.userIndicatorLbl.textColor = UIColor.green
        case 30 ..< 90:
            self.userStatusLbl.text = "\(minutes) min"
            self.userIndicatorLbl.textColor = UIColor.yellow
        case 90 ..< 120:
            self.userStatusLbl.text = "1,5 time"
            self.userIndicatorLbl.textColor = UIColor.orange
        case 120 ..< 1440:
            self.userStatusLbl.text = "\(hours) timer"
            self.userIndicatorLbl.textColor = UIColor.orange
        case 1440 ..< 2880:
            self.userStatusLbl.text = " 1 døgn siden"
            self.userIndicatorLbl.textColor = UIColor.red
        default:
            self.userStatusLbl.text = "\(days) dager"
            self.userIndicatorLbl.textColor = UIColor.gray
        }
        print(minutes)
    }
    
    var requestStatus: RequestStatus? {
        didSet {
            if let requestStatus = self.requestStatus {
                self.requestStatusLbl.text = requestStatus.rawValue
                returnRequestIndicator(status: requestStatus)
            }
        }
    }
    
    var userStatus: Date? {
        didSet {
            if let userStatus = self.userStatus {
                self.userStatusLbl.text = userStatus.description
                self.returnUserIndicator(from: userStatus)
            }
        }
    }
    
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
    
    func setProfileImage() {
        self.cellImageView.clipsToBounds = true
        self.cellImageView.layer.cornerRadius = self.cellImageView.layer.bounds.height / 2
        self.cellImageView.layer.borderColor = UIColor.white.cgColor
        self.cellImageView.layer.borderWidth = 0.85
        
        self.cellImageView.layer.addShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setProfileImage()
        self.amount.layer.cornerRadius = self.amount.frame.height / 2
    }
    
    public enum Direction {
        case enter
        case exit
    }
    
    func animateView( direction: Direction) {
        if direction == .enter {
            self.contentView.alpha = 0
            self.contentView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        } else {
            setProfileImage()
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
        }
    }
    
    func setupView(request: Request, animated: Bool = true) {
        self.cellImageLoaded = false
        self.cellImageView.loadImageUsingCacheWith(urlString: request.imageName, completion: {
            if animated {
                self.animateView(direction: .enter)
                let random = Double(arc4random_uniform(UInt32(1000))) / 3000
                UIView.animate(withDuration: 0.6, delay: random, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    self.nameLabel.text = request.firstName
                    self.messageLabel.text = request.message
                    
                    self.requestStatus = request._requestStatus
                    self.userStatus = request.userStatus
                    
                    self.timeFrom = stringToDateTime(request.timeFrom)
                    self.timeTo = stringToDateTime(request.timeTo)
                    self.amount.text = " \(request.amount) kr   "
                    
                    self.animateView(direction: .exit)
                })
            } else {
                self.nameLabel.text = request.firstName
                self.messageLabel.text = request.message
                
                // self.requestStatus = requestStatusString(request: request.requestStatus)
                self.requestStatus = request._requestStatus
                self.userStatus = request.userStatus
                
                self.timeFrom = stringToDateTime(request.timeFrom)
                self.timeTo = stringToDateTime(request.timeTo)
                self.amount.text = " \(request.amount) kr   "
                self.animateView(direction: .exit)
            }
            self.cellImageLoaded = true
        })
    }
}

