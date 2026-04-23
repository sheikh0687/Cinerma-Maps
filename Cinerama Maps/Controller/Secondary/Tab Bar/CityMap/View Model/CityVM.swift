//
//  CityViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 03/09/24.
//

import Foundation

class CityViewModel {
    
    var country_ID: String = ""
    var arrayOfDetailCityMap: [Res_CityMap] = []
    var arrayOfFilteredDetails: [Res_CityMap] = []
    
    var requestSuccessfull:(() -> Void)?
    
    public func setupSearchBar(for search_Bar: UISearchBar) {
        search_Bar.placeholder = R.string.localizable.search()
        search_Bar.barTintColor = UIColor.white
        search_Bar.searchTextField.backgroundColor = UIColor.white
        search_Bar.searchTextField.textColor = UIColor.black
        search_Bar.searchTextField.font = UIFont(name: "Avenir-Medium", size: 12)
        
        if let clearButton = search_Bar.searchTextField.value(forKey: "_clearButton") as? UIButton {
            clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        }
        
        search_Bar.layer.cornerRadius = 10
        search_Bar.layer.masksToBounds = true
    }
    
    func navigateToCityMapsDetailViewController(from navigationController: UINavigationController?, cityId: String, isSubscribed: String, cityName: String, cityAmount: String, cityRating: String, cityAddress: String, cityMonth: String, cityLat: String, cityLon: String, countryiD: String, cityImg: String) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllMapsDetailVC") as! AllMapsDetailVC
//        vC.cityID = cityId
        vC.viewModel.cityId = cityId
        vC.isSubscribed = isSubscribed
        
        vC.nameOfCity = cityName
        vC.ratingOfCity = cityRating
        vC.addressOfCity = cityAddress
        vC.amountForCity = Double(cityAmount) ?? 0.0
        vC.monthForCity = cityMonth
        vC.latitudeOfCity = cityLat
        vC.longitudeOfCity = cityLon
        vC.countryMapiD = countryiD
        vC.imageOfCity = cityImg
        navigationController?.pushViewController(vC, animated: true)
    }
    
    func returnBackk(from navigationController: UINavigationController?) {
        navigationController?.popViewController(animated: true)
    }
    
    func requestCityMapDetails(vC: UIViewController)
    {
        var param: [String : AnyObject] = [:]
        param["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        param["country_id"] = country_ID as AnyObject
        
        print(param)
        
        Api.shared.requestCityMap(vC, param) { responseData in
            if responseData.count > 0 {
                self.arrayOfDetailCityMap = responseData
                self.arrayOfFilteredDetails = responseData
            } else {
                self.arrayOfDetailCityMap = []
                self.arrayOfFilteredDetails = []
            }
            self.requestSuccessfull?()
        }
    }
    
    func fetchFavAndUnFavMap(vC: UIViewController, cityId: String)
    {
        var param: [String : AnyObject] = [:]
        param["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        param["city_id"] = cityId as AnyObject
        
        print(param)
        
        Api.shared.requestToSelectFavUnFavCityMap(vC, param) { responseData in
            if responseData.status == "1" {
                self.requestSuccessfull?()
            } else {
                print(responseData.message ?? "")
            }
        }
    }
}
