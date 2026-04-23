//
//  GoogleSignin.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 16/12/24.
//

import Foundation
import GoogleSignIn

class GoogleSign {
    
    func socialLogin(_ vC: UIViewController,_ firstName: String,_ email: String,_ mobile: String,_ socialiD: String)
    {
        var dict:[String: AnyObject] = [:]
        dict["first_name"] = firstName as AnyObject
        dict["last_name"] = k.emptyString as AnyObject
        dict["email"] = email as AnyObject
        dict["mobile"] = mobile as AnyObject
        dict["social_id"] = socialiD as AnyObject
        dict["register_id"] = k.emptyString as AnyObject
        dict["ios_register_id"] = k.iosRegisterId as AnyObject
        dict["lat"]   = kAppDelegate.CURRENT_LAT as AnyObject
        dict["lon"]  = kAppDelegate.CURRENT_LON as AnyObject
        dict["type"]  = "Normal" as AnyObject
        
        print(dict)
        
        Api.shared.requestToSocialLogin(vC, dict) { responseData in
            k.userDefault.set(true, forKey: k.session.status)
            k.userDefault.set(responseData.id ?? "", forKey: k.session.userId)
            k.userDefault.set(responseData.email ?? "", forKey: k.session.userEmail)
            Switcher.updateRootVC()
        }
    }
}

extension GoogleSign {
    
     func googleSignIn(vC: UIViewController) {
        GIDSignIn.sharedInstance.signIn(withPresenting: vC) { [weak self] result, error in
            if let error {
                // you can add error handling
                print("Error", error)
                return
            }
            
            guard let fullName = result?.user.profile?.name else { return }
            guard let userId = result?.user.userID else { return }
            guard let emailAddress = result?.user.profile?.email else { return }
            guard let tokenId = result?.user.idToken else { return }
            
            self?.socialLogin(vC, fullName, emailAddress, k.emptyString, userId)
        }
    }
}
