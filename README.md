
# !  [Nanny Now App Icon](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Library/Assets.xcassets/Nanny%20Now%20-%20App%20Icon%20Small.imageset/Nanny%20Now%20-%20App%20Icon%20Small.png)    Nanny Now    
Barnepass, Trygt, Raskt og Lett tilgjengelig

![Presentasjon av Nanny Now](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Library/Assets.xcassets/_presentation.imageset/presentation.png)  

## The project is build around Tabbar Controller (4 tabbar items)
**Konto** [StartViewController](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Controllers/StartViewController.swift) | **Nanny** [NannyViewController](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Controllers/NannyViewController.swift) | **Family** [FamilyViewController](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Controllers/FamilyViewController.swift) | **Melding** [MessageViewController](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Controllers/MessageViewController.swift)


![Tabbar in Main.storyboard](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Library/Assets.xcassets/_Tabbar.imageset/Tabbar.png)


# Services

## Database / Storage
Firebase Database & Firebase Storage - [DataService.swift](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Services/DataService.swift)

## Login / Register
[LoginManager](https://github.com/bjarnet3/Nanny-Now/tree/master/Nanny%20Now/Controllers/LoginViewController) + [Facebook Login API](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Controllers/LoginViewController/LoginZeroVC.swift) + [Firebase Authentication](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Services/DataService.swift)

![Login in LoginZeroVC](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Library/Assets.xcassets/_Login.imageset/Login.png)

## Notifications
Notifications Singleton - [Notifications.swift](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Services/Notifications.swift)

![Notifications in LoginZeroVC](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Library/Assets.xcassets/_Notification.imageset/Notification.png)

## LocationManager / Maps
GPS & Geolocation Services

![LocationManager in NannyViewController](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Library/Assets.xcassets/_Location.imageset/Location.png)

## Regular View / Base
--

![Base Views in NannyViewController](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Library/Assets.xcassets/_BaseViews.imageset/BaseViews.png)

## Animations & Effects
[Blur](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Controllers/MessageViewController.swift) -- [TabBarAnimations](https://github.com/bjarnet3/Nanny-Now/tree/master/Pods/RAMAnimatedTabBarController) -- [Fade](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Utilities/Functions.swift) -- [ParallaxEffectOnView](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Utilities/Functions.swift) -- [CellAnimation](https://github.com/bjarnet3/Nanny-Now/blob/master/Nanny%20Now/Utilities/Functions.swift) -- [SplashView](https://github.com/bjarnet3/Nanny-Now/tree/master/Pods/RevealingSplashView)

# Target / Progress / Goal

## 2016
### Week 23
- [x] Nanny Now - Start Nanny Now Development

### Week 24
- [x] Nanny Now - Implement TableView
- [x] Nanny Now - Implement MapKit
- [x] Nanny Now - Custom ImageView (Rounded corners on Images)

### Week 25
- [ ] Nanny Now - Polymorphism (add from VC to Model) - NOT DONE
- [ ] Nanny Now - MVC - NOT DONE
- [x] Nanny Now - Application Icons
- [x] Nanny Now - Clean up

### Week 26
- [x] Nanny Now «First presentation slide»

### Week 27
- [ ] Nanny Now - Launch Image - NOT DONE
- [ ] Nanny Now - Add to InfoVC - NOT DONE
- [x] Nanny Now - Change StartVC
- [x] Nanny Now - Fix Annotation array (from static implementation)
- [x] Nanny Now - Polymorphism (add from VC to Model) - ALMOST DONE
- [x] Nanny Now - MVC
- [x] Nanny Now - Convert to #Swift 3.0
- [x] Nanny Now - Update «Generic Function» Custom UIColor from RGB: Hex #Swift 3.0
- [x] Nanny Now - Create Calculate To Center Position From Array

### Week 31:
- [x] Nanny Now - Add button Image to Presentation Sheet
- [x] Nanny Now - EmployeeViewController { func notificationSetup(_ all: Bool) { } }

### Week 33:
- Advanced Navigation Bars
- Advanced Table Views
- Advanced Times Tables

### Week 34:
- Webpage to Nanny Now - Alpha 1.0
- Add more buttons (Navigation Buttons)
- Downloading Web Content
- Multiple View Controllers
- Controlling The Keyboard
Summary:
- override func touchesBegan( _  _ ) { self.view.endEditing(true) }
- textFieldShouldReturn( ) { textField.resignFirstResponder() } // add, UITextFieldDelegate

### Week 35:
- JSONParsing
- Optional Chaining
- GeoCoding / Reversed GeoCoding
- Advanced iOS Features II: Animations, Games, Maps & Geolocation, Audio
Summary:
- if let _ = textField { if let _ = label.text { if let _ = text.hashValue }  }  } - NON OPTIONAL CHANING
- if let _ = textField?.text?.hashValue { /* … */ } - OPTIONAL CHANING

### Week 36:
- Start recreation of Nanny Now with Xcode 8 RC
- [x] Nanny Now - StoryBoard - tableViewCell setup
- [x] Nanny Now - Adding User Annotation To Maps

### Week 37:
- Object Oriented Programming VS Protocol Oriented Programming
- Create UIView Playground (Frame, Bounds, Rect) - Maybe use PS instead of Playground
Summary:
- CodeSnippet <#Code>

### Week 38:
- [x] Nanny Now (3D Touch : Quick Actions)
- Firebase «Overview»
- Create Generic UIView (Tinder like buttons) (Look more into Stanford 4 for help) - NOT DONE
Summary:
- didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
- performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping 
- func handleShortcut(shortcutItem: UIApplicationShortcutItem ) -> Bool

### Week 39:
- [x] Nanny Now - Complete Login (Start Screen) - ALMOST DONE (Static)
- [x] Nanny Now - Go from TableViewCell to VC (prepare for seque) - NOT DONE
- Firebase Auth
Summary:
- Documenting /// **Bold** /** */ #H1# ##H2## 

### Week 40:
- [x] Nanny Now - Facebook Authentication with Firebase
- [x] Nanny Now - Email Authentication with Firebase
- Refactoring at Scale - Instagram Presentation (IGListKit Reference)
Summary:
- https://speakerdeck.com/realm/ryan-nystrom-refactoring-at-scale-lessons-learned-rewriting-instagrams-feed

### Week 41:
- [x] Nanny Now - Firebase DB Basic Structure
- UIPictureView post to Firebase / Part 1
- Creating database users for Firebase
- Test Sync til Server (Firebase) (Part 1)
Summary:
- ...

### Week 42:
- [x] Nanny Now - Implement Splash Screen
- [x] Nanny Now - Add Haptic Engine
- Firebase data modeling & architecture
Summary:
- enum HepticEngineTypes { case error, success, warning, light, medium, heavy, selection } 
- Singleton - An instance of a class, that is publicly available that has only one reference.

### Week 43:
- UIPickerView post to Firebase
- Parsing Firebase Database
- Intro to Firebase Storage
- [x] Nanny Now - Authentication with Personal Information from FB
- [x] Nanny Now - Auto Sign in with Keychain (Part 1)
- [x] Nanny Now - Save login to Firebase Database
- [x] Nanny Now - UICollectionView in FamilyViewController (Part 1)
- [x] Nanny Now - UIDatePickerView in UIActionAlert - NOT DONE
- Documenting - Functions, Enums, Structs and Protocols (Part 1) - NOT DONE
Summary:
- FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name"]).start(completionHandler: { (c, r, error) }

### Week 44: (Firebase Datasource)
- Sync and Connect Database (Firebase) (Part 1)
- [x] Nanny Now- UICollectionView in FamilyViewController (Part 1)
- [x] Nanny Now - Test Sync to Server (Firebase) (Part 2)
- [x] Nanny Now - Get «birthday property» from Facebook Login
- Documenting - Functions, Enums, Structs and Protocols (Part 1)
Summary:
- withReadPermissions: ["public_profile", "user_birthday", "email"] - FBSDKLoginManager
- birthday property declared in FBSDKLoginManager...

### Week 45: (Split & Merge)
- Custom Protocol and Delegate Methods
- [x] Nanny Now - Try «Diffing» with Instagram SDK (IGListKit)
- [x] Nanny Now - UIDatePickerView in UIActionAlert
- Conform Protocol and Merge Classes (Nanny & Family) together.

### Week 46:
- FUIAuth.defaultAuthUI() instead of FIRAuthUI.default()

### Week 47: (Firebase)
- [x] Nanny Now - UIPickerViewDelegate and DataSource to extension
- [x] Nanny Now - UITableViewDelegate and DataSource to extension
- [x] Nanny Now - IBDesignable (Removed Again Because of Performance)
- [x] Nanny Now - «Upload Facebook Login Image» to Firebase Storage and set in DB
- [x] Nanny Now - RevealingSplashView in Functions.swift - Standalone function
- [x] Nanny Now - UICollectionView Delegate in FamilyViewController as extension
Summary:
- @IBDesignable // Will update preview in Storyboard / Xib file
- extension NannyViewController : UIPickerViewDelegate, UIPickerViewDataSource - Friendly
- extension NannyViewController : UITableViewDelegate, UITableViewDataSource

### Week 48: (More Firebase)
- [x] Nanny Now - Implement Struct «Firebase Constants»
- [x] Nanny Now - UICollectionView «Easy Display of Fields»
- [x] Nanny Now- Post on Firebase - Part 1
- [x] Nanny Now - Create new Reference (Nannies)
Summary:
- func postToFirebase(_ postNumber: Int) { post to Firebase } 

### Week 49: (Even More Firebase)
- [x] Nanny Now - Post on Firebase - Part 2
- [x] Nanny Now - Upload FB picture to Firebase
- [x] Nanny Now - Create Reference from FB picture to DB
- [x] Nanny Now - Complete Old tutorials
Summary:
- Nanny.swift - // Changed from Foundation to UIKit
- Nanny.swift - // Inherit from MKPointAnnotation

### Week 50: (NEW OFFICE SPACE)

## 2017

### Week 1: (Protocol Oriented Programming)
- [x] Nanny Protocol - Part 1 (Playground)
- [x] Nanny Now - Merge Nanny and CostumPointAnnotation array together
Summary:
- Classes, Structs and Enums that conforms to the same Protocol can be put together in an Array[Protocol]

### Week 2: (Protocol Extensions & Type Extensions)
- [x] Nanny Now - Update Tabbar
- [x] Nanny Protocol - Part 2 (Playground)
Summary:
- Protocol Extensions : implementation of functions to objects conformed to that «base» protocol

### Week 3: (Design Patters, Protocol and Advanced Type Inferences)
- [x] Nanny Now - Conform Nanny Class to User Protocol (Part 1)
- [x] Nanny Now - Add Observer to NannyViewController and TableView
- [x] Nanny Now - Get from Firebase Database (Successful)
Summary:
- DataService.ds.REF_NANNIES.observeSingleEvent(of: .value, with: { (snapshot) in Void } )

### Week 4: (Content uploading & Error resolving)
- [x] Nanny Now - Image Upload to Datastorage
- [x] Nanny Now - Image File Location stored in DB
- [x] Nanny Now - Categorize & Fix
Summary: 
- Dictionary<String, Any>

### Week 5: (Trim, Documentation & Global Function)
- [x] Nanny Now - Post To Firebase / Create Global Function
Summary:
- Optionally Default - display.text = s ?? "  "
- Conditionally Downcast == self.nameLabel.text = self.userInfo["name"] as? String ?? "Unknown name" 
- Timer vs GCD «Grand Central Dispatch» (high level vs low level,, timer easier to stop, dispatch need more code)

### Week 6 - 10: (Flytting og Praktiske ting)
- Flytte, pakke og gjøre praktiske ting
- [x] Nanny Now - Fix Login Screen - NOT DONE
- «Type Inferred Enum» - Kalkuler.playground
Summary:
- var f: (Double) -> Double
- let bigNumbers = [2, 47, 118, 5, 9].filter({ $0 > 20 })  // bigNumber = [ 47, 118 ]

### Week 11: (Views and UIBezierPath)
- [x] Nanny Now - Fix Login Screen - NOT DONE
- [x] Nanny Now - Add TextFields and Buttons - NOT DONE
- [x] Nanny Now - Reintroduce TableView for FamilyVC - Part 1 - NOT DONE
Summary:
- @IBDesignable (update «on the fly» in Interface Builder)
- @IBInspectable (add specific property in Identity Inspector in Interface Builder) (Only explicitly declared)

### Week 12: (Chill and Spill)

### Week 13: (Generics)
- https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Generics.html
- func swapTwoInts(_ a: inout Int, _ b: inout Int)
- func swapTwoStrings(_ a: inout String, _ b: inout String)
- func swapTwoValues<T>(_ a: inout T, _ b: inout T)

### Week 14: (Closures for iOS Developers)
- [x] Nanny Now - Fix Login Screen
- [x] Nanny Now - Add TextFields and Buttons
- [x] Nanny Now - Reintroduce TableView for FamilyVC - Part 1
Summary:
- func someFunction() { }
- var someClosure = { () -> () in }
- Abstract Class «never» initialized,, just used for subclassing «to be subclassed»
- @IBOutlet weak var faceView: FaceView! { didSet { } }

### Week 15: (Firebase Database Order)
- Nanny Protocol - Part 3 (Playground) - NOT DONE
- [x] Nanny Now - Database Order
Summary:
- DataService.ds.REF_NANNIES.queryOrdered(byChild: "breddeGrad" + "lendeGrad").observe

### Week 16: (Nanny Now and Remote Notifications)
- [x] Nanny Now - 1. Create Certificates, IDs and Profiles - ONLY DEVELOPMENT Certificates
- [x] Nanny Now - 2. Setup Firebase for Cloud Messaging
- [x] Nanny Now - 3. Setup Remote Notification in Xcode
- [x] Nanny Now - 4. Send Remote Notification from Application - NOT DONE
- [x] Nanny Now - 5. Receive Notification From Server
Summary:
- Send Multiple Notifications

### Week 17: (Nanny Now and Advanced Notifications)
- [x] Nanny Now - Send Remote Notification from Dedicated server or Terminal - NOT SECURED
- [x] Nanny Now - Send Remote Notification from Application or To Dedicated Server
- [x] Nanny Now - Send Notification From Application to Application
Summary:
- curl -X POST --header "Authorization: key=<API_ACCESS_KEY>"     --Header "Content-Type: application/json"     https://fcm.googleapis.com/fcm/send
- https://framework.realtime.co/blog/ios10-push-notifications-support.html

### Week 18: (Cleanup and Wrap It Up)
- [x] Nanny Now - Cleanup
- [x] Nanny Now - Rich Notification Service :-D
- [x] Nanny Now - Add Database Notification Code
- Nanny Protocol - Part 3 (Playground)

### Week 19: (Rodos Ferie)

### Week 20: (Back 2 Basic + Fix Login)
- [x] Nanny Now - Add Actions On Notification Server
- UIApplication.badge = Unread messages in self.messages (User Database) - Den som sender må sjekke «uleste på mottaker»++
- [x] Nanny Now - Fix Annotation Overlapping
- [x] Nanny Now - Add TextFields and Buttons

### Week 21: (Transformation tuesday OR in between)
- [x] Nanny Now - Cleanup
- [x] Nanny Now - Fix Point Annotation Overlapping - Very Important (Memory Leak)
- [x] Nanny Now - Extend Notification Categories - Not Important
- [x] Nanny Now - Add TextFields and Buttons - Should be very easy
- [x] Nanny Now - Setting up Chat and Request in Database and Xcode
- [x] Nanny Now - Fixing login Functions - Not Complete 
Summary:
- guard can be used outside scope - guard let name else { return } return name 

### Week 22: (New Classes, Global functions, Singletons & Recursion)
- [x] Nanny Now - Sort TableView «closest Nannies»
- [x] Nanny Now - Put Create Notifications() Class and add Global func «sendNotification()»
- [x] Nanny Now - Extend Tabbar Controller / Login
Summary:
- self.nannies.sort(by: { $0.intDistance < $1.intDistance })
- Notifications() is a singleton
- func getMapViewPoints() // northEast and southWest longitude and latitude

### Week 23: (Notification Triks & MiniMix)
- [x] Nanny Now - Notification Class and Appdelegate cleanup - Part 1
- [x] Nanny Now - Change from postDict[location] to post.location.coordinate - Overloading

### Week 24 - 27 : (Swift 4 Update & Vacation)

Uke 28: (New Login screen - «Prepare for seque»)
- [x] Nanny Now - Implement Seque on NannyTableView
- [x] Nanny Now - Add TextFields and Buttons - Should be very easy
Summary:
- if !excemptIDs.contains(userID) { }
- UIView.animate { from view.frame(x,y,height,length) to view.frame(x,y,height,length) }

### Week 29: (Seque, UIView & UICollectionView)
- [x] Nanny Now - Add CollectionView to FamilyVC - Part 1
- [x] Nanny Now - Fix Login Screen - Should be easy
- [x] Nanny Now - Extend Tabbar Controller / Login

### Week 31 - 36: (Keep it Neet, DRY and Repeat)
- Nanny Protocol - Part 3 (Playground)
- [x] Nanny Now - Implement Segue on NannyTableView - Did select row at IndexPath
Summary:
- NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillChangeFrame, object: nil, queue: nil, using: keyboardWillChange(_:)) — Instead of #selector(keyboardWillChange(_:))
- dismiss(animated: true, completion: { } ) — Dismisses the view controller that was presented modally by the view controller.
- self.performSegue(withIdentifier: "riderSeque", sender: nil)

