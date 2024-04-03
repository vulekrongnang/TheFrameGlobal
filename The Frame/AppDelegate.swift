//
//  AppDelegate.swift
//  The Frame
//
//  Created by Vu Le on 02/03/2024.
//

import UIKit
import Firebase
import FirebaseCore
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        initFirebase()
        setRootView()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return true
    }
    
    private func initFirebase() {
        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
        let options = FirebaseOptions(contentsOfFile: filePath)
        FirebaseApp.configure(options: options!)
    }
    
    private func setRootView() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let splashVC = SplashViewController()
        let nav = UINavigationController(rootViewController: splashVC)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
    
    func showCreateGroupView() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let createGroupVC = CreateGroupViewController()
        let nav = UINavigationController(rootViewController: createGroupVC)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
    
    func showHomeView() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let HomeVC = HomeViewController()
        let nav = UINavigationController(rootViewController: HomeVC)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
}

