//
//  AppDelegate.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/14/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit
import UserNotifications
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        setupRemoteNotifications(application: application, launchOptions: launchOptions)
        FlameBossAPI.initializeUser(completion: nil)
//        setupCrashlytics()
        
        return true
    }
    
    private func setupRemoteNotifications(application: UIApplication, launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
    {
        application.registerForRemoteNotifications()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        
        let generalCategory = UNNotificationCategory(identifier: "GENERAL",
                                                     actions: [],
                                                     intentIdentifiers: [],
                                                     options: .customDismissAction)
        
        // Register the category.
        center.setNotificationCategories([generalCategory])
        
        // For iOS 10 display notification (sent via APNS)
        center.delegate = self
        
        // Check if launched from notification
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            print("App opened by notification")
            print(notification.description)
        }
    }
    
    private func setupCrashlytics()
    {
        Fabric.with([Crashlytics.self])
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""

        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }

        FlameBossAPI.setApnToken(tokenString)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        postAppBecameActiveNotification()
    }
    
    private func postAppBecameActiveNotification()
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.post(Notification(name: Notification.Name(rawValue: "AppBecameActive")))
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("received notification while app in foreground")
        print(userInfo.debugDescription)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            print("The user dismissed the notification without taking action")
        }
        else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            print("The user launched the app")
        }
        else {
            print("custom?")
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }

}