### Week 37 - 43: (Poker Mood & Hey-DJ)
- [x] Nanny Now - Extend Tabbar Controller / Login
- [x] Nanny Now - New Version On TestFlight (Nanny Now v1.2)
- [x] Nanny Now - Add TextFields and Buttons (Part 1) - Should be very easy
- [x] Nanny Now - Fix Login Screen (Part 1) - Should be easy
- [x] Nanny Now - Remake FamilyViewController / FamilyCollectionView !!!
- [x] Nanny Now - Add «Peak and Pop» to Nanny VC with «UIViewControllerPreviewingDelegate»
- [x] Nanny Now - Add «Peak and Pop» to CollectionView with «UIViewControllerPreviewingDelegate»

### Week 44: (Pre-Beta on Nanny Now)
- Page View Controller - THORN TECH (Onboarding-With-UIPageViewController-Starter-master)
- [x] Nanny Now - Fix Login Screen (Part 2)
- [x] Nanny Now - Login Screen With PageViewController Part 1
- [x] Nanny Now - New Version On TestFlight (Nanny Now v1.3)
- [x] Nanny Now - Meeting with new Investors
- [x] Nanny Now - Remake FamilyViewController / FamilyCollectionView !!!
Summary:
- Clicking Facebook login when already logged in will get new facebook image,, if logged out, only regular login «with FB» will occur.
- private(set) public var title: String // private for setting , public for getting

