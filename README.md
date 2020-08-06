<h1>Introduction</h1>
INTUZ is presenting an interesting Custom Push Notification Handler App Control to integrate inside your native iOS-based application. 
Push Notification Handler is a simple component, which lets you handle push notifcation with didreceive push notification method in AppDelegate. 

<br/><br/>
<h1>Features</h1>

- Handle push notification.
- Navigate to Perticular screen with notification type.

<br/><br/>
<h1>Getting Started</h1>

To use this component in your project you need to perform the below steps:

> Steps to Integrate


1) Add `INPushNotification.swift` at the required place on your code.

2) Register the Push notification code 

*You have to add `registerForRemoteNotification()` function in you AppDelegate.
This function will Register your push notifcation service. 

```
// Add In didFinishLaunchingWithOptions
// Check if launched from notification
if launchOptions != nil{
    if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? Dictionary<String, Any> {
        // Handle remote notification.
        INPushNotification.handleNotification(userInfo, isLaunchOptions:true)
    }
}

//Register Notification
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
    } 
    else {
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types:[.sound , .alert , .badge] , categories: nil))
        UIApplication.shared.registerForRemoteNotifications()
    }
}

```

3) If you Push notification then you have changes in "didReceiveRemoteNotification" 

* Add below function in AppDelegate:
```
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
```

**Note:** Make sure that the extension which is used in this component has been added to your project. 


<br/><br/>
**<h1>Bugs and Feedback</h1>**
For bugs, questions and discussions please use the Github Issues.


<br/><br/>
**<h1>License</h1>**
The MIT License (MIT)
<br/><br/>
Copyright (c) 2020 INTUZ
<br/><br/>
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 
<br/><br/>
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<br/>
<h1></h1>
<a href="https://www.intuz.com/" target="_blank"><img src="Screenshots/logo.jpg"></a>




