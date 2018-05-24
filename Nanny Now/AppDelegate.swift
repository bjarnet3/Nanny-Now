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
import FirebaseMessaging
import FirebaseInstanceID

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // ********************************
    //
    // MARK: - Properties
    //
    // ********************************
    var window: UIWindow?
    var shortcutItem: UIApplicationShortcutItem?
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
        setNotifications()
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(forName: Notification.Name.MessagingRegistrationTokenRefreshed, object: nil, queue: nil, using: tokenRefreshNotification(_:))
        
        // User Status
        DataService.instance.updateStatusOnUser(with: .active)
        
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
                        // DispatchQueue.main.async(execute: {} )
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
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func setNotifications() {
        
        // Notification Actions
        // --------------------
        
        
        let nannyAccept = UNNotificationAction(identifier: NotificationCategory.nannyAccept.rawValue, title: "Aksepter", options: [ .foreground, .authenticationRequired])
        let nannyConfirm = UNNotificationAction(identifier: NotificationCategory.nannyConfirmed.rawValue, title: "OK", options: [.destructive, .foreground])
        let nannyReject = UNNotificationAction(identifier: NotificationCategory.nannyReject.rawValue, title: "Avvis", options: [.destructive, .authenticationRequired])
        
        let familyAccept = UNNotificationAction(identifier: NotificationCategory.familyAccept.rawValue, title: "Aksepter", options: [ .foreground, .authenticationRequired])
        let familyConfirm = UNNotificationAction(identifier: NotificationCategory.familyConfirmed.rawValue, title: "OK", options: [.destructive, .foreground])
        let familyReject = UNNotificationAction(identifier: NotificationCategory.familyReject.rawValue, title: "Avvis", options: [.destructive, .authenticationRequired])
        
        // let actionLater = UNNotificationAction(identifier: "actionLater", title: "Påminnelse om 10 sekunder", options: [])
        // let actionShowDetails = UNNotificationAction(identifier: "actionShowDetails", title: "Vis detaljer", options: [.foreground])
        // let actionReject = UNNotificationAction(identifier: "actionReject", title: "Avvis", options: [.destructive, .authenticationRequired])
        
        let messageRequest = UNNotificationAction(identifier: NotificationCategory.messageRequest.rawValue, title: "Svar", options: [.foreground, .authenticationRequired])
        let messageAccept = UNNotificationAction(identifier: NotificationCategory.messageAccept.rawValue, title: "Ok", options: [.destructive, .authenticationRequired])
        
        // Notification Categories
        // -----------------------
        
        let nannyCategory = UNNotificationCategory(identifier: NotificationCategory.nannyRequest.rawValue, actions: [nannyAccept, nannyConfirm, nannyReject], intentIdentifiers: [], options: [])
        let nannyMapRequest = UNNotificationCategory(identifier: NotificationCategory.nannyMapRequest.rawValue, actions: [nannyAccept, nannyConfirm, nannyReject], intentIdentifiers: [], options: [])
        
        let familyCategory = UNNotificationCategory(identifier: NotificationCategory.familyRequest.rawValue, actions: [familyAccept, familyConfirm, familyReject], intentIdentifiers: [], options: [])
        let familyMapAccept = UNNotificationCategory(identifier: NotificationCategory.nannyMapRequest.rawValue, actions: [familyAccept, familyReject], intentIdentifiers: [], options: [])
        
        let messageCategory = UNNotificationCategory(identifier: NotificationCategory.messageRequest.rawValue, actions: [messageRequest, messageAccept], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([nannyCategory, nannyMapRequest, familyCategory, familyMapAccept, messageCategory])
    }
    
    // Facebook Part 3
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url as URL?, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    /// Tells the delegate that the app is about to become inactive.
    func applicationWillResignActive(_ application: UIApplication) {
        // User Status
        DataService.instance.updateStatusOnUser(with: .inactive)
    }
    
    /// Tells the delegate that the app is about to enter the foreground.
    func applicationWillEnterForeground(_ application: UIApplication) {
        // User Status
        DataService.instance.updateStatusOnUser(with: .active)
        
        // Clear badge when app is or resumed
        application.applicationIconBadgeNumber = 0
    }
    
    /// Tells the delegate that the app has become active.
    func applicationDidBecomeActive(_ application: UIApplication) {
        // User Status
        DataService.instance.updateStatusOnUser(with: .active)
        
        // Clear badge when app is or resumed
        application.applicationIconBadgeNumber = 0
        
        connectToFcm()
        
        guard let shortcut = shortcutItem else { return }
        
        // print("- Shortcut property has been set")
        if handleShortcut(shortcutItem: shortcut) {
            self.shortcutItem = nil
        }
    }
    
    /// Tells the delegate that the app is now in the background.
    func applicationDidEnterBackground(_ application: UIApplication) {
        // User Status
        DataService.instance.updateStatusOnUser(with: .inactive)
        
        // Messaging.messaging().disconnect()
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
    /// Tells the delegate when the app is about to terminate.
    func applicationWillTerminate(_ application: UIApplication) {
        // User Status
        DataService.instance.updateStatusOnUser(with: .terminate)
    }
    
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        // Won't connect since there is no token
        guard InstanceID.instanceID().token() != nil else {
            return
        }
        // Disconnect previous FCM connection if it exists.
        Messaging.messaging().shouldEstablishDirectChannel = false
        // Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    
    /// Tells the delegate that the app successfully registered with Apple Push Notification service (APNs).
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // FIXME: - Device Token to be changed to ".prod"
        // FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .prod)
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
        // InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.sandbox)
    }
    
    /// Sent to the delegate when Apple Push Notification service cannot successfully complete the registration process
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    /// Tells the app that a remote notification arrived that indicates there is data to be fetched.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber != 0 ? application.applicationIconBadgeNumber - 1 : 0
        
        // TODO: Handle data of notification
        if let mediaUrl = userInfo["mediaUrl"] as? String {
            print("-- did Recieve Remote Notification")
            print(mediaUrl)
        }
    }
    
    // Closure @escaping ...
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        print("Application performActionForShortcutItem")
        completionHandler( handleShortcut(shortcutItem: shortcutItem) )
    }
    
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
}
// [END ios_10_data_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    
    /// Called when a notification is delivered to a foreground app
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])
    }
    
    /// Called to let your app know which action was selected by the user for a given notification.
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let category = response.actionIdentifier
        
        func actionForNotificaion(notificationCategory: NotificationCategory) {
            switch notificationCategory {
            case .nannyRequest:
                print("")
            case .nannyMapRequest:
                print("")
            case .nannyAccept:
                print("nannyAccept")
                // Switch
                let nannyID = userInfo["remoteID"] as? String ?? "noRemoteID"
                let familyID = userInfo["userID"] as? String ?? "noUserID"
                let requestID = userInfo["requestID"] as? String ?? "noRequestID"
                
                let nannyActive = DataService.instance.REF_NANNIES.child("active").child(nannyID)
                let nannyStored = DataService.instance.REF_NANNIES.child("stored").child(familyID).child(nannyID)
                
                DataService.instance.moveValuesFromRefToRef(fromReference: nannyActive, toReference: nannyStored)
                
                let updateStatus = ["requestStatus":"accepted"]
                let updateUserID = ["userID":familyID]
                
                let privateRequest = DataService.instance.REF_REQUESTS.child("private").child(nannyID).child("requests").child(requestID)
                privateRequest.updateChildValues(updateUserID)
                privateRequest.updateChildValues(updateStatus)
                
                let publicRequest = DataService.instance.REF_REQUESTS.child("public").child(nannyID).child(requestID)
                publicRequest.child("userID").removeValue()
                publicRequest.updateChildValues(updateStatus)
                
                let publicAccept = DataService.instance.REF_REQUESTS.child("public").child(familyID).child(requestID)
                DataService.instance.copyValuesFromRefToRef(fromReference: publicRequest, toReference: privateRequest)
                
                publicRequest.updateChildValues(updateUserID)
                DataService.instance.moveValuesFromRefToRef(fromReference: publicRequest, toReference: publicAccept)
                
                // Go to Message / Request location
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateInitialViewController()
                window?.rootViewController = vc
                guard let tabBarController = window?.rootViewController as? RAMAnimatedTabBarController else { return  }
                
                tabBarController.setSelectIndex(from: 0, to: 3)
                tabBarController.tabBarItem.badgeValue = nil
            case .nannyConfirmed:
                print("")
                let familyID = userInfo["remoteID"] as? String ?? "noRemoteID"
                let nannyID = userInfo["userID"] as? String ?? "noUserID"
                let requestID = userInfo["requestID"] as? String ?? "noRequestID"
                
                let privateRequest = DataService.instance.REF_REQUESTS.child("private").child(familyID).child("requests").child(requestID)
                let updateUserID = ["userID": nannyID]
                privateRequest.updateChildValues(updateUserID)
                
                let publicRequest = DataService.instance.REF_REQUESTS.child("public").child(requestID)
                publicRequest.child("familyID").removeValue()
                
                let updateStatus = ["requestStatus":"confirmed"]
                publicRequest.updateChildValues(updateStatus)
            case .nannyReject:
                print("")
                let remoteID = userInfo["remoteID"] as? String ?? "noRemoteID"
                // let userID = userInfo["userID"] as? String ?? "noUserID"
                let aps = userInfo["aps"] as? [String: Any]
                let badge = aps?["badge"] as! Int
                
                DataService.instance.REF_USERS_PRIVATE.child(remoteID).child("badge").setValue(badge - 1)
            case .familyRequest:
                print("")
            case .familyAccept:
                print("")
            case .familyMapAccept:
                print("")
            case .familyReject:
                print("")
                let remoteID = userInfo["remoteID"] as? String ?? "noRemoteID"
                // let userID = userInfo["userID"] as? String ?? "noUserID"
                let aps = userInfo["aps"] as? [String: Any]
                let badge = aps?["badge"] as! Int
                
                DataService.instance.REF_USERS_PRIVATE.child(remoteID).child("badge").setValue(badge - 1)
            case .messageRequest:
                // Go to Message / Request location
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateInitialViewController()
                window?.rootViewController = vc
                guard let tabBarController = window?.rootViewController as? RAMAnimatedTabBarController else { return  }
                
                tabBarController.setSelectIndex(from: 0, to: 1)
                tabBarController.tabBarItem.badgeValue = nil
            case .messageAccept:
                print("")
                
            default:
                print("")
            }
        }
        
        actionForNotificaion(notificationCategory: notificationRequest(category: category))
        
        // MARK: Action will happen on all Notification Events "including" all responses
        // Not launched if Notficitaion is ignored
        completionHandler: do {
            // DataService.instance.REF_NANNIES.child("-Kb0HQzRoxbSIrp0zfFu").removeValue()
        }
    }
    
}


// [START ios_10_data_message_handling]
extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("didRefreshRegistrationToken")
    }
    
    // Receive data message on iOS 10 devices while app is in the foreground.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("applicatioRecievdRemoteMessage \(remoteMessage.appData)")
    }
}
// [END ios_10_data_message_handling]

// Rich Notification Hero
// http://qiita.com/nnsnodnb/items/22b989abb8fcbad2e34d

