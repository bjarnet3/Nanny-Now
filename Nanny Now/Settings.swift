//
//  Settings.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 25.11.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit

// Struct is 900 times faster then Class
// https://stackoverflow.com/questions/24232799/why-choose-struct-over-class/24232845#24232845
struct Settings {
    private(set) public var imageName: String
    private(set) public var title: String
    private(set) public var info: String
    
    init(imageName: String, title: String, info: String) {
        self.imageName = imageName
        self.title = title
        self.info = info
    }
}

struct SubSettings {
    
    private(set) public var imageName: String
    private(set) public var title: String
    private(set) public var info: String
    
    init(imageName: String, title: String, info: String) {
        self.imageName = imageName
        self.title = title
        self.info = info
    }
    
}
