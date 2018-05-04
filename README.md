
# Nanny Now
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

## 2018

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

