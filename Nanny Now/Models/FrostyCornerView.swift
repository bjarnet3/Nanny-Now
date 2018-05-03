//
//  FrostyCornerView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 15.12.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit

class FrostyCornerView: FrostyView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 19.5
        self.layer.borderWidth = 0.2
        self.layer.borderColor = WHITE_ALPHA.cgColor
        setEffect(blurEffect: .light)
    }
}