### Week 45: (New Login on Nanny Now with PageVC)
- [x] Nanny Now - Fix Dyrets Phone problem
- [x] Nanny Now - Add TextFields and Buttons (Part 2)
- [x] Nanny Now - Fix Login Screen (Part 2)
- [x] Nanny Now - Login Screen With PageViewController Part 2
- [x] Nanny Now - Remake FamilyViewController / FamilyCollectionView !!!
- [x] Nanny Now - Add «Peak and Pop» to CollectionView with «UIViewControllerPreviewingDelegate»
- [x] Nanny Now - Find Void Delay Function - Pass void functions
Summary:
- postImageToFirebase: Unable to upload image to Firebase storage (not authenticated)

### Week 46: (Complete the Login on Nanny Now)
- [x] Nanny Now - First fase of «Mutual Facebook Friends»
- [x] Nanny Now - Cleaning Code (Part 1)
- [x] Nanny Now - Database Restructuring (Part 1)
Summary:
- DispatchQue == Do things In the background

### Week 47: (Code Cleaning, Get Ratings, New StartViewController) 
- [x] Nanny Now - Remake of StartViewController
- [x] Nanny Now - Cleaning Code (Part 2)
- [x] Nanny Now - Add TextFields and Buttons (Part 3)
- [x] Nanny Now - Fix Login Screen (Part 3)
- [x] Nanny Now - Nanny Detail VC
- [x] Nanny Now - NannyViewController TableView Images is Fixed 
Summary:
- https://medium.com/@mimicatcodes/unwrapping-optional-values-in-swift-3-0-guard-let-vs-if-let-40a0b05f9e69
- FYI: Two users cannot use same image «imageCache» at least from server (NannyVC)
- Thanks to this: https://www.youtube.com/watch?v=GX4mcOOUrWQ «Lets Build That App»

