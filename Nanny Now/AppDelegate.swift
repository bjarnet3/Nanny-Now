//
//  AppDelegate.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 14.09.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FBSDKLoginKit
import RAMAnimatedTabBarController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // ********************************
    //
    // MARK: - Properties
    //
    // ********************************
    var window: UIWindow?
    var shortcutItem: UIApplicationShortcutItem?
    
    var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    let gcmMessageIDKey = "gcm.message_id"
    
    // ********************************
    //
    // MARK: - Delegates
    //
    // ********************************
    
    /// Tells the delegate that the launch process is almost done and the app is almost ready to run.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Clear badge when app did finish launching
        application.applicationIconBadgeNumber = 0
        
        // [END register_for_notifications]
        FirebaseApp.configure()
        
        // Facebook Part 2
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // get notifications settings.
        setNotificationAuth()
        
        // set user notifications.
        setNotificationCat()
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(forName: Notification.Name.MessagingRegistrationTokenRefreshed, object: nil, queue: nil, using: tokenRefreshNotification(_:))
        
        // User Status
        DataService.instance.updateUserStatus(with: .active)
        
        // Experimental
        application.registerForRemoteNotifications()
        
        var performShortcutDelegate = true
        if let launchOptions = launchOptions {
        
            if let shortcutItem = launchOptions[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            
                print("Application launched via shortcut")
                self.shortcutItem = shortcutItem
            
                performShortcutDelegate = false
            }
        }
        
        return performShortcutDelegate
    }
    
    // Set Notificaiton Authentication
    // -------------------------------
    func setNotificationAuth() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                
                completionHandler: { (grand, error) in
                    guard error == nil else {
                        return
                    }
                    if grand {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
            })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            DispatchQueue.main.async {
                UIApplication.shared.registerUserNotificationSettings(settings)
            }
        }
    }
    
    // Set Notificaiton Categories with Actions
    // ----------------------------------------
    func setNotificationCat() {
        
        // Notification Actions
        // --------------------
        let nannyAccept = UNNotificationAction(identifier: NotificationAction.nannyAccept.rawValue, title: "Aksepter", options: [.foreground, .authenticationRequired])
        // let nannyResponse = UNNotificationAction(identifier: NotificationAction.nannyResponse.rawValue, title: "Svar", options: [.foreground, .authenticationRequired])
        let nannyReject = UNNotificationAction(identifier: NotificationAction.nannyReject.rawValue, title: "Avvis", options: [.destructive, .authenticationRequired])
        
        let familyAccept = UNNotificationAction(identifier: NotificationAction.familyAccept.rawValue, title: "Aksepter", options: [ .foreground, .authenticationRequired])
        let familyResponse = UNNotificationAction(identifier: NotificationAction.familyResponse.rawValue, title: "Svar", options: [ .foreground, .authenticationRequired])
        let familyReject = UNNotificationAction(identifier: NotificationAction.familyReject.rawValue, title: "Avvis", options: [.destructive, .authenticationRequired])
        
        let messageAccept = UNNotificationAction(identifier: NotificationAction.messageAccept.rawValue, title: "Meldinger", options: [.authenticationRequired, .foreground])
        let messageResponse = UNTextInputNotificationAction(identifier: NotificationAction.messageResponse.rawValue, title: "Svar", options: [.authenticationRequired], textInputButtonTitle: "Send", textInputPlaceholder: "Svar")
        // let messageResponse = UNTextInputNotificationAction(identifier: NotificationAction.messageResponse.rawValue, title: "Svar", options: [.authenticationRequired, .foreground], textInputButtonTitle: "Send", textInputPlaceholder: "Svar")
        let messageReject = UNNotificationAction(identifier: NotificationAction.messageReject.rawValue, title: "Mottatt", options: [.destructive])
        
        // Notification Categories
        // -----------------------
        let nannyRequest = UNNotificationCategory(identifier: NotificationCategory.nannyRequest.rawValue, actions: [nannyAccept, messageResponse, nannyReject], intentIdentifiers: [], options: [])
        let nannyMapRequest = UNNotificationCategory(identifier: NotificationCategory.nannyMapRequest.rawValue, actions: [nannyAccept, messageResponse, nannyReject], intentIdentifiers: [], options: [])
        
        let familyRequest = UNNotificationCategory(identifier: NotificationCategory.familyRequest.rawValue, actions: [familyAccept, familyResponse, familyReject], intentIdentifiers: [], options: [])
        let familyMapRequest = UNNotificationCategory(identifier: NotificationCategory.nannyMapRequest.rawValue, actions: [familyAccept, familyReject], intentIdentifiers: [], options: [])
        
        let messageRequest = UNNotificationCategory(identifier: NotificationCategory.messageRequest.rawValue, actions: [messageAccept, messageResponse, messageReject], intentIdentifiers: [], options: [.customDismissAction])
        let messageConfirm = UNNotificationCategory(identifier: NotificationCategory.messageConfirm.rawValue, actions: [messageAccept], intentIdentifiers: [], options: [])
        
        // Set Notification Categories
        // ---------------------------
        UNUserNotificationCenter.current().setNotificationCategories([nannyRequest, nannyMapRequest, familyRequest, familyMapRequest, messageRequest, messageConfirm])
    }
    
    // Facebook     /      FBSDKApplicationDelegate      /
    // ---------------
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url as URL?, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    /// Tells the delegate that the app is about to become inactive.
    /// -----------------------------------------------------------
    func applicationWillResignActive(_ application: UIApplication) {
        // User Status
        DataService.instance.updateUserStatus(with: .inactive)
    }
    
    /// Tells the delegate that the app is about to enter the foreground.
    /// ----------------------------------------------------------------
    func applicationWillEnterForeground(_ application: UIApplication) {
        // User Status
        DataService.instance.updateUserStatus(with: .foreground)
        
        // Clear badge when app is or resumed
        DataService.instance.clearBadge()
    }
    
    /// Tells the delegate that the app has become active.
    /// -------------------------------------------------
    func applicationDidBecomeActive(_ application: UIApplication) {
        // User Status
        DataService.instance.updateUserStatus(with: .active)
        
        connectToFcm()
        guard let shortcut = shortcutItem else { return }
        
        // print("- Shortcut property has been set")
        if handleShortcut(shortcutItem: shortcut) {
            self.shortcutItem = nil
        }
    }
    
    /// Tells the delegate that the app is now in the background.
    /// --------------------------------------------------------
    func applicationDidEnterBackground(_ application: UIApplication) {
        // User Status
        DataService.instance.updateUserStatus(with: .background)
        
        // Messaging.messaging().disconnect()
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
    /// Tells the delegate when the app is about to terminate.
    /// -----------------------------------------------------
    func applicationWillTerminate(_ application: UIApplication) {
        // User Status
        DataService.instance.updateUserStatus(with: .terminate)
    }
    
    // [START refresh_token]
    // ---------------------
    func tokenRefreshNotification(_ notification: Notification) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let refreshedToken = result?.token {
                print("InstanceID token: \(refreshedToken)")
                // Connect to FCM since connection may have failed when attempted before having a token.
                self.connectToFcm()
            }
        }
    }
    
    // FCM Connect and Establish Direct Channel.
    // ----------------------------------------
    func connectToFcm() {
        // Disconnect previous FCM connection if it exists.
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let refreshedToken = result?.token {
                print("InstanceID token: \(refreshedToken)")
                // Disconnect previous FCM connection if it exists.
                // Messaging.messaging().shouldEstablishDirectChannel = true
            }
        }
    }
    
    // MARK : FCM Push Notification . . .
    // ----------------------------------
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase Registration Token \(fcmToken)")
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print(fcmToken)
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    
    /// Tells the delegate that the app successfully registered with Apple Push Notification service (APNs).
    /// ---------------------------------------------------------------------------------------------------
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        })
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
        // InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.sandbox)
    }
    
    /// Sent to the delegate when Apple Push Notification service cannot successfully complete the registration process.
    /// ---------------------------------------------------------------------------------------------------------------
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    /// Tells the app that a remote notification arrived that indicates there is data to be fetched.
    /// -------------------------------------------------------------------------------------------
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        decreaseBadge(application)
    }
    
    // ---------------------------------------------
    // UIBackgroundFetchResult      /   fetchCompletionHandler    /   backGroundFetchResult
    // ---------------------------------------------
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let state : UIApplicationState = application.applicationState
        switch state {
        case UIApplicationState.active:
            print("If needed notify user about the message")
        default:
            print("Run code to download content")
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // Closure @escaping ...
    // ---------------------
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem: shortcutItem))
    }
    
    // Shortcut identifiers
    // --------------------
    func handleShortcut(shortcutItem: UIApplicationShortcutItem ) -> Bool {
        var succeeded = false
        
        func shortCutCase(_ to: Int) -> Bool {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateInitialViewController()
            window?.rootViewController = vc
            guard let tabBarController = window?.rootViewController as? RAMAnimatedTabBarController else { return false }
            // Do not set "from" same as "to", because then "to" will not be selected.
            tabBarController.setSelectIndex(from: 0, to: to)
            return true
        }
        
        switch shortcutItem.type {
            case "no.digital.mood.developer.Nanny-Now.loggInn" :

                succeeded = shortCutCase(0)
            case "no.digital.mood.developer.Nanny-Now.nanny" :

                succeeded = shortCutCase(1)
            case "no.digital.mood.developer.Nanny-Now.family" :

                succeeded = shortCutCase(2)
            // case "no.digital.mood.developer.Nanny-Now.info" :
            default :
                succeeded = shortCutCase(3)
        }
        return succeeded
    }
    
    // Increase and Decrease Badge (on Application)
    // -------------------------------------------
    func increaseBadge(_ application: UIApplication) {
        let badge = application.applicationIconBadgeNumber != 0 ? application.applicationIconBadgeNumber + 1 : 1
        application.applicationIconBadgeNumber = badge
        DataService.instance.updateBadge(for: badge)
    }
    
    func decreaseBadge(_ application: UIApplication) {
        let badge = application.applicationIconBadgeNumber != 0 ? application.applicationIconBadgeNumber - 1 : 0
        application.applicationIconBadgeNumber = badge
        DataService.instance.updateBadge(for: badge)
    }
    
}
// [END ios_10_data_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.

    // Called when a notification is delivered to a foreground app
    //  --------------------------------------------------
    //  willPresent    /   foreground     /   notification    /   Main
    //  --------------------------------------------------
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound])
    }
    
    // Called to let your app know which action was selected by the user for a given notification.
    // Called when a notitication is delivered to background
    //  -------------------------------------------
    //  didRecieve    /   background      /   response    /   Main
    //  -------------------------------------------
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        notificationResponse(response: response, completionHandler: completionHandler)
        completionHandler()
    }
    
    // ---------------------------------------------
    // notificationMessageResponse      /   response    /   helper
    // ---------------------------------------------
    func notificationResponse(response: UNNotificationResponse, completionHandler: Completion? = nil) {
        let notificationAction = notificationRequest(action: response.actionIdentifier)
        
        switch notificationAction {
        case .nannyAccept:
            notificationRequestAction(notificationAction: .nannyAccept, response: response)
            completionHandler?()
        case .nannyResponse:
            notificationRequestAction(notificationAction: .nannyResponse, response: response)
            completionHandler?()
        case .nannyReject:
            notificationRequestAction(notificationAction: .nannyReject, response: response)
            completionHandler?()
        case .messageAccept:
            notificationMessageAction(notificationAction: .messageAccept, response: response)
            completionHandler?()
        case .messageResponse:
            notificationMessageAction(notificationAction: .messageResponse, response: response)
            completionHandler?()
        default:
            print("default")
            completionHandler?()
        }
        completionHandler?()
    }
    
    // ---------------------------------------------
    // notificationRequestAction      /   response    /   helper
    // ---------------------------------------------
    func notificationRequestAction(notificationAction: NotificationAction, response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        let action = response.actionIdentifier
        
        guard let userID = userInfo["remoteID"] as? String else { return }
        guard let remoteID = userInfo["userID"] as? String else { return }
        guard let requestID = userInfo["requestID"] as? String else { return }
        
        let publicRequest = DataService.instance.REF_REQUESTS.child("public").child(userID).child(requestID)
        let privateRequest = DataService.instance.REF_REQUESTS.child("private").child(userID).child("requests").child(requestID)
        
        let publicRemote = DataService.instance.REF_REQUESTS.child("public").child(remoteID).child(requestID)
        // let privateRemote = DataService.instance.REF_REQUESTS.child("private").child(remoteID).child("requests").child(requestID)
        
        func returnRequestStatus(requestStatus: RequestStatus) -> [String:String] {
            return [ "requestStatus":requestStatus.rawValue ]
        }
        
        switch notificationAction {
        case .nannyAccept:
            let updateStatus = returnRequestStatus(requestStatus: .accepted)
            
            publicRequest.updateChildValues(updateStatus)
            DataService.instance.moveValuesFromRefToRef(fromReference: publicRequest, toReference: privateRequest)
            publicRemote.updateChildValues(updateStatus)
            DataService.instance.REF_NANNIES.child("active").child(userID).removeValue()
            
            // Go to Message / Request location
            // --------------------------------
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateInitialViewController()
            window?.rootViewController = vc
            guard let tabBarController = window?.rootViewController as? RAMAnimatedTabBarController else { return  }
            
            tabBarController.setSelectIndex(from: 0, to: 3)
            tabBarController.tabBarItem.badgeValue = nil
        case .nannyResponse:
            let privateRequest = DataService.instance.REF_REQUESTS.child("private").child(remoteID).child("requests").child(requestID)
            let updateUserID = ["userID": userID]
            privateRequest.updateChildValues(updateUserID)
            
            let publicRequest = DataService.instance.REF_REQUESTS.child("public").child(requestID)
            publicRequest.child("familyID").removeValue()
            
            let updateStatus = ["requestStatus":RequestStatus.accepted.rawValue]
            publicRequest.updateChildValues(updateStatus)
        default:
            let updateStatus = returnRequestStatus(requestStatus: .rejected)
            
            publicRequest.setValue(updateStatus)
            DataService.instance.moveValuesFromRefToRef(fromReference: publicRequest, toReference: privateRequest)
            
            publicRemote.updateChildValues(updateStatus)
            DataService.instance.REF_NANNIES.child("active").child(userID).removeValue()
        }
    }
    
    // ---------------------------------------------
    // notificationMessageAction      /   response    /   helper
    // ---------------------------------------------
    func notificationMessageAction(notificationAction: NotificationAction, response: UNNotificationResponse) {
        switch notificationAction {
        case .messageAccept:
            // Go to Message / Request location
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateInitialViewController()
            window?.rootViewController = vc
            guard let tabBarController = window?.rootViewController as? RAMAnimatedTabBarController else { return  }
            
            tabBarController.setSelectIndex(from: 0, to: 3)
            tabBarController.tabBarItem.badgeValue = nil
        case .messageResponse:
            if let textResponse = response as? UNTextInputNotificationResponse {
                
                let messageResponse = textResponse.userText
                
                let userInfo = response.notification.request.content.userInfo
                let remoteID = AnyHashable("userID")
                guard let remoteUID = userInfo[remoteID] as? String else { return }

                DataService.instance.postToMessage(recieveUserID: remoteUID, message: messageResponse)
                decreaseBadge(.shared)
            } else {
                printDebug(object: "UNTextInputNotificationResponse.userText empty")
            }
        default:
            print("messageReject")
        }
    }
    
}

// [START ios_10_data_message_handling]
extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message 10 +: \(remoteMessage)")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: gcmMessageIDKey), object: nil, userInfo: remoteMessage.appData)
    }
    
    // Receive data message on iOS 10 devices while app is in the foreground.
    func application(received remoteMessage: MessagingRemoteMessage) {
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
}

// [END ios_10_data_message_handling]

// Rich Notification Hero
// http://qiita.com/nnsnodnb/items/22b989abb8fcbad2e34d

