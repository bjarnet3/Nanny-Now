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
    private var message: String = ""
    private var completion: Completion?
    
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
            fromSwitch.setOn(segment, animated: true)
            fromSwitch.isUserInteractionEnabled = segment
            fromSwitch.transform = segment ? CGAffineTransform(scaleX: 1.0, y: 1.0) : CGAffineTransform(scaleX: 0.9, y: 0.9)
            fromDateTime.alpha = segment ? 1.0 : 0.2
            fromDateTime.isUserInteractionEnabled = segment
            fromDateTime.transform = segment ? CGAffineTransform(scaleX: 1.0, y: 1.0) : CGAffineTransform(scaleX: 0.9, y: 0.9)
            fromCheck.text = segment ? "✓" : "x"
            fromCheck.textColor = UIColor.darkGray
            
            // To Switch, DatePicker & CheckLabel
            toSwitch.setOn(segment, animated: true)
            toSwitch.isUserInteractionEnabled = segment
            toSwitch.transform = segment ? CGAffineTransform(scaleX: 1.0, y: 1.0) : CGAffineTransform(scaleX: 0.9, y: 0.9)
            toDateTime.alpha = segment ? 1.0 : 0.2
            toDateTime.isUserInteractionEnabled = segment
            toDateTime.transform = segment ? CGAffineTransform(scaleX: 1.0, y: 1.0) : CGAffineTransform(scaleX: 0.9, y: 0.9)
            toCheck.text = segment ? "✓" : "x"
            toCheck.textColor = segment ? UIColor.darkGray : UIColor.lightGray
            
            // TextField & CheckLabel
            requestTextField.alpha = segment ? 0.2 : 1.0
            requestTextField.isUserInteractionEnabled = !segment
            
            // Just enjoy it
            (requestTextField.text, self.message) = (self.message, requestTextField.text ?? "")
            
            requestCheck.text = segment ? "x" : "✓"
            requestCheck.textColor = segment ? UIColor.lightGray : UIColor.darkGray
            
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

    // MARK: - Functions, Database & Animation
    // ---------------------------------------
    public func sendRequest() {
        print("sendRequest")
        if let nanny = self.nanny {
            if let user = self.user {
                var requestMessage = "Melding til: \(nanny.firstName)"
                if let text = self.requestTextField.text, text != "" { requestMessage = text }
                if self.requestType.selectedSegmentIndex == 0 {
                    // Send Request
                    requestMessage = "Forespørsel til: \(nanny.firstName)"
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initNib()
    }

    private func initNib() {
        Bundle.main.loadNibNamed("NannyRequestMenu", owner: self, options: nil)
        addSubview(requestView)
        requestView.frame = self.bounds
        requestView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    public func initData(user: User?, nanny: Nanny?, completion: Completion? = nil) {
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
    
    // MARK: - ViewLoad / LayoutView
    // ---------------------------------------
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
