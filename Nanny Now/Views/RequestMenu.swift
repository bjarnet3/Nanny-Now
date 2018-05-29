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
    @IBOutlet weak var requestMessage: UITextField!
    @IBOutlet weak var requestMessageCheck: UILabel!
    
    @IBOutlet weak var requestType: UISegmentedControl!
    
    @IBOutlet weak var fromSwitch: UISwitch!
    @IBOutlet weak var fromDateTime: UIDatePicker!
    @IBOutlet weak var fromCheck: UILabel!
    
    @IBOutlet weak var toSwitch: UISwitch!
    @IBOutlet weak var toDateTime: UIDatePicker!
    @IBOutlet weak var toCheck: UILabel!
    
    // MARK: - Properties: Array & Varables
    // -------------------------------------
    var user: User?
    var nanny: Nanny?
    var request: Request?
    
    @IBAction func requestTypeAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            fromDateTime.alpha = 1.0
            fromDateTime.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            toDateTime.alpha = 1.0
            toDateTime.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            fromSwitch.setOn(true, animated: true)
            toSwitch.setOn(true, animated: true)
        } else {
            fromDateTime.alpha = 0.2
            fromDateTime.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            fromDateTime.isUserInteractionEnabled = false
            toDateTime.alpha = 0.2
            toDateTime.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            toDateTime.isUserInteractionEnabled = false
            fromSwitch.setOn(false, animated: true)
            fromSwitch.isUserInteractionEnabled = false
            toSwitch.setOn(false, animated: true)
            toSwitch.isUserInteractionEnabled = false
        }
        dismissKeyboard()
    }
    
    // Send Simple Message
    @IBAction func sendRequestAction(_ sender: UIButton) {
        self.sendRequest()
    }
    
    @IBAction func cancelRequestAction(_ sender: Any) {
        /* self.exitAllMenu()
         for selectedAnnotation in self.mapView.selectedAnnotations {
         self.mapView.deselectAnnotation(selectedAnnotation, animated: true)
         }
         self.mapView.showAnnotations(self.nannies, animated: lowPowerModeDisabled)
         */
    }
    
    @IBAction func resignKeyboard(_ sender: Any) {
        dismissKeyboard()
    }

    // MARK: - Functions, Database & Animation
    // ---------------------------------------
    func sendRequest() {
        if let nanny = self.nanny {
            if let user = self.user {
                var requestMessage = "Melding til: \(nanny.firstName)"
                if let text = self.requestMessage.text, text != "" { requestMessage = text }
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
        /*
        self.exitAllMenu()
        for selectedAnnotation in self.mapView.selectedAnnotations {
            self.mapView.deselectAnnotation(selectedAnnotation, animated: true) }
        self.mapView.showAnnotations(self.nannies, animated: lowPowerModeDisabled)
        */
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.endEditing(true)
    }

    // This initializer hides init(frame:) from subclasses
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RequestMenu", owner: self, options: nil)
        addSubview(requestView)
        requestView.frame = self.bounds
        requestView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return nibView
    }

    
    /*
    init(user: User?, nanny: Nanny?) {
        super.init(frame: CGRect.zero)
        
        if let nanny = self.nanny {
            let lastNanny = nanny
            
            self.requestImage.loadImageUsingCacheWith(urlString: lastNanny.imageName)
            self.requestName.text = lastNanny.firstName
            self.requestAge.text = "\(lastNanny.age) år"
            self.requestTitle.text = lastNanny.jobTitle
            self.requestGender.text = lastNanny.gender
            self.requestRating.text = lastNanny.ratingStar
            self.requestDistance.text = lastNanny.returnDistance
            
            self.fromDateTime.minimumDate = Date(timeIntervalSinceNow: 900.0)
            self.toDateTime.minimumDate = Date(timeIntervalSinceNow: 4800.0)
            
            // self.enterRequestMenu()
        }
        if let user = user {
            self.user = user
        }
    }
    */
    
    func initData(user: User?, nanny: Nanny?) {
        if let nanny = self.nanny {
            let lastNanny = nanny
            
            self.requestImage.loadImageUsingCacheWith(urlString: lastNanny.imageName)
            self.requestName.text = lastNanny.firstName
            self.requestAge.text = "\(lastNanny.age) år"
            self.requestTitle.text = lastNanny.jobTitle
            self.requestGender.text = lastNanny.gender
            self.requestRating.text = lastNanny.ratingStar
            self.requestDistance.text = lastNanny.returnDistance
            
            self.fromDateTime.minimumDate = Date(timeIntervalSinceNow: 900.0)
            self.toDateTime.minimumDate = Date(timeIntervalSinceNow: 4800.0)
            // self.enterRequestMenu()
        }
        if let user = user {
            self.user = user
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("requestMenu layoutSubViews")
    }

}
