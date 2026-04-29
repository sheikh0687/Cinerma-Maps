//
//  OtpViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 31/08/24.
//

import Foundation
import OTPFieldView

class OtpViewModel {
    
    var signupStatus: String = ""
    var res_SendOtpModel: Api_SendOtp!
    var emailAddress: String = ""
    var strPhoneKey: String = ""
    
//    var verificationCode: String = ""
    var enteredOtp:String!
    var otpNumber: String = ""
    
    var errorMessage: String = ""
    
    var cloResendOtp:((_ vC: UIViewController) -> Void)?

    func setupOtpView(for otpTextFieldView: OTPFieldView!) {
        otpTextFieldView.fieldsCount = 4
        otpTextFieldView.fieldBorderWidth = 1
        otpTextFieldView.defaultBorderColor = #colorLiteral(red: 0.8862745098, green: 0.368627451, blue: 0.07843137255, alpha: 1)
        otpTextFieldView.filledBorderColor = #colorLiteral(red: 0.8862745098, green: 0.368627451, blue: 0.07843137255, alpha: 1)
        otpTextFieldView.cursorColor = #colorLiteral(red: 0.8862745098, green: 0.368627451, blue: 0.07843137255, alpha: 1)
        otpTextFieldView.displayType = .roundedCorner
        otpTextFieldView.fieldSize = 40
        otpTextFieldView.separatorSpace = 8
        otpTextFieldView.shouldAllowIntermediateEditing = false
        otpTextFieldView.initializeUI()
        otpTextFieldView.delegate = self
    }
    
    func navigateToSignupViewController(from navigationController: UINavigationController?) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupVC") as! SignupVC
        vC.signupViewModel.isComingFrom = "Otp"
        vC.signupViewModel.uEmail = emailAddress
//        vC.signupViewModel.uMobile = mobileNum
//        vC.signupViewModel.phoneKey = strPhoneKey
        navigationController?.pushViewController(vC, animated: true)
    }
    
    func returnBackk(from navigationController: UINavigationController?) {
        navigationController?.popViewController(animated: true)
    }
}

extension OtpViewModel: OTPFieldViewDelegate {
    
    func manageUserSession() {
        k.userDefault.set(true, forKey: k.session.status)
        k.userDefault.set(res_SendOtpModel.user_details?.id, forKey: k.session.userId)
        k.userDefault.set(res_SendOtpModel.user_details?.email ?? "", forKey: k.session.userEmail)
        k.userDefault.set(res_SendOtpModel.user_details?.subscription_status ?? "", forKey: k.session.subcription)
        k.userDefault.set(res_SendOtpModel.user_details?.image ?? "", forKey: k.session.userImg)
        k.userDefault.set(res_SendOtpModel.user_details?.first_name ?? "", forKey: k.session.firstName)
        k.userDefault.set(res_SendOtpModel.user_details?.last_name ?? "", forKey: k.session.lastName)
        Switcher.updateRootVC()
    }

    func validateInput() -> Bool {
        let trimmedEnteredOtp = enteredOtp?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Always allow "1234" as a default/testing OTP
        if trimmedEnteredOtp == "1234" {
            return true
        }
        
        // Retrieve the value as Int and convert to String
        let storedCode = k.userDefault.value(forKey: k.session.verificationCode) as? Int
        let storedCodeString = storedCode.map { String($0) } // Convert Int to String safely
        
        print("Stored Code: \(storedCodeString ?? "nil")")
        print("Entered OTP: \(trimmedEnteredOtp ?? "nil")")
        
        // Compare with stored code if it exists
        if let storedCodeString = storedCodeString, let enteredOtp = trimmedEnteredOtp {
            if storedCodeString == enteredOtp {
                return true
            } else {
                errorMessage = R.string.localizable.pleaseEnterTheValidVerificationCode()
                return false
            }
        } else {
            errorMessage = L102Language.currentAppleLanguage() == "en" ? "Please enter a valid verification code" : "يرجى إدخال رمز تحقق صالح"
            return false
        }
    }
    
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp otpString: String) {
        self.enteredOtp = otpString
    }
}

