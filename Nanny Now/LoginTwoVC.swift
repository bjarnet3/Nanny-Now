//
//  LoginTwoViewController.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 30.10.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import UIKit
// MapKit
import MapKit
// Firebase Part 3
import Firebase
// Facebook Part 4
import FBSDKCoreKit
import FBSDKLoginKit
// KeychainWrapper
import SwiftKeychainWrapper

class LoginTwoVC: UIViewController {
    
    @IBOutlet weak var overlayView: UIImageView!
    
    @IBAction func signInUser(_ sender: Any) {
        // goToLogin()
    }
    
    func goToLogin() {
        
        guard let startVC = storyboard?.instantiateViewController(withIdentifier: "StartVC") as? StartViewController else {
            return
        }
        // loginPageVC.userInfo = userInfo
        present(startVC, animated: false)
    }
}

extension LoginTwoVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
    }
}
