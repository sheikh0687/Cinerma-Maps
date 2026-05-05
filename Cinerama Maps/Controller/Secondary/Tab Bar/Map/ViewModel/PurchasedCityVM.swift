//
//  PurchasedCityViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 24/10/24.
//

import Foundation

class PurchasedCityViewModel {
    
    var cityLoading = true
    var arrayOfPurchasedCityMap: [Res_PurchasedCityMap] = []
    var arrayOfFilterPurchaseCityMap: [Res_PurchasedCityMap] = []
    var requestSuccessfull:(() -> Void)?
    
    func fetchPurchaseCityMap(vC: UIViewController,tableView: UITableView, tableHeight: NSLayoutConstraint) {
        Api.shared.requestToPurchasedCityMap(vC) { responseData in
            
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayOfPurchasedCityMap = res
                        self.arrayOfFilterPurchaseCityMap = res
                        tableHeight.constant = CGFloat(self.arrayOfPurchasedCityMap.count * 180)
                        
                        tableView.backgroundView = UIView()
                        tableView.reloadData()
                    }
                }
            } else {
                self.arrayOfPurchasedCityMap = []
                self.arrayOfFilterPurchaseCityMap = []
                
                tableView.backgroundView = UIView()
                tableView.reloadData()
                Utility.showNoDataView(R.string.localizable.noDataAvailable(), k.emptyString, in: tableView, parentViewController: vC, image: #imageLiteral(resourceName: "empty_notification"))
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
    
    func cancelSubcription(vC: UIViewController, countryId: String,cityId: String)
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        paramDict["map_country_id"] = countryId as AnyObject
        paramDict["map_city_id"] = cityId as AnyObject
        
        print(paramDict)
        
        Api.shared.requestToCancelSubcription(vC, paramDict) { [self] responseData in
            if responseData.status == "1" {
                self.requestSuccessfull?()
            } else {
                print(responseData.message ?? "")
            }
        }
    }
}
