//
//  LoginVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 22/08/24.
//

import UIKit
import NMLocalizedPhoneCountryView

class LoginVC: UIViewController {
    
    @IBOutlet weak var txt_CountryPicker: UITextField!
    @IBOutlet weak var txt_EmailAddress: UITextField!
    @IBOutlet weak var txt_MobileNum: UITextField!
    @IBOutlet weak var lbl_Language: UILabel!
    
    @IBOutlet weak var btnCountryPickOt: UIButton!
    @IBOutlet weak var btnTermsAndCondition: UIButton!
    
    let viewModel = LoginViewModel()
    let socialViewModel = GoogleSign()
    
    var strCCode:String! = "966"
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        self.txt_MobileNum.delegate = self
        if L102Language.currentAppleLanguage() == "en" {
            self.lbl_Language.text = "English"
            self.lbl_Language.textAlignment = .left
        } else {
            self.lbl_Language.text = "العربية";
            self.lbl_Language.textAlignment = .right
        }
        self.navigationController?.navigationBar.isHidden = true
//        setTermsAndConditionsText()
    }
    
    func setTermsAndConditionsText() {
        let isEnglish = L102Language.currentAppleLanguage() == "en"
        
        let text = isEnglish
            ? "By registering, you will agree to our terms and conditions."
            : "بالتسجيل، فإنك توافق على شروطنا شروطنا والأحكام"
        
        let subText = isEnglish
            ? "terms and conditions"
            : "شروطنا والأحكام"
        
        let attributedString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: subText)
        
        if range.location != NSNotFound {
            attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: range)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
        
        btnTermsAndCondition.setAttributedTitle(attributedString, for: .normal)
        btnTermsAndCondition.titleLabel?.numberOfLines = 0
        btnTermsAndCondition.titleLabel?.textAlignment = .center
    }
    
    @IBAction func btn_TermCondition(_ sender: UIButton) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Policy_sVC") as! Policy_sVC
        vC.isFrom = "TermCondition"
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Login(_ sender: UIButton) {
//        viewModel.phoneKey = strCCode
//        viewModel.mobileNum = txt_MobileNum.text ?? ""
        viewModel.emailAddress = txt_EmailAddress.text ?? ""
        viewModel.requestToCallVerifyNum(vC: self)
    }
    
    private func setupBindings() {
        viewModel.showErrorMessage = { [weak self] in
            if let errorMessage = self?.viewModel.errorMessage {
                Utility.showAlertMessage(withTitle: k.appName, message: errorMessage, delegate: nil, parentViewController: self!)
            }
        }
        
        viewModel.loginSuccess = { [] in
            self.viewModel.navigateToOtpViewController(from: self.navigationController)
        }
    }
    
    @IBAction func btn_DropLanguage(_ sender: UIButton) {
        viewModel.configureDropDown(sender: sender)
    }
    
    @IBAction func btn_CountryPicker(_ sender: UIButton) {
        print("Country Picker Tapped!!")
        let countryListVC = CountryList()
        countryListVC.delegate = self
        let navController = UINavigationController(rootViewController: countryListVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func btn_SocialLogin(_ sender: UIButton) {
        self.socialViewModel.googleSignIn(vC: self)
    }
}

extension LoginVC: CountryListDelegate {
    func selectedCountry(country: Country) {
        strCCode = "\(country.phoneExtension)"
        print(strCCode!)
        let displayName = country.name ?? country.countryCode
        btnCountryPickOt.setTitle("\(displayName) (\(strCCode!))", for: .normal)
        print("Selected country:", displayName, strCCode!)
    }
}

extension LoginVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the full text after user's input
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

        // Check if it's the first character and it's 0
        if newText.count == 1 && newText == "0" {
            // You can show an alert or just block it
            print("You can not start with 0")
            return false
        }

        return true
    }
}
