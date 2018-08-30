//
//  CustomImageView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 12.10.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {
    
    func setupView() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = WHITE_SOLID.cgColor
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.height / 2
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()


    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.autoresizesSubviews = true

        self.setupView()
    }
    
}
