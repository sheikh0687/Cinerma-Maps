//
//  SubscriberViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 01/08/25.
//

import Foundation
import DropDown

class SubscriberViewModel {
    
    var arrayUserSubscriber: [Res_UserSubscriberCity] = []
    var cloUserSubscribeSuccess: ((String) -> Void)?
    
    var dropDown = DropDown()
    var selectedCityName:String!
    var cityiD:String = ""
    
    func fetchuserSubscriberCity(vC: UIViewController, sender: UIButton, cityName: UILabel) {
        Api.shared.requestToUserSubscriberCity(vC) { [weak self] responseData in
            guard let self = self else { return }
         
            if responseData.count > 0 {
                self.arrayUserSubscriber = responseData
            } else {
                self.arrayUserSubscriber = []
            }
            
            configureDropDown(sender: sender, lblCityName: cityName, vC: vC)
        }
    }
    
    func configureDropDown(sender: UIButton, lblCityName: UILabel, vC: UIViewController)
    {
        var arrayOfCityName: [String] = []
        var arrayOfCityArbic: [String] = []
        var arrayofCityId: [String] = []
            
        arrayOfCityName.insert("Choose City", at: 0)
        arrayOfCityArbic.insert("اختر المدينة", at: 0)
        arrayofCityId.insert("", at: 0) // optional: to maintain index alignment

        for val in arrayUserSubscriber {
            arrayOfCityName.append(val.name ?? "")
            arrayofCityId.append(val.id ?? "")
            arrayOfCityArbic.append(val.name_ar ?? "")
        }
        
        dropDown.anchorView = sender
        dropDown.dataSource = L102Language.currentAppleLanguage() == "en" ? arrayOfCityName : arrayOfCityArbic
        dropDown.backgroundColor = .white
        dropDown.setupCornerRadius(8)
        dropDown.separatorColor = .systemBackground
        dropDown.bottomOffset = L102Language.currentAppleLanguage() == "en" ? CGPoint(x: -60, y: 40) : CGPoint(x: 280, y: 40)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            lblCityName.text = item
            self.cityiD = arrayofCityId[index]
            cloUserSubscribeSuccess?(item)
        }
    }

    var arrayOfSubscriberCat: [Res_SubscriberCategory] = []
    var cloMainCatSuccess: (() -> Void)?
    
    func requestToGetSubscriberCat(vC: UIViewController, strCity: String, collectionVw: UICollectionView) {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject
        paramDict["city_id"] = cityiD as AnyObject
        
        print(paramDict)
        
        Api.shared.requestToSubscriberMainCategory(vC, paramDict ) { [weak self] response in
            guard let self = self else { return }
            if response.status == "1" {
                if let res = response.result {
                    if res.count > 0 {
                        self.arrayOfSubscriberCat = res

                        collectionVw.backgroundView = UIView()
                        collectionVw.reloadData()
                        collectionVw.isHidden = false
                    }
                }
            } else {
                self.arrayOfSubscriberCat = []
                collectionVw.isHidden = true
            }
            self.cloMainCatSuccess?()
        }
    }
    
    var arrayOfSubscribeSubCat: [Res_SubscriberSubCategory] = []
    var cloSubCatSuccess: (() -> Void)?
    
    func fetchSubscriberSubCat(catId: String, vC: UIViewController, collectionVw: UICollectionView) {
        
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject
        paramDict["cat_id"] = catId as AnyObject
        
        print(paramDict)
        
        Api.shared.requestToSubscriberSubCategory(vC, paramDict) { [weak self] response in
            guard let self = self else { return }
            if response.status == "1" {
                if let res = response.result {
                    if res.count > 0 {
                        self.arrayOfSubscribeSubCat = res

                        collectionVw.backgroundView = UIView()
                        collectionVw.reloadData()
                        collectionVw.isHidden = false
                    }
                }
            } else {
                self.arrayOfSubscribeSubCat = []
                collectionVw.isHidden = true
            }
            self.cloSubCatSuccess?()
        }
    }
    
    var arrayOfSubChildCat: [Res_SubscriberChildCategory] = []
    var cloChildCatSuccess: (() -> Void)?
    
    func fetchSubscriberChildCat(subCatId: String,catiD: String, vC: UIViewController, collectionVw: UICollectionView) {
        
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject
        paramDict["cat_id"] = catiD as AnyObject
        paramDict["sub_cat_id"] = subCatId as AnyObject
        
        print(paramDict)
        
        Api.shared.requestToSubscriberChildCategory(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayOfSubChildCat = res

                        collectionVw.backgroundView = UIView()
                        collectionVw.reloadData()
                        collectionVw.isHidden = false
                    }
                }
            } else {
                self.arrayOfSubChildCat = []
                collectionVw.isHidden = true
            }
            self.cloChildCatSuccess?()
        }
    }
    
    var arrayGuidelinesTip: [Res_GuidelineTips] = []
    var arrayFilteredGuidelinesTip: [Res_GuidelineTips] = []
    
    var fethcedSuccessfully:(() -> Void)?

    func fetchGuidelineTips(vC: UIViewController, catId: String, subCatId: String, childSubCatId: String,_ collectionVw: UICollectionView)
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject
        paramDict["cat_id"] = catId as AnyObject
        paramDict["sub_cat_id"] = subCatId as AnyObject
        paramDict["child_sub_cat_id"] = childSubCatId as AnyObject
        paramDict["city_id"] = cityiD as AnyObject
        
        print(paramDict)
        
        Api.shared.requestGuidelineTips(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayGuidelinesTip = res
                        self.arrayFilteredGuidelinesTip = res

                        collectionVw.backgroundView = UIView()
                        collectionVw.reloadData()
                    }
                }
            } else {
                self.arrayGuidelinesTip = []
                self.arrayFilteredGuidelinesTip = []
                
                collectionVw.backgroundView = UIView()
                collectionVw.reloadData()
                Utility.showNoDataView(R.string.localizable.noDataAvailable(), k.emptyString, in: collectionVw, parentViewController: vC, image: #imageLiteral(resourceName: "empty_notification"))
            }
            self.fethcedSuccessfully?()
        }
    }
}
