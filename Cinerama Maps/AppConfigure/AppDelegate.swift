//
//  AppDelegate.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 22/08/24.
//

import UIKit
import CoreLocation
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import FirebaseCore
import FirebaseMessaging
import SwiftUI
import SDWebImage
import SDWebImageWebPCoder

let Kstoryboard = UIStoryboard.init(name: "Main", bundle: nil)
let kAppDelegate = UIApplication.shared.delegate as! AppDelegate

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    var window: UIWindow?
    var coordinate1 = CLLocation(latitude: 0.0, longitude: 0.0)
    var coordinate2 = CLLocation(latitude: 0.0, longitude: 0.0)
    var CURRENT_LAT = ""
    var CURRENT_LON = ""
    let language = k.userDefault.value(forKey: k.session.language) as? String
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        notificationCenter.delegate = self
        self.configureNotification()
        
        IQKeyboardManager.shared.enable = true
        
        LocationManager.sharedInstance.delegate = kAppDelegate
        LocationManager.sharedInstance.startUpdatingLocation()
        
        CurrencyHandler.shared.fetchCurrenciesFromJsonFile()
        
        GMSServices.provideAPIKey("AIzaSyAGxLMNvIuc8XpG21cOF3VkxbK1EkTpuzQ")
        GMSPlacesClient.provideAPIKey("AIzaSyAGxLMNvIuc8XpG21cOF3VkxbK1EkTpuzQ")
                        
        if let savedLang = k.userDefault.value(forKey: k.session.language) as? String {
            print("Language found in defaults: \(savedLang)")
            if L102Language.currentAppleLanguage() != savedLang {
                L102Language.setAppleLAnguageTo(lang: savedLang)
            }
        } else {
            print("language not set, defaulting to ar")
            k.userDefault.set(emLang.ar.rawValue, forKey: k.session.language)
            L102Language.setAppleLAnguageTo(lang: "ar")
        }
        
        let isRTL = L102Language.currentAppleLanguage() == "ar"
        UIView.appearance().semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        UIPageControl.appearance().semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        L102Localizer.DoTheMagic()
        
        UIScrollView.appearance().bounces = false
        
        if #available(iOS 13.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundEffect = .none
            tabBarAppearance.shadowColor = .clear
            tabBarAppearance.backgroundColor = UIColor.white
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().tintColor = R.color.main()
            UITabBar.appearance().unselectedItemTintColor = .darkGray
            
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }
        
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        
        Switcher.updateRootVC()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func configureNotification() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        }
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                k.iosRegisterId = token
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        k.iosRegisterId = deviceTokenString
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)")
    }
    
    // MARK:-  Received Remote Notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
    }
}

extension AppDelegate: LocationManagerDelegate {
    
    func didEnterInCircularArea() {
        print("")
    }
    
    func didExitCircularArea() {
        print("")
    }
    
    
    func tracingLocation(currentLocation: CLLocation) {
        coordinate2 = currentLocation
        print(coordinate2)
        let distanceInMeters = coordinate1.distance(from: coordinate2) // result is in meters
        if distanceInMeters > 250 {
            CURRENT_LAT = String(currentLocation.coordinate.latitude)
            print(CURRENT_LAT)
            CURRENT_LON = String(currentLocation.coordinate.longitude)
            coordinate1 = currentLocation
            if let _ = UserDefaults.standard.value(forKey: "user_id") {
                //self.updateLatLon()
            }
        }
    }
    
    func tracingLocationDidFailWithError(error: NSError) {
        print("tracing Location Error : \(error.description)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        navigateToMyBooking()
        completionHandler()
    }
    
    func navigateToMyBooking() {
        let visibleVC = UIApplication.shared.topmostViewController()
        
        let vC = Kstoryboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        visibleVC?.navigationController?.pushViewController(vC, animated: true)
    }
}

extension UIViewController {
    func topmostViewController() -> UIViewController {
        if !Thread.isMainThread {
            return DispatchQueue.main.sync {
                self.topmostViewController()
            }
        }
        if let navigationVC = self as? UINavigationController,
           let topVC = navigationVC.topViewController {
            return topVC.topmostViewController()
        }
        if let tabBarVC = self as? UITabBarController,
           let selectedVC = tabBarVC.selectedViewController {
            return selectedVC.topmostViewController()
        }
        if let presentedVC = presentedViewController {
            return presentedVC.topmostViewController()
        }
        if let childVC = children.first {
            return childVC.topmostViewController()
        }
        return self
    }
}

extension UIApplication {
    func topmostViewController() -> UIViewController? {
        if !Thread.isMainThread {
            return DispatchQueue.main.sync {
                self.topmostViewController()
            }
        }
        return keyWindow?.rootViewController?.topmostViewController()
    }
}
