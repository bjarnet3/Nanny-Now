//
//  CustomTextField.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 05.06.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    let textPadding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    let placePadding = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
    let editPadding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
    
    let clearOffset: CGFloat = 30

    // Paddging for place holder
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: placePadding)
    }
    
    // Padding for text
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    // Padding for text in editting mode
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: editPadding)
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let origin = CGPoint(x: -(self.bounds.width - clearOffset), y: bounds.origin.y)
        let superRect = super.clearButtonRect(forBounds: CGRect(origin: origin, size: bounds.size))
        return superRect
    }
    
}
