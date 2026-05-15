//
//  Switcher.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 02/09/24.
//

import Foundation

class Switcher {
    static func updateRootVC(skipSplash: Bool = true) {
        
        if !skipSplash {
            let rootVC = Kstoryboard.instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
            let nav = UINavigationController(rootViewController: rootVC)
            nav.isNavigationBarHidden = true
            kAppDelegate.window!.rootViewController = nav
            kAppDelegate.window?.makeKeyAndVisible()
            return
        }
        
        let status = k.userDefault.bool(forKey: k.session.status)
        
        if status {
            let mainViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
            let vC = UINavigationController(rootViewController: mainViewController)
            kAppDelegate.window?.rootViewController = vC
            kAppDelegate.window?.makeKeyAndVisible()
        } else {
            if isLogout {
                let rootVC = Kstoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                let nav = UINavigationController(rootViewController: rootVC)
                nav.isNavigationBarHidden = false
                kAppDelegate.window!.rootViewController = nav
                kAppDelegate.window?.makeKeyAndVisible()
            } else {
                let isFirstTime = k.userDefault.bool(forKey: k.session.isFirstTime)
                if isFirstTime {
                    let rootVC = Kstoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    let nav = UINavigationController(rootViewController: rootVC)
                    nav.isNavigationBarHidden = false
                    kAppDelegate.window!.rootViewController = nav
                    kAppDelegate.window?.makeKeyAndVisible()
                } else {
                    let rootVC = Kstoryboard.instantiateViewController(withIdentifier: "OnboardingVC") as! OnboardingVC
                    let nav = UINavigationController(rootViewController: rootVC)
                    nav.isNavigationBarHidden = true
                    kAppDelegate.window!.rootViewController = nav
                    kAppDelegate.window?.makeKeyAndVisible()
                }
            }
        }
    }
}
