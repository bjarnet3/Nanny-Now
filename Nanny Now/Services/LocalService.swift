//
//  LocalService.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 08.11.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import Foundation

/// Sign In Status in (LocalService Singleton)
var signedIn = LocalService.instance.signedIn
/// Public Info Stored in (LocalService Singleton)
var publicInfo = LocalService.instance.publicInfo
/// User Info Stored in (LocalService Singleton)
var userInfo = LocalService.instance.userInfo
/// User Friends Stored in (LocalService Singleton)
var userFriends = LocalService.instance.userFriends

/// if **Low Power Mode Enabled** return **false**
var lowPowerModeDisabled: Bool {
    return !ProcessInfo.processInfo.isLowPowerModeEnabled
}

class LocalService {
    // LocalService Singleton
    static let instance = LocalService()
    
    // Stored Public Properties in LocalService
    var signedIn: Bool = false
    var publicInfo: Dictionary<String, Any> = [:]
    
    var userInfo: Dictionary<String, Any> = [:]
    var userFriends: Dictionary<String, String> = [:]
    var user: User?
    
    private let settings = [
        Settings(imageName: "noun_1052547_cc", title: "Bruker Profil", info: "Set dine personlige instillinger her"),
        Settings(imageName: "noun_1402133_cc", title: "Inviter Venner", info: "Inviter venner og familie"),
        Settings(imageName: "noun_1177170_cc", title: "Innstillinger", info: "Applikasjons Instillinger"),
        Settings(imageName: "noun_974817_cc", title: "Trenger du Hjelp?", info: "FAQ, veiledning og kontakt info"),
        Settings(imageName: "noun_1323364_cc", title: "Logg ut", info: "Her kan du logge ut din bruker")
    ]
    
    private let subSettings = [
        Settings(imageName: "noun_1086663_cc", title: "Notifikasjoner / Varslinger", info: "For å forandre på melding, og notificasjoner."),
        Settings(imageName: "noun_182952_cc", title: "Lokasjon / Posisjonering", info: "Set ønsket instillinger for lokasjonstjenestene."),
        Settings(imageName: "noun_590438_cc_Modified2", title: "Brukere / Blokkering / Tillgang", info: "Set dine innstillinger for hvordan andre kan nå deg."),
    ]
    
    func setUser(user: User?) {
        if let user = user {
            self.user = user
        }
    }
    
    func getUser() -> User? {
        return user
    }
    
    func getSettings() -> [Settings] {
        return settings
    }
    
    func getSubSettings() -> [Settings] {
        return subSettings
    }
}
