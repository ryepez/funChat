//
//  AppDelegate.swift
//  chatDare
//
//  Created by Ramon Yepez on 9/6/21.
//

import UIKit
import Firebase
@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       //config firebase
        FirebaseApp.configure()
        
        //using firebase persistence to true
        Database.database().isPersistenceEnabled = true
        
        //checking if first time running app
        checkIfFirstLaunch()

        return true
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

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("background")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("application terminated")
    }
    
    func saveViewContext() {
        print("save")

    }
    
    func checkIfFirstLaunch() {
        
        if UserDefaults.standard.bool(forKey: "hasLaunchBefore") {
            print("The app has launched before")
        } else {
            //setting the value if is first time that app runs
            print("This is the first time this app runs!")
            UserDefaults.standard.set(true, forKey: "hasLaunchBefore")
            UserDefaults.standard.set(true, forKey: "firtRun")
            UserDefaults.standard.synchronize()
        }
    }

}

