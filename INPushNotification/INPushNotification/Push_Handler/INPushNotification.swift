//The MIT License (MIT)
//
//Copyright (c) 2020 INTUZ
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit

class INPushNotification: NSObject {
    
    // MARK: Shared Instance
    static let shared = INPushNotification()
    
    var hasPush : Bool = false
    var showAlertView : Bool = false
    
    var userInfo : Dictionary<String, Any>? = nil

    var notificationAction: (() -> Void)?
    
    //MARK: Handle Notification From App Delegate.
    class func handleNotification(_ userInfo:Dictionary<String, Any>, isLaunchOptions: Bool = false, waitingTime: UInt64 = 3) -> Void {
        
        // Set Notification Info.
        let notificaion = INPushNotification.shared
        notificaion.hasPush = true
        notificaion.showAlertView = !isLaunchOptions
        notificaion.userInfo = userInfo
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: waitingTime), execute: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PushNotificaitonAlert"), object: nil)
        })
    }
    
    // MARK: Set Observer for Handler Local Notification.
    func setNotificationObserver(_ action: @escaping (() -> Void)) -> Void {
        // Remove Observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PushNotificaitonAlert"), object: nil)
        
        // Add Observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleLocalNotification(_:)), name: NSNotification.Name(rawValue: "PushNotificaitonAlert"), object: nil)
        
        // Assign Completion Handler
        notificationAction = action
    }
    
    // Handler Local Notification
    @objc func handleLocalNotification(_ notification: Notification) -> Void {
        
        // Call Completion Action.
        notificationAction?()
    }
    
    //MARK: Handle Notification Message And Perform Action.
    func handlePushNotification(_ controller: UIViewController) -> Void {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: 2)) {
            
            let notification = INPushNotification.shared
            
            // If has notification and valid type then handler message.
            if notification.hasPush == true, let data = notification.userInfo {
                notification.hasPush = false
                
                let message = data["message"] as? String ?? ""
                let isIOS10OrGreater = UIDevice.systemFloatVersion() >= 10
                if notification.showAlertView == true && !isIOS10OrGreater {
                    let alert = UIAlertController(title: "Notification",
                                                  message: message,
                                                  preferredStyle: UIAlertController.Style.alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    let okAction = UIAlertAction(title: "View", style: .default, handler: { (alert) in
                        // Perform action on View Clicked.
                        self.performNotificationAction()
                    })
                    alert.addAction(cancelAction)
                    alert.addAction(okAction)
                    controller.present(alert, animated: true, completion: nil)
                }
                else {
                    // Perform action when open app from notification.
                    self.performNotificationAction()
                }
            }
        }
    }
    
    func performNotificationAction() -> Void {
        
        let notification = INPushNotification.shared
        if let userInfo = notification.userInfo {
            if let notificationType = userInfo["notification_type"] as? String {
                // Liked Post / Comment
                if notificationType == "like" {
                    // Navigate to Feed Details
                }
                // Follow Request
                else if notificationType == "request" {
                    // Navigate to User Profile
                }
                // Comment On Post
                else if notificationType == "comment" {
                    // Navigate to Feed Details
                }
                // Indivitual Chat Message
                else if notificationType == "chat" {
                    // Navigate to Chat Screen
                }
                // Group Chat Message
                else if notificationType == "groupmessage" {
                    // Navigate to Chat Screen
                }
                // Date of Birth
                else if notificationType == "dob_reminder" {
                    // Navigate to Feed Details
                }
                // Date of Death
                else if notificationType == "dod_reminder" {
                    // Navigate to Feed Details
                }
            }
        }
    }
}
