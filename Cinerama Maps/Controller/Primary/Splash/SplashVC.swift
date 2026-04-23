//
//  SplashVC.swift
//  City Spriiint
//
//  Created by Techimmense Software Solutions on 19/07/23.
//

import UIKit

class SplashVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let status = k.userDefault.bool(forKey: k.session.status)
            if status {
                let mainViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                let vC = UINavigationController(rootViewController: mainViewController)
                kAppDelegate.window?.rootViewController = vC
                kAppDelegate.window?.makeKeyAndVisible()
            } else {
                let vc = Kstoryboard.instantiateViewController(withIdentifier: "OnboardingVC") as! OnboardingVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
