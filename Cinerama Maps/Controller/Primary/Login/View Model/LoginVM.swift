//
//  LoginViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 31/08/24.
//

import Foundation
import DropDown
import NMLocalizedPhoneCountryView

class LoginViewModel {
    
    var mobileNum: String = ""
    var emailAddress: String = ""
    var signupStatus: String = ""
    var verificationCode: String = ""
    
    var api_ModelToRescueResponse: Api_SendOtp!
    
    var errorMessage: String? {
        didSet {
            self.showErrorMessage?()
        }
    }
    
    var dropDown = DropDown()
    var selectedVal: String = ""
    
    var showErrorMessage: (() -> Void)?
    var loginSuccess: (() -> Void)?

    var phoneKey:String! = "966"
        
    func navigateToOtpViewController(from navigationController: UINavigationController?) {
        let vC = Kstoryboard.instantiateViewController(withIdentifier: "OtpVC") as! OtpVC
        vC.viewModel.signupStatus = signupStatus
        vC.viewModel.res_SendOtpModel = api_ModelToRescueResponse
//        vC.viewModel.strPhoneKey = phoneKey
        vC.viewModel.cloResendOtp = { (viewController) in
            self.requestToCallVerifyNum(vC: viewController, shouldNavigate: false)
        }
        //        vC.viewModel.verificationCode = self.verificationCode
        
        vC.viewModel.emailAddress = self.emailAddress
        navigationController?.pushViewController(vC, animated: true)
    }
    
    func configureDropDown(sender: UIButton)
    {
        dropDown.anchorView = sender
        dropDown.show()
        switch L102Language.currentAppleLanguage()  {
        case "en":
            dropDown.dataSource = ["English","Arabic"]
            dropDown.bottomOffset = CGPoint(x: -60, y: 40)
        default:
            dropDown.dataSource = ["الإنجليزية","العربية"]
            dropDown.bottomOffset = CGPoint(x: 280, y: 40)
        }
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            selectedVal = item
            if index == 0 {
                k.userDefault.set(emLang.en.rawValue, forKey: k.session.language)
                L102Language.setAppleLAnguageTo(lang: "en")
                let _: UIView.AnimationOptions = .transitionFlipFromLeft
                UIView.appearance().semanticContentAttribute = .forceLeftToRight
                isLogout = true
                Switcher.updateRootVC()
            } else {
                k.userDefault.set(emLang.ar.rawValue, forKey: k.session.language)
                L102Language.setAppleLAnguageTo(lang: "ar")
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
                isLogout = true
                Switcher.updateRootVC()
            }
        }
    }
}

extension LoginViewModel {
    
    // Validate user input
    func validateInput() -> Bool {
        if emailAddress.isEmpty {
            errorMessage = L102Language.currentAppleLanguage() == "en" ? "Please enter the valid email address" : "يرجى إدخال عنوان بريد إلكتروني صحيح."
            return false
        }
        return true
    }
    
    func requestToCallVerifyNum(vC: UIViewController, shouldNavigate: Bool = true) {
        
        guard self.validateInput() else { return }
        
        var param: [String : AnyObject] = [:]
        param["email"] = emailAddress as AnyObject
//        param["mobile_with_code"] = "\(phoneKey ?? "")\(mobileNum)" as AnyObject
        param["ios_register_id"] = k.iosRegisterId as AnyObject
        
        print(param)
        
        Api.shared.requestOtpToVerifyNum(vC, param) { responseData in
            // Assuming `responseData` is a dictionary that contains a `status` key
            if let status = responseData.status, status == "1" {
                self.api_ModelToRescueResponse = responseData
                self.signupStatus = responseData.signup_statu ?? ""
                
                if let result = responseData.result, let code = result.code {
                    print("Verification Code: \(code)")
                    k.userDefault.set(code, forKey: k.session.verificationCode)
                } else {
                    print("Error: result or code is nil")
                }
                
                if shouldNavigate {
                    self.loginSuccess?()
                } else {
                    print("Call Api without navigating!!")
                }
                
            } else {
                print(vC.alert(alertmessage: responseData.message ?? ""))
            }
        }
    }
}

