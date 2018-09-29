//
//  RequestMenu.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 29.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class NannyRequestMenu: UIView {
    
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
    
    @IBOutlet weak var fromDateTime: UIDatePicker!
    @IBOutlet weak var fromCheck: UILabel!
    
    @IBOutlet weak var toDateTime: UIDatePicker!
    @IBOutlet weak var toCheck: UILabel!
    
    @IBOutlet weak var mapSwitch: UISwitch!
    @IBOutlet weak var mapBackView: UIView!
    
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    private var user: User?
    private var remote: User?
    
    private var message: String = ""
    private var completion: Completion?
    
    private func switchUser() {
        (self.user, self.remote) = (self.remote, self.user)
    }
    
    // MARK: - IBAction: Methods connected to UI
    // ----------------------------------------
    @IBAction private func requestTypeAction(_ sender: UISegmentedControl) {
        enum RequestType {
            case request
            case message
        }
        let requestType = sender.selectedSegmentIndex == 0 ? RequestType.request : RequestType.message
        func switchSegment(segmentType: RequestType) {
            let segment: Bool = segmentType == .request ? true : false
            
            mapBackView.alpha = segmentType == .request ? 1.0 : 0.0
            mapBackView.isUserInteractionEnabled = segmentType == .request ? true : false
            
            fromDateTime.alpha = segment ? 1.0 : 0.2
            fromDateTime.isUserInteractionEnabled = segment
            fromDateTime.transform = segment ? CGAffineTransform(scaleX: 1.0, y: 1.0) : CGAffineTransform(scaleX: 0.9, y: 0.9)
            fromCheck.text = segment ? "✓" : "x"
            fromCheck.textColor = UIColor.darkGray
            
            // To Switch, DatePicker & CheckLabel
            toDateTime.alpha = segment ? 1.0 : 0.2
            toDateTime.isUserInteractionEnabled = segment
            toDateTime.transform = segment ? CGAffineTransform(scaleX: 1.0, y: 1.0) : CGAffineTransform(scaleX: 0.9, y: 0.9)
            toCheck.text = segment ? "✓" : "x"
            toCheck.textColor = segment ? UIColor.darkGray : UIColor.lightGray
            
            // TextField & CheckLabel
            requestTextField.alpha = segment ? 0.0 : 1.0
            requestTextField.isUserInteractionEnabled = !segment
            
            // Just enjoy it
            (requestTextField.text, self.message) = (self.message, requestTextField.text ?? "")
            if segment { dismissKeyboard() } else { requestTextField.becomeFirstResponder() }
        }
        switchSegment(segmentType: requestType)
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
    
    @IBAction func mapSwitchAction(_ sender: UISwitch) {
        requestCheck.text = sender.isOn ? "✓" : "x"
    }
    
    // MARK: - Functions, Database & Animation
    // ---------------------------------------
    public func sendRequest() {
        print("sendRequest")
        
        if let remoteUser = self.remote {
            if let user = self.user {
                var requestMessage = "Melding til: \(remoteUser.firstName)"
                if let text = self.requestTextField.text, text != "" { requestMessage = text }
                if self.requestType.selectedSegmentIndex == 0 {
                    // Request
                    requestMessage = "Forespørsel til: \(remoteUser.firstName)"
                    var request = Request(nanny: remoteUser as! Nanny, user: user, timeFrom: self.fromDateTime.date, timeTo: self.toDateTime.date, message: requestMessage)
                    if !mapSwitch.isOn {
                        // Send Nanny Request
                        request.requestCategory = NotificationCategory.nannyRequest.rawValue
                            Notifications.instance.sendNotification(with: request)
                    } else {
                        // Send Map Request
                        request.requestCategory = NotificationCategory.nannyMapRequest.rawValue
                        Notifications.instance.sendNotification(with: request)
                    }
                    
                } else {
                    // Send Message
                    let message = Message(from: user, to: remoteUser, message: requestMessage)
                    Notifications.instance.sendNotification(with: message)
                }
            }
        }
        self.completion?()
    }
    
    private func cancelRequest() {
        self.completion?()
    }
    
    //Calls this function when the tap is recognized.
    private func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.endEditing(true)
    }
    
    // MARK: - Initializers
    // ---------------------------------------
    
    // This initializer hides init(frame:) from subclasses
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initNib()
    }
    
    // Initialize frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        initNib()
    }

    // Initialize Xib File
    private func initNib() {
        Bundle.main.loadNibNamed("NannyRequestMenu", owner: self, options: nil)
        addSubview(requestView)
        requestView.frame = self.bounds
        requestView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    // Initialize Data
    public func initData(user: User?, remote: User?, completion: Completion? = nil) {
        if let remoteUser = remote {
            self.requestImage.loadImageUsingCacheWith(urlString: remoteUser.imageName)
            self.requestName.text = remoteUser.firstName
            self.requestAge.text = "\(remoteUser.age) år"
            self.requestTitle.text = remoteUser.jobTitle
            self.requestGender.text = remoteUser.gender
            self.requestRating.text = remoteUser.ratingStar
            self.requestDistance.text = remoteUser.returnDistance
            
            self.fromDateTime.minimumDate = Date(timeIntervalSinceNow: 900.0)
            self.toDateTime.minimumDate = Date(timeIntervalSinceNow: 4800.0)
            
            self.remote = remoteUser
        }
        if let user = user {
            self.user = user
        }
        self.completion = completion
    }
    
    // MARK: - ViewLoad / LayoutView
    // ---------------------------------------
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
