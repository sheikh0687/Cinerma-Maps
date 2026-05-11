//
//  ServiceRatingViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 05/11/24.
//

import Foundation

class ServiceRatingViewModel {
    
    var fetchedSuccessfully:(() -> Void)?
    var reloadSuccessfully:((Res_AddCityRating) -> Void)?
    
    var ratingStar: Double = 0.0
    var ratingMessage: String = ""
    var serviceId: String = ""
    var requestId: String = ""
    var cityId: String = ""
    var reviewType: String = "City"
    
    var errorMessage: String? {
        didSet {
            self.showErrorMessage?()
        }
    }
    
    var showErrorMessage: (() -> Void)?
    
    func isValidUserInput() -> Bool
    {
        if ratingStar.isZero {
            errorMessage = R.string.localizable.pleaseSelectTheRatingStar()
            return false
        } else if ratingMessage.isEmpty {
            errorMessage = R.string.localizable.pleaseGiveTheReview()
            return false
        }
        return true
    }
    
    func addServiceRating(vC: UIViewController) {
        
        guard isValidUserInput() else { return }
        
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        paramDict["service_id"] = serviceId as AnyObject
        paramDict["rating"] = ratingStar as AnyObject
        paramDict["review"] = ratingMessage as AnyObject
        
        print(paramDict)
        
        Api.shared.requestToAddServiceRating(vC, paramDict) { [self] responseData in
            self.fetchedSuccessfully?()
        }
    }
    
    func addCityRating(vC: UIViewController) {
        
        guard isValidUserInput() else { return }
        
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        paramDict["request_id"] = requestId as AnyObject
        paramDict["type"] = reviewType as AnyObject
        
        if reviewType == "City" {
            paramDict["place_id"] = "" as AnyObject
            paramDict["city_id"] = cityId as AnyObject
        } else if reviewType == "Service" {
            paramDict["place_id"] = "" as AnyObject
            paramDict["service_id"] = serviceId as AnyObject
        } else {
            paramDict["city_id"] = "" as AnyObject
            paramDict["place_id"] = cityId as AnyObject
        }
        
        paramDict["driver_id"] = "" as AnyObject
        paramDict["rating"] = ratingStar as AnyObject
        paramDict["review"] = ratingMessage as AnyObject
        
        print(paramDict)
        
        Api.shared.requestToAddCityRating(vC, paramDict) { [self] responseData in
            self.reloadSuccessfully?(responseData)
            self.fetchedSuccessfully?()
        }
    }
}
