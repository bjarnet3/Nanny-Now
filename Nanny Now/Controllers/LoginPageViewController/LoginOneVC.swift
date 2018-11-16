//
//  LoginOneViewController.swift
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

class LoginOneVC: UIViewController {
    
    @IBOutlet weak var mainLbl: UILabel!
    @IBOutlet weak var subLbl: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayView: UIImageView!
    
    // @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtFirstName: DTTextField!
    @IBOutlet weak var txtLastName: DTTextField!
    @IBOutlet weak var txtEmail: DTTextField!
    @IBOutlet weak var txtJob: DTTextField!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    
    @IBOutlet weak var birthDay: UIDatePicker!
    
    // @IBOutlet weak var txtPassword: DTTextField!
    // @IBOutlet weak var txtConfirmPassword: DTTextField!
    
    // https://github.com/iDhaval/DTTextField
    let firstNameMessage        = "Fornavn er obligatorisk."
    let lastNameMessage         = "Etternavn er obligatorisk."
    let emailMessage            = "Epost er obligatorist."
    let jobTitleMessage         = "Yrke / Titel obligatorisk."
    // let passwordMessage         = "Password is required."
    // let confirmPasswordMessage  = "Confirm password is required."
    // let mismatchPasswordMessage = "Password and Confirm password are not matching."
    
    // MARK: - Properties & Variables
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // scrollView.alpha = 0
        
        addTextToRegistration()
        
        genderSegment.layer.cornerRadius = genderSegment.frame.height / 2
        genderSegment.layer.borderColor = UIColor.white.cgColor
        genderSegment.layer.borderWidth = 1.0
        genderSegment.layer.masksToBounds = true
        
