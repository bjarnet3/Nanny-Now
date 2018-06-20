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
    static var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    
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
        DataService.instance.updateUserStatus(with: .active)
        
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
                // UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func setNotifications() {
        // Notification Actions
        // --------------------
        let nannyAccept = UNNotificationAction(identifier: NotificationAction.nannyAccept.rawValue, title: "Aksepter", options: [.foreground, .authenticationRequired])
        let nannyResponse = UNNotificationAction(identifier: NotificationAction.nannyResponse.rawValue, title: "Svar", options: [.foreground, .authenticationRequired])
        let nannyReject = UNNotificationAction(identifier: NotificationAction.nannyReject.rawValue, title: "Avvis", options: [.destructive, .authenticationRequired])
        
        let familyAccept = UNNotificationAction(identifier: NotificationAction.familyAccept.rawValue, title: "Aksepter", options: [ .foreground, .authenticationRequired])
        let familyResponse = UNNotificationAction(identifier: NotificationAction.familyResponse.rawValue, title: "Svar", options: [ .foreground, .authenticationRequired])
        let familyReject = UNNotificationAction(identifier: NotificationAction.familyReject.rawValue, title: "Avvis", options: [.destructive, .authenticationRequired])
        
        // let actionLater = UNNotificationAction(identifier: "actionLater", title: "Påminnelse om 10 sekunder", options: [])
        // let actionShowDetails = UNNotificationAction(identifier: "actionShowDetails", title: "Vis detaljer", options: [.foreground])
        // let actionReject = UNNotificationAction(identifier: "actionReject", title: "Avvis", options: [.destructive, .authenticationRequired])
        
        let messageAccept = UNNotificationAction(identifier: NotificationAction.messageAccept.rawValue, title: "OK", options: [.destructive])
        let messageResponse = UNTextInputNotificationAction(identifier: NotificationAction.messageResponse.rawValue, title: "Svar", options: [.authenticationRequired], textInputButtonTitle: "Send", textInputPlaceholder: "Svar")
        let messageReject = UNNotificationAction(identifier: NotificationAction.messageReject.rawValue, title: "Avvis", options: [.destructive])
        
        // Notification Categories
        // -----------------------
        let nannyRequest = UNNotificationCategory(identifier: NotificationCategory.nannyRequest.rawValue, actions: [nannyAccept, nannyResponse, nannyReject], intentIdentifiers: [], options: [])
        let nannyMapRequest = UNNotificationCategory(identifier: NotificationCategory.nannyMapRequest.rawValue, actions: [nannyAccept, nannyReject], intentIdentifiers: [], options: [])
        
        let familyRequest = UNNotificationCategory(identifier: NotificationCategory.familyRequest.rawValue, actions: [familyAccept, familyResponse, familyReject], intentIdentifiers: [], options: [])
        let familyMapRequest = UNNotificationCategory(identifier: NotificationCategory.nannyMapRequest.rawValue, actions: [familyAccept, familyReject], intentIdentifiers: [], options: [])
        
        let messageRequest = UNNotificationCategory(identifier: NotificationCategory.messageRequest.rawValue, actions: [messageAccept, messageResponse, messageReject], intentIdentifiers: [], options: [])
        let messageConfirm = UNNotificationCategory(identifier: NotificationCategory.messageConfirm.rawValue, actions: [messageAccept], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([nannyRequest, nannyMapRequest, familyRequest, familyMapRequest, messageRequest, messageConfirm])
    }
    
    // Facebook Part 3
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url as URL?, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    /// Tells the delegate that the app is about to become inactive.
    func applicationWillResignActive(_ application: UIApplication) {
        // User Status
        DataService.instance.updateUserStatus(with: .inactive)
    }
    
    /// Tells the delegate that the app is about to enter the foreground.
    func applicationWillEnterForeground(_ application: UIApplication) {
        // User Status
        DataService.instance.updateUserStatus(with: .active)
        
        // Clear badge when app is or resumed
        application.applicationIconBadgeNumber = 0
    }
    
    /// Tells the delegate that the app has become active.
    func applicationDidBecomeActive(_ application: UIApplication) {
        // User Status
        DataService.instance.updateUserStatus(with: .active)
        
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
        DataService.instance.updateUserStatus(with: .inactive)
        
        // Messaging.messaging().disconnect()
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
    /// Tells the delegate when the app is about to terminate.
    func applicationWillTerminate(_ application: UIApplication) {
        // User Status
        DataService.instance.updateUserStatus(with: .terminate)
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
        Messaging.messaging().shouldEstablishDirectChannel = true
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
        if let mediaUrl = userInfo["remoteURL"] as? String {
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
        DataService.instance.REF_AI.child("foreground").setValue("foreground")
        
        if notification.request.content.categoryIdentifier == NotificationCategory.messageRequest.rawValue {
            completionHandler([.alert, .sound])
            return
        } else {
            completionHandler([])
        }
    }
    
    /// Called to let your app know which action was selected by the user for a given notification.
    /// Called when a notitication is delivered to background
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        
        DataService.instance.REF_AI.child("foreground").setValue("foreground")
        
        // let action = response.actionIdentifier
        
        actionForNotificaion(notificationAction: notificationRequest(action: response.actionIdentifier), response: response, completion: completionHandler)
        
        // MARK: Action will happen on all Notification Events "including" all responses
        // Not launched if Notficitaion is ignored
        // completionHandler()
    }
    
    func actionForNotificaion(notificationAction: NotificationAction, response: UNNotificationResponse, completion: Completion? = nil) {
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
            // Switch
            let updateStatus = returnRequestStatus(requestStatus: .accepted)
            
            publicRequest.updateChildValues(updateStatus)
            DataService.instance.moveValuesFromRefToRef(fromReference: publicRequest, toReference: privateRequest)
            publicRemote.updateChildValues(updateStatus)
            DataService.instance.REF_NANNIES.child("active").child(userID).removeValue()
            
            // Go to Message / Request location
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
        case .nannyReject:
            let updateStatus = returnRequestStatus(requestStatus: .rejected)
            
            publicRequest.setValue(updateStatus)
            DataService.instance.moveValuesFromRefToRef(fromReference: publicRequest, toReference: privateRequest)
            
            publicRemote.updateChildValues(updateStatus)
            DataService.instance.REF_NANNIES.child("active").child(userID).removeValue()
        case .messageAccept:
            // Go to Message / Request location
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateInitialViewController()
            window?.rootViewController = vc
            guard let tabBarController = window?.rootViewController as? RAMAnimatedTabBarController else { return  }
            
            tabBarController.setSelectIndex(from: 0, to: 3)
            tabBarController.tabBarItem.badgeValue = nil
        case .messageResponse:
            
            DataService.instance.REF_AI.child("messageResponse").setValue("responseMessage")
            
            if let responseText = response as? UNTextInputNotificationResponse {
                let responseMessage = responseText.userText
                
                let user = User(userUID: userID)
                let remote = User(userUID: remoteID)
                // let responseText = "messageResponse Text"
                var message = Message(from: user, to: remote, message: responseMessage, messageID: requestID)
                message.setCategory(category: .messageConfirm)
                
                DataService.instance.REF_AI.child("messageResponse").setValue(responseMessage)
                Notifications.instance.sendNotification(with: message)
            }
            completion?()
            return
        default:
            print("")
        }
        completion?()
    }
    
}


// [START ios_10_data_message_handling]
extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("didRefreshRegistrationToken")
    }
    
    // Receive data message on iOS 10 devices while app is in the foreground.
    func application(received remoteMessage: MessagingRemoteMessage) {
        
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        print("applicatioRecievdRemoteMessage \(remoteMessage.appData)")
    }
    
}
// [END ios_10_data_message_handling]

// Rich Notification Hero
// http://qiita.com/nnsnodnb/items/22b989abb8fcbad2e34d

