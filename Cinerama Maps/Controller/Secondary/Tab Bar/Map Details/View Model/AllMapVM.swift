//
//  AllMapViewMode.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 05/09/24.
//

import Foundation

class AllMapViewModel {
    
    var arrayOfDetailCityMaps: Res_CityPlaceDetails!
    var arrayOfReviews: [Rating_review] = []
    var arrayOfPlaceImg: [Places_images] = []
    var arrayOfCityImages: [Res_CityImages] = []
    var arrayOfCityTag: [Tag_details] = []
    
    var fetchedSuccessfully:(() -> Void)?
    var fetchedImagesSuccess: (() -> Void)?
    
    var cityId: String = ""
    
    func navigateToSubcribeViewController(from navigationController: UINavigationController?, mapiD:String, type: String, durationVal: String, amountVal: String,amountValInUSD:String) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
        vC.viewModel.countryMapiD = mapiD
        vC.viewModel.countryCityiD = cityId
        
        vC.typeVal = type
        vC.duration = durationVal
        vC.totalPaidAmount = Double(amountVal) ?? 0.0
        vC.totalPaidAmountInUSD = Double(amountValInUSD) ?? 0.0
        navigationController?.pushViewController(vC, animated: true)
    }
    
    func returnBackk(from navigationController: UINavigationController?) {
        navigationController?.popViewController(animated: true)
    }
    
    func requestCountryMapDetails(vC: UIViewController, tagHeight: NSLayoutConstraint, collectionVw: UICollectionView) {
        var param: [String : AnyObject] = [:]
        param["city_id"] = cityId as AnyObject
        
        print(param)
        
        Api.shared.requestCityPlaceDt(vC, param) { responseData in
            
            self.arrayOfDetailCityMaps = responseData
            
            if let obj_RatingReview = responseData.rating_review {
                if obj_RatingReview.count > 0 {
                    self.arrayOfReviews = obj_RatingReview
                } else {
                    self.arrayOfReviews = []
                }
            }
            
            if let obj_PlaceImage = responseData.places_images {
                if obj_PlaceImage.count > 0 {
                    self.arrayOfPlaceImg = obj_PlaceImage
                } else {
                    self.arrayOfPlaceImg = []
                }
            }

            
            if let obj_TagDetails = responseData.tags {
                if obj_TagDetails.count > 0 {
                    self.arrayOfCityTag = obj_TagDetails
                    let numberOfItemsInRow = 3
                    let _ = (obj_TagDetails.count + numberOfItemsInRow - 1) / numberOfItemsInRow
                    var totalHeight: CGFloat = 0
                    
                    // Calculate total height based on text in each cell
                    for index in 0..<obj_TagDetails.count {
                        let obj = obj_TagDetails[index]
                        let labelText = "\(obj.total_tag_place_count ?? "") \(obj.tag_name ?? "")"
                        let font = UIFont.systemFont(ofSize: 14) // Adjust as needed
                        let maxWidth = collectionVw.bounds.width / 3 - 10 // Space for 3 items in a row with padding
                        
                        let labelSize = labelText.boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                                                               options: .usesLineFragmentOrigin,
                                                               attributes: [.font: font],
                                                               context: nil).size
                        
                        totalHeight += labelSize.height + 10 // Add extra space for padding
                    }
                    
                    // Update the height constraint for the collection view
                    tagHeight.constant = totalHeight
                } else {
                    self.arrayOfCityTag = []
                }
            }
            
            self.fetchedSuccessfully?()
        }
    }
    
    func fetchCityImages(vC: UIViewController) {
        var paramDict: [String : AnyObject] = [:]
        paramDict["city_id"] = cityId as AnyObject
        
        print(paramDict)
        
        Api.shared.requestToCityImages(vC, paramDict) { responseData in
            if responseData.count > 0 {
                self.arrayOfCityImages = responseData
            } else {
                self.arrayOfCityImages = []
            }
            self.fetchedImagesSuccess?()
        }
    }
    
    func fetchFavAndUnFavMap(vC: UIViewController) {
        var param: [String : AnyObject] = [:]
        param["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        param["city_id"] = cityId as AnyObject
        
        print(param)
        
        Api.shared.requestToSelectFavUnFavCityMap(vC, param) { responseData in
            if responseData.status == "1" {
                self.fetchedSuccessfully?()
            } else {
                print(responseData.message ?? "")
            }
        }
    }
}
