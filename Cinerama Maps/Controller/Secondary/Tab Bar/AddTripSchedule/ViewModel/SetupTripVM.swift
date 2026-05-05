//
//  SetupTripVM.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 14/11/24.
//

import Foundation
import DropDown

class SetupTripVM {
    
    var fethcedCityPurchaseMapSuccessfully:(() -> Void)?
    var fethcedAddMapNameSuccessfully:(() -> Void)?
    var arrayOfPurchasedCityMap: [Res_PurchasedCityMap] = []
    
    var dropDown = DropDown()
    
    var mapType:String = ""
    var mapTypeArabic:String = ""
    var mapName:String = ""
    
    var isCNRM: String = ""
    
    var countryId:String = ""
    var countryName:String = ""
    var countryNameAr:String = ""
    
    var placeiD: String = ""
    var isFrom:String = ""
    
    func configureDropDown(sender: UIButton)
    {
        var arrayOfMapName: [String] = []
        var arrayOfMapNameArbic: [String] = []
        var arrayofMapId: [String] = []
        
        var arrayCountryId: [String] = []
        var arrayCountryName: [String] = []
        var arrayCountryNameAr: [String] = []
        
        for val in arrayOfPurchasedCityMap {
            arrayOfMapName.append(val.name ?? "")
            arrayofMapId.append(val.id ?? "")
            arrayOfMapNameArbic.append(val.name_ar ?? "")
            
            arrayCountryId.append(val.country_details?.id ?? "")
            arrayCountryName.append(val.country_details?.name ?? "")
            arrayCountryNameAr.append(val.country_details?.name_ar ?? "")
        }
        
        dropDown.anchorView = sender
        dropDown.dataSource = arrayOfMapName
        dropDown.backgroundColor = .white
        dropDown.setupCornerRadius(8)
        dropDown.separatorColor = .systemBackground
        dropDown.bottomOffset = CGPoint(x: -5, y: 45)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            sender.setTitle(item, for: .normal)
            mapType = item
            placeiD = arrayofMapId[index]
            mapTypeArabic = arrayOfMapNameArbic[index]
            
            countryId = arrayCountryId[index]
            countryName = arrayCountryName[index]
            countryNameAr = arrayCountryNameAr[index]
        }
    }
    
    func fetchPurchaseCityMap(vC: UIViewController)
    {
        Api.shared.requestToPurchasedCityMap(vC) { responseData in
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayOfPurchasedCityMap = res
                    } else {
                        self.arrayOfPurchasedCityMap = []
                    }
                }
            }
            self.fethcedCityPurchaseMapSuccessfully?()
        }
    }
    
    var errorMessage: String? {
        didSet {
            self.showErrorMessage?()
        }
    }
    
    var showErrorMessage: (() -> Void)?
    
    func isValidUserInput() -> Bool
    {
        if mapType.isEmpty {
            errorMessage = R.string.localizable.pleaseSelectTheMapType()
            return false
        } else if mapName.isEmpty {
            errorMessage = R.string.localizable.pleaseEnterTheMapName()
            return false
        }
        return true
    }
    
    func addNewTrip(vC: UIViewController)
    {
        guard isValidUserInput() else { return }
        
        var paramDict: [String : AnyObject] = [:]
        if isFrom == "Place" {
            paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
            
            paramDict["map_name"] = mapName as AnyObject
            paramDict["map_type"] = mapType as AnyObject
            paramDict["map_type_ar"] = mapTypeArabic as AnyObject
            
            paramDict["country_id"] = countryId as AnyObject
            paramDict["country_name"] = countryName as AnyObject
            paramDict["country_name_ar"] = countryNameAr as AnyObject
            
            paramDict["place_id"] = placeiD as AnyObject
            paramDict["trip_by_cineramap"] = isCNRM as AnyObject
            
            paramDict["trip_name"] = k.emptyString as AnyObject

            paramDict["table_map_name"] = k.emptyString as AnyObject
            paramDict["trip_id"] = k.emptyString as AnyObject
            
            paramDict["trip_place_id"] = k.emptyString as AnyObject
            paramDict["map_place_id"] = k.emptyString as AnyObject
            
            paramDict["trip_name"] = k.emptyString as AnyObject
            paramDict["trip_name_ar"] = k.emptyString as AnyObject
            
            paramDict["day_id"] = k.emptyString as AnyObject
            paramDict["day_name"] = k.emptyString as AnyObject
            paramDict["day_name_ar"] = k.emptyString as AnyObject
            
            paramDict["address"] = k.emptyString as AnyObject
            
            paramDict["lat"] = k.emptyString as AnyObject
            paramDict["lon"] = k.emptyString as AnyObject
            
            paramDict["how_much_day"] = k.emptyString as AnyObject
            
        } else {
            paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
            paramDict["trip_name"] = k.emptyString as AnyObject
            
            paramDict["map_type"] = mapType as AnyObject
            paramDict["map_type_ar"] = mapTypeArabic as AnyObject
            paramDict["map_name"] = mapName as AnyObject
            
            paramDict["table_map_name"] = k.emptyString as AnyObject
            paramDict["trip_id"] = k.emptyString as AnyObject
            
            paramDict["country_id"] = countryId as AnyObject
            paramDict["country_name"] = countryName as AnyObject
            paramDict["country_name_ar"] = countryNameAr as AnyObject
            
            paramDict["trip_place_id"] = k.emptyString as AnyObject
            paramDict["map_place_id"] = k.emptyString as AnyObject
            
            paramDict["place_id"] = self.placeiD as AnyObject
            
            paramDict["trip_name"] = k.emptyString as AnyObject
            paramDict["trip_name_ar"] = k.emptyString as AnyObject
            
            paramDict["day_id"] = k.emptyString as AnyObject
            paramDict["day_name"] = k.emptyString as AnyObject
            paramDict["day_name_ar"] = k.emptyString as AnyObject
            
            paramDict["address"] = k.emptyString as AnyObject
            
            paramDict["lat"] = k.emptyString as AnyObject
            paramDict["lon"] = k.emptyString as AnyObject
            
            paramDict["how_much_day"] = k.emptyString as AnyObject
            
            paramDict["trip_by_cineramap"] = isCNRM as AnyObject
        }
        
        print(paramDict)
        
        Api.shared.requestToAddScheduleTrip(vC, paramDict) { [self] responseData in
            self.fethcedAddMapNameSuccessfully?()
        }
    }
}
