//
//  OtpVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 22/08/24.
//

import UIKit
import OTPFieldView

class OtpVC: UIViewController {
    
    @IBOutlet var otpTextFieldView: OTPFieldView!
    @IBOutlet weak var lbl_UserNumber: UILabel!
    
    let viewModel = OtpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.setupOtpView(for: otpTextFieldView)
        self.lbl_UserNumber.text = viewModel.emailAddress
    }
    
    @IBAction func btn_Back(_ sender: UIButton) {
        viewModel.returnBackk(from: self.navigationController)
    }
    
    @IBAction func btn_Resend(_ sender: UIButton) {
        viewModel.cloResendOtp?(self)
    }
    
    @IBAction func btn_Verification(_ sender: UIButton) {
        if viewModel.validateInput() {
            if viewModel.signupStatus == "Yes" {
                viewModel.manageUserSession()
            } else {
                viewModel.navigateToSignupViewController(from: self.navigationController)
            }
        } else {
            Utility.showAlertMessage(withTitle: k.appName, message: self.viewModel.errorMessage, delegate: nil, parentViewController: self)
        }
    }
}