### Week 48: (Passing Objects + Server Architecture)
- [x] Nanny Now - Fix DatabaseObserver — IMPORTANT - Not Complete yet,, half done as always
- [x] Nanny Now - Server Architecture - Look in the Firebase documentation
- [x] Nanny Now - StartViewController add more (Part 2) - IMPORTANT
- [x] Nanny Now - Nanny Detail VC (Part 2) - IMPORTANT
- [x] Nanny Now - MKDirectionsRequest() - MapKit Route / Distance etc - Almost complete
- [x] Nanny Now - Images must be put in Folder on every user,, so it is easier to delete user account.
- [x] Nanny Now - Nanny Detail VC (Part 4) - MapCamera - Experimental
- Fix Constraints for TableView in NannyVC and StartVC
Summary: 
- Markup Formatting Reference / Documentation
- https://developer.apple.com/library/content/documentation/Xcode/Reference/xcode_markup_formatting_ref/index.html
- MKDirectionsRequest() - MapKit Route / Distance etc - Almost complete

### Week 49: (Completion - Preparation)
- [x] Nanny Now - StartViewController add more (Part 3) - IMPORTANT
- [x] Nanny Now - Mutual Friends (Part 2)
- [x] Nanny Now - Clean Up Code on Notifications
- [x] Nanny Now - Database / Datastructure Update (Part 2)
- [x] Nanny Now - Nanny Detail VC (Part 3) - IMPORTANT
- [x] Nanny Now - Nanny Detail VC (Part 3) - Background & TableView like StartVC
- [x] Nanny Now - Settings Page,, Notification, remove, messages, remove Tokens etc…
Summary:
- Token is added to Nannies (function) to get Token from User and add Token to Nannies «when Nanny-Ad is active»
- Token now has Device UUID and name And Sorted by UUID

