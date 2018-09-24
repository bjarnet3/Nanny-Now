//
//  RequestCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 09.09.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//
import UIKit

class RequestCategory: UITableViewCell {
    
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var categoryProgress: UIProgressView!
    
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
            self.contentView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        } else {
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
        }
    }
    
    func setupView(request: Request, requests: [Request], animated: Bool = true) {
        if animated {
            self.animateView(direction: .enter)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                self.animateView(direction: .exit)
                
                let categoryAmount = requests.filter{$0.requestStatus == request.requestStatus}.count
                self.categoryTitle.text = "\(request.requestStatus) (\(categoryAmount)"
            })
        } else {
            self.animateView(direction: .exit)

        }
        
    }
}

