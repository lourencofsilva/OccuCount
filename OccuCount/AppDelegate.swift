//
//  AppDelegate.swift
//  OccuCount
//
//  Created by Lourenço Silva on 11/06/2020.
//

import Firebase
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("AppWillTerminate"), object: nil)
        return
    }

}

