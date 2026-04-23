//
//  ProfileViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 03/09/24.
//

import Foundation
import DropDown

class ProfileViewModel {
    
    var isComingFrom: String = ""
    var navigationTitle = ""
    
    var uFirstName: String = ""
    var uLastName: String = ""
    var uMobile: String = ""
    var uEmail: String = ""
    var uGender: String = ""
    var uDob: String = "2024-01-02"
    var profileImage: String = ""
    
    var image = UIImage()
    var dropDown = DropDown()
    
    var errorMessage: String? {
        didSet {
            self.showErrorMessage?()
        }
    }
    
    var showErrorMessage: (() -> Void)?
    var fetchedSuccess: (() -> Void)?
    
    var profileUpdatedSuccessfull:(() -> Void)?
    
    func textOnValue() -> String {
        if isComingFrom == "Otp" {
            return R.string.localizable.registerYourProfile()
        } else {
            return R.string.localizable.editProfile()
        }
    }
    
    func isValidUserInput() -> Bool
    {
        if uFirstName.isEmpty {
            errorMessage = R.string.localizable.pleaseEnterTheFirstName()
            return false
        } else if uLastName.isEmpty {
            errorMessage = R.string.localizable.pleaseEnterTheLastName()
            return false
        } else if uEmail.isEmpty {
            errorMessage = R.string.localizable.pleaseEnterTheEmail()
            return false
        } else if uMobile.isEmpty {
            errorMessage = R.string.localizable.pleaseEnterTheMobileNumber()
            return false
        } else if uGender.isEmpty {
            errorMessage = R.string.localizable.pleaseSelectYourGender()
            return false
        } else if uDob.isEmpty {
            errorMessage = R.string.localizable.pleaseEnterYourDateOfBirth()
            return false
        }
        
        return true
    }
    
    func configureDropDown(sender: UIButton)
    {
        dropDown.anchorView = sender
        dropDown.show()
        dropDown.dataSource = [R.string.localizable.male(), R.string.localizable.female()]
        dropDown.bottomOffset = CGPoint(x: -5, y: 40)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            sender.setTitle(item, for: .normal)
            if index == 0 {
                self.uGender = "Male"
            } else {
                self.uGender = "Female"
            }
        }
    }
    
    func configureProfileImg(vC: UIViewController, sender: UIButton)
    {
        CameraHandler.shared.showActionSheet(vc: vC)
        CameraHandler.shared.imagePickedBlock = { (image) in
            self.image = image
            sender.contentMode = .scaleToFill
            sender.setImage(image, for: .normal)
        }
    }
    
    func requestUserProfile(vC: UIViewController)
    {
        Api.shared.requestUserProfile(vC) { responseData in
            print(responseData)
            let obj = responseData
            self.uFirstName = obj.first_name ?? ""
            self.uLastName = obj.last_name ?? ""
            self.uMobile = obj.mobile_with_code ?? ""
            self.uEmail = obj.email ?? ""
//            let onlyPhoneKey = obj.mobile_with_code ?? ""
//            self.phoneKey = String(onlyPhoneKey.prefix(2))
            self.uGender = obj.gender ?? ""
            self.uDob = obj.dob ?? ""
            self.profileImage = obj.image ?? ""
            self.fetchedSuccess?()
        }
    }
    
    func requestToUpdate(vC: UIViewController)
    {
        guard self.isValidUserInput() else { return }
        
        var param: [String : String] = [:]
        param["user_id"] = k.userDefault.value(forKey: k.session.userId) as? String
        param["first_name"] = uFirstName
        param["last_name"] = uLastName
        param["mobile"] = uMobile
        param["mobile_with_code"] = "\(uMobile)"
        param["email"] = uEmail
        param["register_id"] = k.emptyString
        param["ios_register_id"] = k.iosRegisterId
        param["address"] = k.emptyString
        param["lat"] = k.emptyString
        param["lon"] = k.emptyString
        param["gender"] = uGender
        param["dob"] = uDob
        
        print(param)
        
        var paramImg: [String : UIImage] = [:]
        paramImg["image"] = self.image
        
        print(paramImg)
        
        Api.shared.updateUserProfile(vC, param, images: paramImg, videos: [:]) { responseData in
            self.profileUpdatedSuccessfull?()
        }
    }
}