### Week 50: (The End is near, request & repair) 
- [x] Nanny Now - RequestVC
- [x] Nanny Now - RequestPageVC
- [x] Nanny Now - New Datastructur (Part 1)
- [x] Nanny Now - Small Fixes
- [x] Nanny Now - FamilyTableViewController (Part 1) - VERY IMPORTANT - Remake

### Week 51: (Christmas Holiday)

### Week 52: (New Year)
- [x] Nanny Now - Mutual Friends (Part 3) (Picture and Name) - NOT COMPLETE
- [x] Nanny Now - AnimateCells «Family TableView Cells»
- [x] Nanny Now - Request Observer (Part 1)
- [x] Nanny Now - New Datastructure (Part 2)
- [x] Nanny Now - Notifications Cleanup (Part 1)
Summary:
- Nanny / User - preview-light.jpg in UX-Folder as payment template,, instead of location

## 2018

### Week 1: (Startup & Request)
- [x] Nanny Now - RequestVC
- [x] Nanny Now - RequestPageVC
- [ ] Nanny Now - RequestCurrentVC - prepare for seque «to all requests from that user»
- [x] Nanny Now - Login Page / Register push to Database «Almost Done»
- [x] Nanny Now - New Datastructure (Part 3) - Half done
- [x] Nanny Now - «Firebase USER_PRIVATE/Name» example: «Bjarne 34 år»
- [ ] Nanny Now - Notifications Cleanup (Part 2)
- [x] Nanny Now - Login Page / Register update Public username
- [ ] Nanny Now - Fix : getLocations() crash, probably current is not available

