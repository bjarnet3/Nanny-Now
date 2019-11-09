//
//  LoginZeroViewController.swift
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
// SplashView
import RevealingSplashView
// KeychainWrapper
import SwiftKeychainWrapper

class LoginZeroVC: UIViewController {

    @IBOutlet weak var mainLbl: UILabel!
    @IBOutlet weak var middelLbl: UILabel!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var professionLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayView: UIImageView!
    @IBOutlet weak var profileImageView: CustomImageView!
    
    @IBOutlet weak var loginBtn: CustomButton!
    @IBOutlet weak var loginBtnImage: CustomImageView!
    
    // MARK: - Properties & Variables
    // -------------------------------
    var imagePicker: UIImagePickerController!
    var viewHasDisappeard: Bool = false

    // MARK: - Facebook Authentication
    // -------------------------------
    @IBAction func loginAction(_ sender: AnyObject) {
        if !signedIn {
            facebookAuth()
        } else {
            animateLabel(delay: 0, enter: false, mainLabel: "Takk for besøket", middleLabel: "Du er ut logget av Nanny Now")
            animateLabel(delay: 0.1, enter: true)
            
            logout()
            
            animateView(delay: 0.1, enter: true)
            animateLabel(delay: 2, enter: false)
            
            animateButton(isSignedIn: false)
            animateProfileInfo(delay: 0.1, enter: false)
            
            animateLabel(delay: 4, enter: true, mainLabel: "Hei", middleLabel: "Logg in på Nanny Now")
            self.profileImageView.image = UIImage(named: "")
        }
    }
    
    func facebookAuth() {
        hapticButton(.light)
        // self.activityIndicator.startAnimating()
        self.animateLabel(delay: 0, enter: false)
        self.animateProfileInfo(delay: 0, enter: false)
        let facebookLogin = LoginManager()
        facebookLogin.logOut()
        // Facebook Part 6
        facebookLogin.logIn(permissions: ["public_profile", "user_birthday", "email", "user_friends"], from: self) { (result, error) in
            self.animateLabel(delay: 0.1, enter: true, mainLabel:" Vent litt", middleLabel: "     henter facebook data . . .")
            if error != nil {
                self.animateLabel(delay: 0, enter: false)
                hapticButton(.error)
                print("PRINT: Unable to authenticate with Facebook - \(String(describing: error))")
                self.animateLabel(delay: 0, enter: true, mainLabel: " Error", middleLabel: "  Unable to authenticate with Facebook")
            } else if result?.isCancelled == true {
                self.animateLabel(delay: 0, enter: false)
                self.animateLabel(delay: 0, enter: true, mainLabel: "Avbrutt . . .", middleLabel: "Prøv å logg på igjen")
                hapticButton(.warning)
                print("PRINT: User cancelled Facebook Auth")
            } else {
                self.animateLabel(delay: 0, enter: false)
                hapticButton(.success)
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                // print("PRINT: Facebook Authentication Successfull")
                // Facebook Login Info
                if((AccessToken.current) != nil){
                    GraphRequest(graphPath: "me", parameters: ["fields": "gender, id, last_name, birthday, email, first_name"]).start(completionHandler: { (connection, result, error) -> Void in
                        if (error == nil) {
                            userInfo.removeAll()
                            publicInfo.removeAll()
                            for (key, val) in result as! Dictionary<String,Any> {
                                if key == "id" {
                                    let fid = "fid"
                                    userInfo.updateValue(val, forKey: fid)
                                    publicInfo.updateValue(val, forKey: fid)
                                } else if key == "first_name" {
                                    let fname = "name"
                                    publicInfo.updateValue(val, forKey: fname)
                                    userInfo.updateValue(val, forKey: key)
                                } else if key == "birthday" {
                                    if let ageString = val as? String {
                                        let age = calcAge(birthday: ageString)
                                        publicInfo.updateValue(age, forKey: "age")
                                    }
                                    if key == "gender" {
                                        publicInfo.updateValue(val, forKey: key)
                                        userInfo.updateValue(val, forKey: key)
                                    } else {
                                        publicInfo.updateValue("other", forKey: key)
                                        userInfo.updateValue("other", forKey: key)
                                    }
                                    userInfo.updateValue(val, forKey: key)
                                }
                                userInfo.updateValue(val, forKey: key)
                            }
                            let name = userInfo["first_name"] as? String ?? "Unknown Name"
                            self.descriptionLbl.text = userInfo["email"] as? String ?? "Unknown Email"
                            if let ageString = userInfo["birthday"] as? String {
                                let age = calcAge(birthday: ageString)
                                self.nameLbl.text = "\(name)"
                                publicInfo.updateValue(age, forKey: "age")
                            } else {
                                self.nameLbl.text = "\(name)"
                            }
                            if let education = userInfo["education"] as? String {
                                self.professionLbl.text = education
                                publicInfo.updateValue(education, forKey: "title")
                            }
                            
                            signedIn = true
                            self.animateLabel(delay: 0.1, enter: true, mainLabel: "Gratulerer", middleLabel: "  Logget inn som  \(name)")
                            self.animateProfileInfo(delay: 0, enter: true)
                        }
                    })
                    // MARK: This is much better :-D -- Getting User Facebook friends
                    GraphRequest(graphPath: "/me/friends/", parameters: ["fields": "id, first_name"]).start(completionHandler: { (connection, result, error) -> Void in
                        if (error == nil) {
                            for (key, val) in result as! Dictionary<String,Any> {
                                if key == "data" {
                                    for array in (val as? [AnyHashable])! {
                                        var id: String = "Unknown ID"
                                        var name: String = "Unknown Name"
                                        for (key, val) in (array as? [String:String])! {
                                            if key == "id" {
                                                id = val
                                            }
                                            if key == "first_name" {
                                                name = val
                                            }
                                        }
                                        userFriends.updateValue(name, forKey: id)
                                    }
                                }
                            }
                        }
                        self.firebaseAuth(credential)
                    })
                }
            }
        }
    }
    
