//The MIT License (MIT)
//
//Copyright (c) 2020 INTUZ
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit
import UserNotifications
import Firebase
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Register and handle push notification
        registerForRemoteNotification()
        
        // Set Firebase App Configure
        self.setUpFirebaseNotification()
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "com.App.test"
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        DynamicLinks.performDiagnostics(completion: nil)
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics()])
        self.setupCrashlyticsUser()
        
        // Check if launched from notification
        if launchOptions != nil{
            if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? Dictionary<String, Any> {
                // Handle remote notification.
                INPushNotification.handleNotification(userInfo, isLaunchOptions:true)
            }
        }
        
        return true
    }
    
    //MARK: - Register Notification
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            let inviteCategory = UNNotificationCategory(identifier: "Notification", actions: [], intentIdentifiers: [], options: UNNotificationCategoryOptions.customDismissAction)
            let categories = NSSet(objects: inviteCategory)
            
            center.delegate = self
            center.setNotificationCategories(categories as! Set<UNNotificationCategory>)
            center.requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { (granted, error) in
                if !(error != nil){
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            })
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types:[.sound , .alert , .badge] , categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    //MARK: - Notification Delegate Methods
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        //For Production and Sendbox
        let options = ["apns_token" : deviceToken,
                       "apns_sandbox" : 0] as [String : Any] // 1 if APNS sandbox token else 0
        InstanceID.instanceID().token(withAuthorizedEntity: "com.App.test", scope: InstanceIDScopeFirebaseMessaging, options: options) { (string, error) in
            self.connectToFcm(tokenString: string)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        INPushNotification.handleNotification(userInfo as! Dictionary<String, Any>)
    }
    
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let dict = userInfo as? [String: AnyObject] {
            INPushNotification.handleNotification(dict)
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo as! Dictionary<String, Any>
        INPushNotification.handleNotification(userInfo)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

//MARK: FCM Connectivity
extension AppDelegate {
    
    func setupCrashlyticsUser() {
        Crashlytics.sharedInstance().setUserEmail("User Email ID")
        Crashlytics.sharedInstance().setUserIdentifier("user_id")
        Crashlytics.sharedInstance().setUserName("User_Name")
    }
    
    func setUpFirebaseNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification),                                               name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:
            #selector(self.fcmConnectionStateChange), name:
            NSNotification.Name.MessagingConnectionStateChanged, object: nil)
    }
    
    @objc func tokenRefreshNotification(_ notification: Notification) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let tokenString = result?.token {
                print("DeviceToken : \(tokenString)")
                
                StandardUserDefaults.set(tokenString, forKey: "DeviceToken")
                StandardUserDefaults.synchronize()
                
                self.connectToFcm(tokenString: tokenString)
            }
        }
    }
    
    func connectToFcm(tokenString: String?) {
        if tokenString != nil {
            Messaging.messaging().shouldEstablishDirectChannel = true
        }
    }
    
    @objc func fcmConnectionStateChange() {
        if Messaging.messaging().isDirectChannelEstablished {
            print("Connected to FCM.")
        } else {
            print("Disconnected from FCM.")
        }
    }
}