### Week 2: (Time is running out…)
- [x] Nanny Now - Login / Register «Txt Field» Resign / Hide Keyboard on Done Button
- [ ] Nanny Now - RequestCurrentVC locations on NannyAd
- [ ] Nanny Now - NannyDetail «Map Request» in RequestCurrentVC
- [ ] Nanny Now - FamilyTableViewController (Part 1) - VERY IMPORTANT - Remake / Redesign

### Week 3: (Light in the end of the tunnel)
- [x] Nanny Now - Create Tinder like Flipp… 
Summary:
- Touches Begun, Touches Ended & Touches Cancelled - Instead of setHighligted…

### Week 4: (APIs and the week goes By) <— This Week
- [x] Nanny Now - Haptic Light, medium, heavy... touches move
Summary:
- «/Users/bjarnet3/Library/Mobile Documents/com~apple~CloudDocs/Xcode/Projects/_macOS/Hey DJ/firebase-express»
- nvm start - To start the server
- https://github.com/firebase/firebase-ios-sdk/tree/master/Example

### Week 6: (Frameworks, Codecs, Web & Logo)
- [x] Nanny Now - Notification Content «Custom» Request with MapKit - WORKING GOOD
- [ ] Nanny Now - Notification Remake
Summary:
- https://theswiftdev.com/2018/01/25/deep-dive-into-swift-frameworks/
- Target Membership == Almost same as #import == Include
- [ if case let ], [ where case let ], [ for case let ] - http://alisoftware.github.io/swift/pattern-matching/2016/05/16/pattern-matching-4/
- [ if let ] vs [ guard let ] - Expression accesible inside vs outside scope