        birthDay.layer.cornerRadius = birthDay.frame.height / 2
        birthDay.backgroundColor = WHITE_SOLID
        birthDay.layer.masksToBounds = true
    }
    
    func addTextToRegistration() {
        if !userInfo.isEmpty || signedIn {
            // MARK: - This is working pretty good
            for (key, value) in userInfo {
                switch key {
                case "first_name":
                    txtFirstName.text = value as? String
                case "last_name":
                    txtLastName.text = value as? String
                case "email":
                    txtEmail.text = value as? String
                case "yrke":
                    txtJob.text = value as? String
                case "birthday":
                    if let birthday = value as? String {
                        let birthDate = stringToDate(birthday)
                        birthDay.setDate(birthDate, animated: true)
                    }
                case "gender":
                    if let gender = value as? String {
                        if gender == "female" {
                            genderSegment.selectedSegmentIndex = 0
                        } else if gender == "male" {
                            genderSegment.selectedSegmentIndex = 1
                        } else {
                            genderSegment.selectedSegmentIndex = 2
                        }
                    }
                default:
                    print("Unable to add Text to Textfields from userInfo")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        print(self.isViewLoaded)
        animateLabel(delay: 0.3, enter: true)
        animateView(delay: 0.2, enter: true)
        
        addTextToRegistration()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        print(LocalService.instance.userInfo)
        // animateLabel(delay: 2.0, enter: true)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        animateLabel(delay: 0.1, enter: false)
        animateView(delay: 0.0, enter: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
    }
    
    func getInfo() {
        if !userInfo.isEmpty {
            for (key, value) in userInfo {
                switch key {
                case "first_name":
                    txtFirstName.text = value as? String
                case "last_name":
                    txtLastName.text = value as? String
                case "email":
                    txtEmail.text = value as? String
                case "yrke":
                    txtJob.text = value as? String
                case "birthday":
                    if let birthday = value as? String {
                        let birthDate = stringToDate(birthday)
                        birthDay.setDate(birthDate, animated: true)
                    }
                case "gender":
                    if let gender = value as? String {
                        if gender == "male" {
                            genderSegment.selectedSegmentIndex = 1
                        } else if gender == "female" {
                            genderSegment.selectedSegmentIndex = 0
                        } else {
                            genderSegment.selectedSegmentIndex = 2
                        }
                    }
                default: break
                }
            }
        }
    }
    
    @IBAction func onBtnSubmitClicked(_ sender: Any) {
        
        guard validateData() else { return }
        let alert = UIAlertController(title: "Gratulerer", message: "Din informasjon opplastet.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (cancel) in
            
            DispatchQueue.main.async {
                self.txtFirstName.textColor = UIColor.lightGray
                self.txtLastName.textColor = UIColor.lightGray
                self.txtEmail.textColor = UIColor.lightGray
                self.txtJob.textColor = UIColor.lightGray
                // self.txtConfirmPassword.text = ""
                // self.txtPassword.text        = ""
                // self.txtFirstName.textColor = ""
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func resignKeyboard(_ sender: Any) {
        dismissKeyboard()
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func animateView(delay: Double, enter: Bool) {
        if enter {
            UIView.animate(withDuration: 0.45, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.imageView.alpha = 0.25
                // self.scrollView.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.35, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.imageView.alpha = 0.0
                // self.scrollView.alpha = 0.0
            })
        }
    }
    
    func animateLabel(delay: Double, enter: Bool) {
        if enter {
            UIView.animate(withDuration: 0.45, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.mainLbl.alpha = 1
                self.mainLbl.frame = self.mainLbl.frame.offsetBy(dx: 0, dy: -30)
            })
            UIView.animate(withDuration: 0.45, delay: delay * 1.2, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.subLbl.alpha = 1
                self.subLbl.frame = self.subLbl.frame.offsetBy(dx: 0, dy: -30)
                
                // self.scrollView.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.subLbl.alpha = 0.0
                self.subLbl.frame = self.subLbl.frame.offsetBy(dx: 0, dy: 30)
            })
            UIView.animate(withDuration: 0.35, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.85, options: .curveEaseIn, animations: {
                self.mainLbl.alpha = 0.0
                self.mainLbl.frame = self.mainLbl.frame.offsetBy(dx: 0, dy: 30)
                
                // self.scrollView.alpha = 0.0
            })
        }
    }
    
}

// MARK: User Define Methods
extension LoginOneVC {
    
    @objc func keyboardWillShow(notification:Notification) {
        guard let keyboardHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        // scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight.height, 0)
        print(keyboardHeight)
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        // scrollView.contentInset = .zero
    }
    
    func uploadUserData() -> Bool {
        
        guard let firstName = self.txtFirstName.text else { return false }
        guard let lastName = self.txtLastName.text else { return false }
        guard let email = self.txtEmail.text else { return false }
        guard let jobTitle = self.txtJob.text else { return false }
        
        let genderIndex = self.genderSegment.selectedSegmentIndex
        var gender = "unknown"
        
        switch genderIndex {
        case 0:
            gender = "female"
        case 1:
            gender = "male"
        default:
            gender = "other"
        }
        
        let dateString = self.birthDay.date
        let birthday = dateToString(dateString)
        
        /*
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let stringFromDate = dateFormater.string(from: dateString)
        */
        
        let privateData: [String:Any] = [
            "userName": firstName,
            "first_name": firstName,
            "last_name": lastName,
            "yrke": jobTitle,
            "email": email,
            "gender": gender,
            "birthday" : birthday
        ]
        
        let publicData: [String:Any] = [
            "age": calcAge(birthday: birthday),
            "name": firstName,
            "gender": gender,
            "title": jobTitle
        ]
        
        guard let userID = KeychainWrapper.standard.string(forKey: KEY_UID) else {
            return false
        }
        
        DataService.instance.updateUserChildValues(uid: userID, userData: privateData)
        DataService.instance.updatePublicUserChildValues(uid: userID, userData: publicData)
        
        // Experimental - testing
        userInfo["first_name"] = firstName
        userInfo["last_name"] = lastName
        userInfo["email"] = email
        userInfo["yrke"] = jobTitle
        userInfo["gender"] = gender
        userInfo["birthday"] = birthday
        
        return true
    }
    
    func validateData() -> Bool {
        
        guard !txtFirstName.text!.isEmptyStr else {
            txtFirstName.showError(message: firstNameMessage)
            return false
        }
        
        guard !txtLastName.text!.isEmptyStr else {
            txtLastName.showError(message: lastNameMessage)
            return false
        }
        
        guard !txtEmail.text!.isEmptyStr else {
            txtEmail.showError(message: emailMessage)
            return false
        }
        
        guard !txtJob.text!.isEmptyStr else {
            txtJob.showError(message: jobTitleMessage)
            return false
        }
        
        /*
         guard !txtPassword.text!.isEmptyStr else {
         txtPassword.showError(message: passwordMessage)
         return false
         }
         
         guard !txtConfirmPassword.text!.isEmptyStr else {
         txtConfirmPassword.showError(message: confirmPasswordMessage)
         return false
         }
         
         guard txtPassword.text == txtConfirmPassword.text else {
         txtConfirmPassword.showError(message: mismatchPasswordMessage)
         return false
         }
         */
        
        return uploadUserData()
    }
}
