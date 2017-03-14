//
//  AppDelegate.swift
//  HoosRight
//
//  Created by ios on 13/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import UIKit
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let reachability = Reachability()!
    let userNameKeyConstant = "keyWord"
    let prefs = UserDefaults.standard
    let notificationName = Notification.Name("rechabilitySwift")


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.networkReachability()
        prefs.removeObject(forKey: userNameKeyConstant)
        prefs.synchronize()
        self.window?.tintColor = UIColor(red:0.87, green:0.31, blue:0.25, alpha:1.0)
        if !(UserDefaults.standard.dictionary(forKey: "UserLoginDetails") == nil) {
            
            let initialViewController = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "SWRevealViewController") as UIViewController
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            appDelegate.window?.rootViewController = initialViewController
        }
        else {
            print("nilll.................")
            let initialViewController = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "firstVC") as UIViewController
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            appDelegate.window?.rootViewController = initialViewController
            
        }

        return true
    }

    func networkReachability() {
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async() {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async() {
                print("Not reachable")
            }
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        reachability.stopNotifier()
    }


}

