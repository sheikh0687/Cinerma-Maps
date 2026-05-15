//
//  EditProfileVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 24/08/24.
//

import UIKit

class SignupVC: UIViewController {

    @IBOutlet weak var lbl_NavigationTitle: UILabel!
    @IBOutlet weak var lbl_FullName: UILabel!
    @IBOutlet weak var txt_FirstName: UITextField!
    @IBOutlet weak var txt_LastName: UITextField!
    @IBOutlet weak var txt_MobileNum: UITextField!
    @IBOutlet weak var btnCountryPickerOt: UIButton!
    @IBOutlet weak var txt_Email: UITextField!
    @IBOutlet weak var btn_SelectGenderOt: UIButton!
    @IBOutlet weak var btn_DOBOt: UIButton!
    @IBOutlet weak var btn_ImagePickerOt: UIButton!
    
    let signupViewModel = SignupViewModel()
    let profileViewModel = ProfileViewModel()
    
    var isFrom: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultCountry()
        
        self.lbl_NavigationTitle.text = signupViewModel.textOnValue()
        self.txt_Email.text = signupViewModel.uEmail
        
        if isFrom == "Profile" {
            fetchUserDetails()
            setupBindings()
            self.txt_Email.isEnabled = false
        } else {
            self.txt_Email.isEnabled = false
            setupBindings()
        }
    }
    
    @IBAction func btn_CountryPicker(_ sender: UIButton) {
        print("Country Picker Tapped!!")
        let countryListVC = CountryList()
        countryListVC.delegate = self
        let navController = UINavigationController(rootViewController: countryListVC)
        self.present(navController, animated: true, completion: nil)
    }

    @IBAction func btn_Back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_SetProfileImg(_ sender: UIButton) {
        if isFrom == "Profile" {
            profileViewModel.configureProfileImg(vC: self, sender: sender)
        } else {
            signupViewModel.configureProfileImg(vC: self, sender: sender)
        }
    }
    
    @IBAction func btn_SelectGender(_ sender: UIButton) {
        if isFrom == "Profile" {
            profileViewModel.configureDropDown(sender: sender)
        } else {
            signupViewModel.configureDropDown(sender: sender)
        }
    }
    
    @IBAction func btn_SelectDOB(_ sender: UIButton) {
        if isFrom == "Profile" {
            self.datePickerTapped(strFormat: "yyyy/MM/dd", mode: .date) { dateString in
                print(dateString)
                self.profileViewModel.uDob = dateString
                sender.setTitle(dateString, for: .normal)
            }

        } else {
            self.datePickerTapped(strFormat: "yyyy/MM/dd", mode: .date) { dateString in
                print(dateString)
                self.signupViewModel.uDob = dateString
                sender.setTitle(dateString, for: .normal)
            }

        }
    }
    
    @IBAction func btn_Save(_ sender: UIButton) {
        if isFrom == "Profile" {
            self.lbl_FullName.isHidden = false
            profileViewModel.uFirstName = txt_FirstName.text ?? ""
            profileViewModel.uLastName = txt_LastName.text ?? ""
            profileViewModel.uEmail = txt_Email.text ?? ""
            profileViewModel.uMobile = txt_MobileNum.text ?? ""
            profileViewModel.requestToUpdate(vC: self)
        } else {
            self.lbl_FullName.isHidden = true
            signupViewModel.uFirstName = txt_FirstName.text ?? ""
            signupViewModel.uLastName = txt_LastName.text ?? ""
            signupViewModel.uEmail = txt_Email.text ?? ""
            signupViewModel.uMobile = txt_MobileNum.text ?? ""
            signupViewModel.requestToRegisterUser(vC: self)
        }
    }
    
    private func setupBindings() {
        if isFrom == "Profile" {
            profileViewModel.showErrorMessage = { [weak self] in
                if let errorMessage = self?.profileViewModel.errorMessage {
                    Utility.showAlertMessage(withTitle: k.appName, message: errorMessage, delegate: nil, parentViewController: self!)
                }
            }
            
            profileViewModel.profileUpdatedSuccessfull = { [self] in
                Utility.showAlertWithAction(withTitle: k.appName, message: L102Language.currentAppleLanguage() == "en" ? "Profile Updated Successfully" : "تم تحديث الملف الشخصي بنجاح", delegate: nil, parentViewController: self) { bool in
                    self.fetchUserDetails()
                }
            }
        } else {
            signupViewModel.showErrorMessage = { [weak self] in
                if let errorMessage = self?.signupViewModel.errorMessage {
                    Utility.showAlertMessage(withTitle: k.appName, message: errorMessage, delegate: nil, parentViewController: self!)
                }
            }
            
            signupViewModel.registerSuccess = { [weak self] in
                guard let self else { return }
                Switcher.updateRootVC()
            }
        }
    }
  
    private func fetchUserDetails()
    {
        profileViewModel.requestUserProfile(vC: self)
        profileViewModel.fetchedSuccess = { [weak self] in
            guard let self = self else { return }
            self.lbl_FullName.text = "\(self.profileViewModel.uFirstName) \(self.profileViewModel.uLastName )"
            self.txt_FirstName.text = self.profileViewModel.uFirstName
            self.txt_LastName.text = self.profileViewModel.uLastName
            self.txt_Email.text = self.profileViewModel.uEmail
            self.txt_MobileNum.text = self.profileViewModel.uMobile
            
            if let country = Countries.shared.first(where: { $0.phoneExtension == self.profileViewModel.phoneKey }) {
                self.updateCountryButton(title: self.makeTitle(for: country))
            }
            
            self.btn_SelectGenderOt.setTitle(self.profileViewModel.uGender, for: .normal)
            self.btn_DOBOt.setTitle(self.profileViewModel.uDob, for: .normal)
            
            if Router.BASE_IMAGE_URL != self.profileViewModel.profileImage {
                Utility.setImageWithSDWebImageOnButton(self.profileViewModel.profileImage, self.btn_ImagePickerOt)
            } else {
                self.btn_ImagePickerOt.setImage(R.image.profile_ic(), for: .normal)
            }
        }
    }
}