### Week 7: (Step by Step)
- [ ] Nanny Now - Why, What, How Presentasjon til Frank Mjøs med Video
- [x] Nanny Now - Add block and unBlock DataService function()
- [x] Nanny Now - Fixing UIImageView overlapping pictures - WORKING «reloadData() only if last cell loaded»
- [x] Nanny Now - Cleanup - Part 1
- [ ] Nanny Now - Create Instillinger «seque» - Part 1
- [ ] Nanny Now - Send Request «DatePicker» - Part 1
Summary:
- @available(iOS, deprecated, message: "Use unfold(_:animated:completion) method instead.")

### Week 8: (Final Countdown)
- [ ] Nanny Now - Why, What, How Presentasjon til Frank Mjøs med Video
- [ ] Nanny Now - Create Instillinger «seque» - Part 1
- [ ] Nanny Now - Send Request «DatePicker» - Part 1
- [x] Nanny Now - Cleanup - Part 2 - Nanny / User object
- [ ] Nanny Now - Cleanup - Part 3
- [x] Nanny Now - «Custom Point Annotation» instead of Artwork Annotation - MORE CLEAN

### Week 9: (Resett, Refill & Regain)
- [x] Nanny Now - Cleanup - Part 3 (Nanny / User object)
- [x] Nanny Now - Fix Nanny / Family / Users New Objects - Part 1
- [x] Nanny Now - Fix Nanny / Family / Users New Objects - Part 2
- [ ] Nanny Now - Why, What, How Presentasjon til Frank Mjøs med Video - Side 1
- [x] Nanny Now - Fix & Simplify «Custom Point Annotation»
- [x] Nanny Now - Added Select Route in Nanny Detail View Controller
- [ ] Nanny Now - Mutual Friends dissaperad (Nanny Detali VC)
- [ ] Nanny Now - Create Instillinger «seque» - Part 1
- [ ] Nanny Now - Send Request «DatePicker» - Part 1

### Week 10: (Identity Politics & Feminism)
- [x] Nanny Now - Update 3D / Force Touch icons.
- [x] Nanny Now - Remove Artwork (Annotation) - Part 1
- [ ] Nanny Now - Send Request «DatePicker» - Part 1
- [ ] Nanny Now - Mutual Friends dissaperad (Nanny Detali VC)

### Week 11: (Gledespikene og Landssvikerne)
- [ ] Nanny Now - Fix Constraints for iPhone 8 Plus and iPhone X
- [ ] Nanny Now - Send Request «DatePicker» - Part 1
- [x] Nanny Now - Mutual Friends dissaperad (Nanny Detali VC) - OK
- [x] Nanny Now - Cleanup - Part 4 (Functions / DataService)
- [ ] Nanny Now - Login PVC / Firstname, job Title and imageName not Loading
Summary:
- Property Observer = var flipCount = 0 { didSet { print(self.flipCount) }  }  — print if flipCount didSet

### Week 12 - 13: (…Hemsedal…Easter Bunny…)
- [x] Nanny Now - Fix Constraints for iPhone 8 Plus and iPhone X
- [x] Nanny Now - Release v.1.23