    // MARK: Facebook Logout
    // ---------------------
    func facebookLogout() {
        let loginView : LoginManager = LoginManager()
        loginView.loginBehavior = .browser
        
        let manager = LoginManager()
        manager.logOut()
    }
    
    // MARK: - Firebase Authentication
    // -------------------------------
    func firebaseAuth(_ credential: AuthCredential) {
        // This line is Auth for Firebase,, the rest is just Error handling :-)
        Auth.auth().signInAndRetrieveData(with: credential, completion: { (data, error) in
            if error != nil {
                /// This didn't work
                print("PRINT: Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                // print("PRINT: Firebase Authentication Successfull")
                if let user = data?.user {
                    // SET: userData to DB
                    if let publicFID = publicInfo["fid"] as? String {
                        printFunc(publicFID)
                        let gender = userInfo["gender"] as? String ?? "other"
                        let userData = [
                            "provider": credential.provider,
                            "name": self.nameLbl.text!,
                            "gender": gender,
                            "email": self.descriptionLbl.text!
                        ]
                        KeychainWrapper.standard.set(user.uid, forKey: KEY_UID)
                        if let fid = userInfo["id"] as? String {
                            printFunc(fid)
                            userInfo.removeValue(forKey: "id")
                            userInfo["fid"] = fid
                            KeychainWrapper.standard.set(fid, forKey: KEY_FID)
                                let image = DataService.instance.getFacebookProfilePicture(fid, .large)
                                // self.profileImageView.loadFacebookImageUsingCache(with: fid, size: .large)
                                self.profileImageView.image = image
                                UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                                    self.profileImageView.alpha = 1.0
                                })
                            self.postImageToFirebase(image: image)
                        } else {
                            print("unable to download image")
                        }
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                }
            }
        })
    }
    
    func completeSignIn(id: String, userData: [String : String]) {
        DataService.instance.createFirbaseDBUser(uid: id, userData: userData)
        _ = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        animateButton(isSignedIn: true)
    }
    
