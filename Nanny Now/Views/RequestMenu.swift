//
//  RequestMenu.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 29.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class RequestMenu: UIView {

    @IBOutlet var requestView: FrostyCornerView!
    
    @IBOutlet weak var requestImage: CustomImageView!
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var requestName: UILabel!
    @IBOutlet weak var requestRating: UILabel!
    @IBOutlet weak var requestAge: UILabel!
    @IBOutlet weak var requestGender: UILabel!
    @IBOutlet weak var requestDistance: UILabel!
    
    @IBOutlet weak var requestTextField: UITextField!
    @IBOutlet weak var requestCheck: UILabel!
    
    @IBOutlet weak var requestType: UISegmentedControl!
    
    @IBOutlet weak var fromSwitch: UISwitch!
    @IBOutlet weak var fromDateTime: UIDatePicker!
    @IBOutlet weak var fromCheck: UILabel!
    
    @IBOutlet weak var toSwitch: UISwitch!
    @IBOutlet weak var toDateTime: UIDatePicker!
    @IBOutlet weak var toCheck: UILabel!
    
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    private var user: User?
    private var nanny: Nanny?
    
    private var completion: Completion?
    
    @IBAction func requestTypeAction(_ sender: UISegmentedControl) {
        // Request Mode
        if sender.selectedSegmentIndex == 0 {
            // TextField & CheckLabel
            requestTextField.alpha = 0.2
            requestTextField.isUserInteractionEnabled = false
            
            requestCheck.text = "x"
            requestCheck.textColor = UIColor.lightGray
            
            dismissKeyboard()
            
            // From Switch, DatePicker & CheckLabel
            fromSwitch.setOn(true, animated: true)
            fromSwitch.isUserInteractionEnabled = true
            fromSwitch.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            fromDateTime.alpha = 1.0
            fromDateTime.isUserInteractionEnabled = true
            fromDateTime.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            fromCheck.text = "✓"
            fromCheck.textColor = UIColor.darkGray
            
            // To Switch, DatePicker & CheckLabel
            toSwitch.setOn(true, animated: true)
            toSwitch.isUserInteractionEnabled = true
            toSwitch.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            toDateTime.alpha = 1.0
            toDateTime.isUserInteractionEnabled = true
            toDateTime.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            toCheck.text = "✓"
            toCheck.textColor = UIColor.darkGray
        } else {
            // Message Mode
            
            // TextField & CheckLabel
            requestTextField.alpha = 1.0
            requestTextField.isUserInteractionEnabled = true
            
            requestCheck.text = "✓"
            requestCheck.textColor = UIColor.darkGray

            // From Switch, DatePicker & CheckLabel
            fromSwitch.setOn(false, animated: true)
            fromSwitch.isUserInteractionEnabled = false
            fromSwitch.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
            fromDateTime.alpha = 0.2
            fromDateTime.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            fromDateTime.isUserInteractionEnabled = false
            fromCheck.text = "x"
            fromCheck.textColor = UIColor.lightGray
            
            // To Switch, DatePicker & CheckLabel
            toSwitch.setOn(false, animated: true)
            toSwitch.isUserInteractionEnabled = false
            toSwitch.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            toDateTime.alpha = 0.2
            toDateTime.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            toDateTime.isUserInteractionEnabled = false
            toCheck.text = "x"
            toCheck.textColor = UIColor.lightGray
            requestTextField.becomeFirstResponder()
        }
    }
    
    // Send Simple Message
    @IBAction private func sendRequestAction(_ sender: UIButton) {
        self.sendRequest()
    }
    
    @IBAction private func cancelRequestAction(_ sender: Any) {
        self.cancelRequest()
    }
    
    @IBAction private func tapBackground(_ sender: Any) {
        self.dismissKeyboard()
    }
    
    @IBAction private func resignKeyboard(_ sender: Any) {
        self.dismissKeyboard()
    }

    // MARK: - Functions, Database & Animation
    // ---------------------------------------
    func sendRequest() {
        print("sendRequest")
        if let nanny = self.nanny {
            if let user = self.user {
                var requestMessage = "Melding til: \(nanny.firstName)"
                if let text = self.requestTextField.text, text != "" { requestMessage = text }
                if self.requestType.selectedSegmentIndex == 0 {
                    // Send Request
                    var request = Request(nanny: nanny, user: user, timeFrom: self.fromDateTime.date, timeTo: self.toDateTime.date, message: requestMessage)
                    request.requestCategory = NotificationCategory.nannyRequest.rawValue
                    Notifications.instance.sendNotification(with: request)
                } else {
                    // Send Message
                    let message = Message(from: user, to: nanny, message: requestMessage)
                    Notifications.instance.sendNotifications(with: message)
                }
            }
        }
        self.completion?()
    }
    
    func cancelRequest() {
        self.completion?()
    }
    
    func resignSegmentResponder() {
        
    }
    
    //Calls this function when the tap is recognized.
    private func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.endEditing(true)
    }

    // This initializer hides init(frame:) from subclasses
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initNib()
    }

    private func initNib() {
        Bundle.main.loadNibNamed("RequestMenu", owner: self, options: nil)
        addSubview(requestView)
        requestView.frame = self.bounds
        requestView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func initData(user: User?, nanny: Nanny?, completion: Completion? = nil) {
        if let nanny = nanny {
            self.requestImage.loadImageUsingCacheWith(urlString: nanny.imageName)
            self.requestName.text = nanny.firstName
            self.requestAge.text = "\(nanny.age) år"
            self.requestTitle.text = nanny.jobTitle
            self.requestGender.text = nanny.gender
            self.requestRating.text = nanny.ratingStar
            self.requestDistance.text = nanny.returnDistance
            
            self.fromDateTime.minimumDate = Date(timeIntervalSinceNow: 900.0)
            self.toDateTime.minimumDate = Date(timeIntervalSinceNow: 4800.0)
            
            self.nanny = nanny
        }
        if let user = user {
            self.user = user
        }
        self.completion = completion
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