### Week 14: (Criminal Aliens & Cognitive Dissonance)
- [x] Nanny Now - Send Request «DatePicker» - Part 1
Summary:
- self.requests.count == self.totalRequests - 1 <— This was the solution for tableView and reloadData
- Assert() =  Crash if not true (Debugging)
- switch (can be used on most types,, even string)
- enum MemosMenu { case kebab(size: Int) case pizza(String)  }
- switch menuItem { case .kebab(let size: print() case .pizza(let pizzaName): print() }
«Multiple inheritance» with protocols
- Dictionary is also a Collection, as is Set and String
- Equatable protocol, to match objects together 

### Week 15: ()
- [ ] Nanny Now - Send Request «DatePicker» - Part 2
- [x] Nanny Now - Mutual Friends (Nanny Detali VC) (FID) - OK
- [x] Nanny Now - Review Feedback (FID) - OK
- [x] Nanny Now - Extend SettingsViewController / SubSettingsViewController - Part 1
- [ ] Nanny Now - Cleanup

### Week 16: (Versace & Garage)
- [x] Nanny Now - MessageViewController()
- [x] Nanny Now - Removed RequestPageViewController
- [x] Nanny Now - Add Blur Effect with PropertyAnimatorView
- [x] Nanny Now - Remove Artwork (Annotation) - Part 2
- [ ] Nanny Now - Create SubSettings «Seque» - Part 1
- [ ] Nanny Now - Nedtelling / Takstameter / Pris
- [x] Nanny Now - Launch New Version v1.24
- [ ] Add Nanny Now to Github

### Week 17: (Github & Version Control)
- [x] Nanny Now - Fixed Token and Location Manager in Nanny

### Week 18: (Github & Version Control)
- [ ] Nanny Now - Login PVC / Firstname, job Title and imageName not Loading
- [ ] Nanny Now - Why, What, How Presentasjon til Frank Mjøs med Video - Side 1
- [ ] Nanny Now - Create SubSettings «Seque» - Part 1
- [ ] Nanny Now - Nedtelling / Takstameter / Pris
- [x] Add Nanny Now to Github
- [x] Add Other projects to Github (musicVOID, TV-Remote, Poker Mood, FolkVote)

### Week 19: (Deprecated & Obsolete)


# Contributors:
**App Icon Template (iOS)**
- Michael Flarup (https://appicontemplate.com/) - PixelResort, Twitter @flarup

**The Noun Project (Icons)**
- Boudewijn Mijnlieff (noun_206322_cc) - Part of the Logo
- Guillaume Bahri (noun_67650_cc) - Part of the Logo
- Vishal Marotkar (noun_221523_cc) - Part of the Logo
- Mister Pixel (noun_35686_cc) - Part of the Map Annotation
- Sasha Willins (noun_322104_cc) - Part of the Map Annotation and unknown profil female picture
- Gayatri (noun_362109_cc) - Part of the Map Annotation and unknown profil male picture
- Alex Fuller (noun_10551_cc) 

**Notification Sounds**
- [notification11](https://www.zedge.net/ringtone/1716388/)
- [notification48](https://www.zedge.net/ringtone/87154a39-442a-3cc0-b026-709657d4de6d)
- [notification50](https://www.zedge.net/ringtone/9addaf43-4207-3e41-8de9-a933d558e224)
- [success_notification](https://www.zedge.net/ringtone/2c79b8be-ce82-347f-8e80-fae1b7ed58ea)
- [failure_notification](https://www.zedge.net/ringtone/d6cf9eaf-66b3-365f-95d4-1fe486549177)

**Web Page / Internet**

**Web template (for presentation)**
- Blackrock Digital LLC (startbootstrap-creative) MIT License

**Pods and Animations**
- TabBarAnimations - "Thanx to [Ramotion](https://github.com/bjarnet3/Nanny-Now/tree/master/Pods/RAMAnimatedTabBarController)"
- SKSplashView - "Thanx to [sachinkesiraju](https://github.com/bjarnet3/Nanny-Now/tree/master/Pods/RevealingSplashView)"
- SwiftKeychainWrapper - "Thanx to [Jason Rendel](https://github.com/jrendel/SwiftKeychainWrapperExample)"

**Thanks to**

- Espen Dyrnes (DNB Autolease)
- Anne Rydgren (Barnehage Eier)
- Joachim Rydgren (Naprapat)