extension SignupVC: CountryListDelegate {
 
    // MARK: - Delegate
    func selectedCountry(country: Country) {
        signupViewModel.phoneKey = country.phoneExtension
        profileViewModel.phoneKey = country.phoneExtension
        updateCountryButton(title: makeTitle(for: country))
        print("Selected: \(makeTitle(for: country))")
    }
 
    // MARK: - Default Country (call from viewDidLoad)
    func setDefaultCountry() {
        if let saudi = Countries.shared.first(where: { $0.countryCode == "SA" }) {
            signupViewModel.phoneKey = saudi.phoneExtension
            profileViewModel.phoneKey = saudi.phoneExtension
            updateCountryButton(title: makeTitle(for: saudi))
        }
    }
 
    // MARK: - Title Builder (RTL/LTR)
    private func makeTitle(for country: Country) -> String {
        let flag = country.flag ?? "🏳"
        let ext  = "+\(country.phoneExtension)"
        let code = country.countryCode
 
        if L102Language.currentAppleLanguage() == "ar" {
            return "\(code) \(ext) \(flag)"   // ⭐️ AR:  SA +966 🇸🇦
        } else {
            return "\(flag) \(ext) \(code)"   // ⭐️ EN:  🇸🇦 +966 SA
        }
    }
 
    // MARK: - Button Updater
    private func updateCountryButton(title: String) {
        btnCountryPickerOt.setTitle(title, for: .normal)
        btnCountryPickerOt.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
//        btnCountryPickerOt.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
// 
//        // ⭐️ Alignment based on language
//        if L102Language.currentAppleLanguage() == "ar" {
//            btnCountryPickerOt.contentHorizontalAlignment = .right
//            btnCountryPickerOt.semanticContentAttribute   = .forceRightToLeft
//        } else {
//            btnCountryPickerOt.contentHorizontalAlignment = .left
//            btnCountryPickerOt.semanticContentAttribute   = .forceLeftToRight
//        }
// 
//        btnCountryPickerOt.setContentHuggingPriority(.required, for: .horizontal)
//        btnCountryPickerOt.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
