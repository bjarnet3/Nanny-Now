//
//  Constants.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 10.10.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit

// Static User ID, Facebook ID, Post ID og Request ID
let KEY_UID = "uid"
let KEY_FID = "fid"
let KEY_PID = "pid"
let KEY_RID = "rid"

// Color Constants
let SHADOW_GRAY: CGFloat = 120.0 / 255.0
let BLACK_SOLID = UIColor.black
let GRAY_SOLID = UIColor.gray

let WHITE_SOLID = hexStringToUIColor("#FFFFFF")
let WHITE_ALPHA = hexStringToUIColor("#FFFFFF", 0.3)

// Nanny Colors
let PINK_SOLID = hexStringToUIColor("#cc00cc")
let PINK_DARK_SOLID = hexStringToUIColor("#660033")
let PINK_DARK_SHARP = hexStringToUIColor("#FF3191") // FF3191

let ORANGE_SOLID = hexStringToUIColor("#cc3300")
let RED_SOLID = hexStringToUIColor("#cc0000")

let PINK_NANNY_LOGO = hexStringToUIColor("#ff3366")
let ORANGE_NANNY_LOGO = hexStringToUIColor("#ff6633")

let PINK_TABBAR_SELECTED = hexStringToUIColor("#FC2F92")
let PINK_TABBAR_UNSELECTED = hexStringToUIColor("#FF85FF")

let LIGHT_GREY = hexStringToUIColor("#EBEBEB")
let LIGHT_PINK = hexStringToUIColor("#FF72C8")
let LIGHT_BLUE = hexStringToUIColor("#0096FF")

let AQUA_BLUE = hexStringToUIColor("#0096FF")

let STRAWBERRY = hexStringToUIColor("#FF2F92")
let SILVER     = hexStringToUIColor("#D6D6D6")


// Struct Altitude Constants
struct AltitudeDistance {
    static let tiny: Double = 600
    static let XSmall: Double = 900
    static let small: Double = 2500
    static let normal: Double = 4000
    static let medium: Double = 6500
    static let xMedium: Double = 8000
    static let large: Double = 11200
    static let XLarge: Double = 25000
    static let XXLarge: Double = 40000
}