    // Post Image To Firebase (and update DB)
    func postImageToFirebase(image: UIImage?) {
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            if let img = image {
                // Generic Function
                if let imgData = img.jpegData(compressionQuality: 0.4) {
                    // Unique image identifier
                    let imageUID = NSUUID().uuidString
                    // Set metaData for the image
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    // Upload image - STORAGE_BASE.child("post-pics").child(uniqueID).put(image, meta)
                    let storageREF = DataService.instance.REF_PROFILE_IMAGES.child(userID).child("\(imageUID).jpg")
                    storageREF.putData(imgData, metadata: metadata) { (metadata, error) in
                        if error != nil {
                            print("postImageToFirebase: Unable to upload image to Firebase storage")
                            print(error!)
                        } else {
                            print("postImageToFirebase: Successfully uploaded image to Firebase storage")
                            storageREF.downloadURL { (url, err) in
                                if let absoluteUrlString = url?.absoluteString {
                                    userInfo.updateValue(absoluteUrlString, forKey: "imageUrl")
                                    self.postUserInfoToFirebase(imgUrl: absoluteUrlString, userFirebaseInfo: userInfo)
                                } else {
                                    print("unable to get imageLocation")
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    // Post Image To Firebase (and update DB)
    func oldPostImageToFirebase(image: UIImage?) {
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            if let img = image {
                // Generic Function
                if let imgData = img.jpegData(compressionQuality: 0.4) {
                    // Unique image identifier
                    let imageUid = NSUUID().uuidString
                    // Set metaData for the image
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    // Upload image - STORAGE_BASE.child("post-pics").child(uniqueID).put(image, meta)
                    DataService.instance.REF_PROFILE_IMAGES.child(userID).child(imageUid).putData(imgData, metadata: metadata) { (metadata, error) in
                        if error != nil {
                            print("postImageToFirebase: Unable to upload image to Firebase storage")
                            print(error!)
                        } else {
                            // print("postImageToFirebase: Successfully uploaded image to Firebase storage")
                            metadata?.storageReference?.downloadURL(completion: {
                                (url, error) in
                                if (error == nil) {
                                    if let downloadUrl = url {
                                        let downloadString = downloadUrl.absoluteString
                                        userInfo.updateValue(downloadString, forKey: "imageUrl")
                                    }
                                } else {
                                    print("Unable to extract downloadString from metadata")
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    // Post userInfo to Firebase
    func postUserInfoToFirebase(imgUrl: String, userFirebaseInfo: [String:Any]) {
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            // Database - REF_POSTS = .child("posts") - .childByAutoId()
            userInfo.updateValue(userID, forKey: "userID")
            
            guard let firstName = userFirebaseInfo["first_name"] as? String else {
                print("- firstName unavaliable")
                return
            }
            /*
            guard let lengdeGrad = userFirebaseInfo["lengdeGrad"] as? Double else {
                print("- lengdeGrad unavailable")
                return
            }
            
            guard let breddeGrad = userFirebaseInfo["breddeGrad"] as? Double else {
                print("- breddeGrad unavailable")
                return
            }

            
            guard let yrke = userFirebaseInfo["yrke"] as? String else {
                print("- yrke unavailable")
                return
            }
            */
            /*
            guard let birthDay = userFirebaseInfo["birthday"] as? String else {
                print("- birthDay unavailable")
                return
            }
            */
            /*
            guard let age = Int(calcAge(birthday: birthDay)) else {
                print("- age unavailable")
                return
            }
            */
            
            userInfo.updateValue(firstName, forKey: "first_name")
            userInfo.updateValue(firstName, forKey: "userName")
            
            // userInfo.updateValue(lengdeGrad, forKey: "lengdeGrad")
            // userInfo.updateValue(breddeGrad, forKey: "breddeGrad")
            
            // userInfo.updateValue(yrke, forKey: "yrke")
            
            userInfo.updateValue(false, forKey: "vistPolitiatest")
            // userInfo.updateValue(0, forKey: "ratings")
            
            userInfo.updateValue(userFriends, forKey: "friends")
            
            // FIXME: - This needs to be better (userInfo.updateValue)
            // userInfo.updateValue(self.userFriends, forKey: "friends")
            
            DataService.instance.addFriendsToDatabase(friends: userFriends)
            DataService.instance.updateUserChildValues(uid: userID, userData: userInfo)
            
            let publicUser = DataService.instance.REF_USERS_PUBLIC
            publicUser.child(userID).updateChildValues(publicInfo)
        }
    }
    
    // MARK: - GET from Firebase
    // -------------------------
    func getInfoFromFirebase() {
        // activityIndicator.startAnimating()
        if let userID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            signedIn = true
            let firebasePost = DataService.instance.REF_USERS_PRIVATE.child(userID)
            firebasePost.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    // self.userInfo = snapshot as! Dictionary<String, AnyObject>
                    for snap in snapshot {
                        if snap.key == "id" {
                            let fid = "fid"
                            if let fidValue = snap.value as? String {
                                userInfo.updateValue(fidValue, forKey: fid)
                            }
                            // Jump over communication and facebook friends
                            if snap.key != "communication" {
                                if snap.key != "friends" {
                                    if snap.key != "tokens" {
                                        
                                        // FIXME: Get info from userInfo Dictionary (getInfoFromFirebase)
                                        // userInfo updated with database values from userID
                                        userInfo.updateValue(snap.value as AnyObject, forKey: snap.key)
                                        // This is where userinfo is got from Firebase Nannies
                                        
                                        let first_name = userInfo["first_name"] as! String
                                        let title = userInfo["yrke"] as! String
                                        printDebug(object: first_name)
                                        printDebug(object: title)
                                        
                                        if let name = snap.value, snap.key == "name" { self.nameLbl.text = name as? String }
                                        if let yrke = snap.value, snap.key == "yrke" { self.professionLbl.text = yrke as? String }
                                        if let alder = snap.value, snap.key == "birthday" { self.descriptionLbl.text = "\(alder)" }
                                        if let image = snap.value, snap.key == "imageUrl" {
                                            let imageName = image as! String
                                            let ref = Storage.storage().reference(forURL: (imageName as NSString) as String)
                                            // print("ref annotation \(ref)")
                                            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                                                if error != nil {
                                                    print("PRINT: Unable to download image from Firebase storage (getImageFromFirebase)")
                                                } else {
                                                    // print("PRINT: Image downloaded from Firebase storage (getImageFromFirebase)")
                                                    if let imgData = data {
                                                        if let img = UIImage(data: imgData) {
                                                            // Here we have the image (img)
                                                            self.profileImageView.image = img
                                                            UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                                                                self.profileImageView.alpha = 1.0
                                                            })
                                                        }
                                                    }
                                                }
                                            })
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    // MARK: - Logout, Sign Out and Exit (functions)
    // ---------------------------------------------
    func logout(service: Service = .All) {
        switch service {
        case .Facebook:
            self.facebookLogout()
        case .Firebase:
            try! Auth.auth().signOut()
        default:
            _ = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            try! Auth.auth().signOut()
            self.facebookLogout()
            signedIn = false
            userInfo.removeAll()
            userFriends.removeAll()
            publicInfo.removeAll()
        }
    }
    
    // This is just a test "different message labels"
    func messageLabel() {
        /*
         let name = self.userInfo["first_name"] as? String ?? "Unknown Name"
         let mainSmallArray = ["Hei \(name)", "Hallo \(name)", "\(name) . . ."]
         let mainMediumArray = ["Heisann", "Halloen"]
         let mainLongArray = ["Velkommen", "Heisann . .", "Hei igjen .", "Hei . . .", "Halloen . . ."]
         
         let midSmallArray = ["Pålogget", "Innlogget"]
         let midMediumArray = ["Pålogget som","Innlogget som"]
         let midLongArray = ["Du er nå pålogget", "Kjekt å se deg"]
         */
    }
    
    func getInfoFromUserInfo() {
        if !userInfo.isEmpty || signedIn {
            // MARK: - This is working pretty good
            for (key, value) in userInfo {
                switch key {
                case "first_name":
                    self.nameLbl.text = value as? String
                    // txtFirstName.text = value as? String
                case "last_name":
                    print("lastName")
                    // txtLastName.text = value as? String
                case "email":
                    self.descriptionLbl.text = value as? String
                    // txtEmail.text = value as? String
                case "yrke":
                    self.professionLbl.text = value as? String
                    // txtJob.text = value as? String
                case "birthday":
                    print("birthDay")
                    /*
                    if let birthday = value as? String {
                        let birthDate = stringToDate(birthday)
                        birthDay.setDate(birthDate, animated: true)
                    }
                    */
                default:
                    print("Unable to add Text to Textfields from userInfo")
                }
            }
        }
    }
    
}



// MARK: - ViewDidLoad, Disappear, LayoutSubviews
// ---------------------------------------------
extension LoginZeroVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainLbl.alpha = 0
        middelLbl.alpha = 0
        nameLbl.alpha = 0
        professionLbl.alpha = 0
        descriptionLbl.alpha = 0
        
        profileImageView.alpha = 0
        
        loginBtn.alpha = 0
        loginBtnImage.alpha = 0
        
        self.getInfoFromFirebase()
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
        
        // Old token
        /*
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(String(describing: refreshedToken))")
        }
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        
        animateButton(isSignedIn: signedIn)
        getInfoFromUserInfo()
        
        // If view have Disappeard before (comming back)
        if viewHasDisappeard {
            animateView(delay: 0.2, enter: true)
            if signedIn {
                let firstName = userInfo["first_name"] as? String ?? "Unknown Name"
                self.animateLabel(delay: 0.3, enter: true, mainLabel: "Velkommen", middleLabel: "  tilbake \(firstName)")
                self.animateProfileInfo(delay: 0.4, enter: true)
            } else {
                animateLabel(delay: 0.3, enter: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        // animateLabel(delay: 2.0, enter: true)
        
        if let imageURL = userInfo["imageUrl"] as? String {
            printFunc(imageURL)
            self.profileImageView.loadImageUsingCacheWith(urlString: imageURL, completion: {
                self.profileImageView.alpha = 1.0
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        viewHasDisappeard = true
        
        animateLabel(delay: 0.1, enter: false)
        animateView(delay: 0.0, enter: false)
        animateProfileInfo(delay: 0.1, enter: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
    }
    
    override func viewWillLayoutSubviews() {
        print("viewWillLayoutSubviews")
    }
    
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews")
        if !viewHasDisappeard {
            animateView(delay: 0.2, enter: true)
            if signedIn {
                print(userInfo)
                let name = userInfo["first_name"] as? String ?? "Unknown Name"
                self.animateLabel(delay: 0.3, enter: true, mainLabel: "Heisann...", middleLabel: "  Innlogget som \(name)")
                animateProfileInfo(delay: 0.4, enter: true)
            } else {
                animateLabel(delay: 0.3, enter: true)
            }
        }
    }
}

// MARK: - Animations - Labels and Views
// ---------------------------------------------
extension LoginZeroVC {
    
    func animateView(delay: Double, enter: Bool) {
        if enter {
            UIView.animate(withDuration: 0.45, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.imageView.alpha = 0.25
                self.loginBtnImage.alpha = 1.0
                self.loginBtn.alpha = 1.0
                if signedIn && self.profileImageView.image != nil {
                    self.profileImageView.alpha = 1.0
                } else {
                    self.profileImageView.alpha = 0.0
                }
            })
        } else {
            UIView.animate(withDuration: 0.45, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.imageView.alpha = 0.0
                self.loginBtnImage.alpha = 0.0
                self.loginBtn.alpha = 0.0
                self.profileImageView.alpha = 0.0
            })
        }
    }
    
    func animateProfileInfo(duration: TimeInterval = 0.45, delay: Double, enter: Bool) {
        if enter {
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.nameLbl.alpha = 1.0
            })
            UIView.animate(withDuration: duration, delay: delay + 0.1, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.professionLbl.alpha = 1.0
            })
            UIView.animate(withDuration: duration, delay: delay + 0.2, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.descriptionLbl.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.nameLbl.alpha = 0.0
            })
            UIView.animate(withDuration: duration, delay: delay + 0.02, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.professionLbl.alpha = 0.0
            })
            UIView.animate(withDuration: duration, delay: delay + 0.04, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.descriptionLbl.alpha = 0.0
            })
        }
    }
    
    func animateLabel(duration: TimeInterval = 0.45, delay: Double, enter: Bool, mainLabel: String = "Velkommen", middleLabel: String = " til Nanny Now . . .") {
        if enter {
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.mainLbl.alpha = 1
                self.mainLbl.frame = self.mainLbl.frame.offsetBy(dx: 0, dy: 30)
                self.mainLbl.text = mainLabel
            })
            UIView.animate(withDuration: duration, delay: delay + 0.1, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.middelLbl.alpha = 1
                self.middelLbl.frame = self.middelLbl.frame.offsetBy(dx: 0, dy: -30)
                self.middelLbl.text = middleLabel
            })
        } else {
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.mainLbl.alpha = 0.0
                self.mainLbl.frame = self.mainLbl.frame.offsetBy(dx: 0, dy: -30)
            })
            UIView.animate(withDuration: duration, delay: delay + 0.1, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.middelLbl.alpha = 0.0
                self.middelLbl.frame = self.middelLbl.frame.offsetBy(dx: 0, dy: 30)
            })
        }
    }
    
    func animateButton(isSignedIn: Bool) {
        if isSignedIn {
            if let name = userInfo["first_name"] as? String {
                UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                    let buttonTitle = "Logg ut: \(name)"
                    self.loginBtn.setTitle(buttonTitle, for: .normal)
                    self.loginBtn.setTitleColor(UIColor.red, for: .normal)
                    self.loginBtnImage.image = UIImage(named: "off")
                })
            }
        } else {
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.loginBtn.setTitle("Facebook", for: .normal)
                self.loginBtn.setTitleColor(UIColor.darkGray, for: .normal)
                self.loginBtnImage.image = UIImage(named: "Facebook_Home_logo_old.svg")
            })
        }
    }
}
