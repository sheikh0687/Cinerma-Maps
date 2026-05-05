//
//  FavCityMapViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 24/10/24.
//

import Foundation
import SwiftUI

class FavCityMapViewModel {
    
    var isLoading = true
    var arrayOfFavCityMap: [Res_FavCityMaps] = []
    var arrayOfFilteredFav: [Res_FavCityMaps] = []
    var fetchedSuccessfull:(() -> Void)?
    
    func fetchFavCityMap(vC: UIViewController, tableView: UITableView) {
        Api.shared.requestToFavCityMap(vC) { responseData in
            if responseData.status == "1" {
                if let result = responseData.result {
                    if result.count > 0 {
                        self.arrayOfFavCityMap = result
                        self.arrayOfFilteredFav = result
                        
                        tableView.backgroundView = UIView()
                        tableView.reloadData()
                    }
                }
            } else {
                self.arrayOfFavCityMap = []
                self.arrayOfFilteredFav = []
                
                tableView.backgroundView = UIView()
                tableView.reloadData()
                
                Utility.showNoDataView(R.string.localizable.noDataAvailable(), k.emptyString, in: tableView, parentViewController: vC, image: #imageLiteral(resourceName: "empty_notification"))
            }
            self.fetchedSuccessfull?()
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
                self.fetchedSuccessfull?()
            } else {
                print(responseData.message ?? "")
            }
        }
    }
    
    func navigateToSubscriptionViewController(from navigation: UINavigationController?, cityId: String)
    {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubscriptionMapVC") as! SubscriptionMapVC
        vC.viewModel.cityId = cityId
        vC.cityId = cityId
        navigation?.pushViewController(vC, animated: true)
        
//        let swiftUIView = SubscriptionMapView(viewModel: .init(cityiD: cityId), cityId: cityId)
//
//        let hostingController = UIHostingController(rootView: swiftUIView)
//        hostingController.hidesBottomBarWhenPushed = true
//
//        navigation?.pushViewController(hostingController, animated: true)
    }
    
    func navigateToCityMapsDetailViewController(from navigationController: UINavigationController?, cityId: String, isSubscribed: String, cityName: String, cityAmount: String, cityRating: String, cityAddress: String, cityMonth: String, cityLat: String, cityLon: String, countryiD: String, cityImg: String) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllMapsDetailVC") as! AllMapsDetailVC
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
}
