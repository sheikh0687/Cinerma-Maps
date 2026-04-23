//
//  ToursimViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 29/07/25.
//

import Foundation

class ToursimViewModel {
    
    var arrayTourismService: [Res_TourismService] = []
    var arrayOfFilteredTourismService: [Res_TourismService] = []
    
    var arrayToursimMainCat: [Res_ToursimCategory] = []
    var arrayTourismSubCat: [Res_TourismSubCategory] = []
    var arrayTourismChildCat: [Res_ToursimChildCategory] = []
 
    var cloTourismServiceSuccessfully:(() -> Void)?
    var cloTourismMainCatSuccessfully:(() -> Void)?
    var cloTourismSubCatSuccessfully:(() -> Void)?
    var cloTourismChildCatSuccessfully:(() -> Void)?
    
    //    MARK: TOURISM NETWORK MANAGMENT
    func fetchToursimServiceDetails(vC: UIViewController,catiD: String, subCatiD: String, childiD: String, tableVw: UITableView)
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        paramDict["cat_id"] = catiD as AnyObject
        paramDict["sub_cat_id"] = subCatiD as AnyObject
        paramDict["child_sub_cat_id"] = childiD as AnyObject
        
        print(paramDict)
        
        Api.shared.requestTourismServices(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayTourismService = res
                        self.arrayOfFilteredTourismService = res

                        tableVw.backgroundView = UIView()
                        tableVw.reloadData()
                    }
                }
            } else {
                self.arrayTourismService = []
                self.arrayOfFilteredTourismService = []

                tableVw.backgroundView = UIView()
                tableVw.reloadData()
                Utility.showNoDataView(R.string.localizable.noDataAvailable(), k.emptyString, in: tableVw, parentViewController: vC, image: #imageLiteral(resourceName: "empty_notification"))
            }

            self.cloTourismServiceSuccessfully?()
        }
    }
    
    func fetchTourismMainCategory(vC: UIViewController, collectionvW: UICollectionView)
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        
        print(paramDict)
        
        Api.shared.requestTourismMainCategory(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayToursimMainCat = res

                        collectionvW.backgroundView = UIView()
                        collectionvW.reloadData()
                    }
                }
            } else {
                self.arrayToursimMainCat = []

                collectionvW.isHidden = true
            }
            self.cloTourismMainCatSuccessfully?()
        }
    }
    
    func fetchTourismSubCategory(vC: UIViewController,_ catiD: String, collectionVw: UICollectionView)
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        paramDict["cat_id"] = catiD as AnyObject
        
        print(paramDict)
        
        Api.shared.requestTourismSubCategory(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayTourismSubCat = res
                        
                        collectionVw.backgroundView = UIView()
                        collectionVw.reloadData()
                    }
                }
            } else {
                self.arrayTourismSubCat = []

                collectionVw.isHidden = true
            }
            self.cloTourismSubCatSuccessfully?()
        }
    }
    
    func fetchTourismChildCategory(vC: UIViewController,_ catiD: String, subCatiD: String, collectionVw: UICollectionView)
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        paramDict["cat_id"] = catiD as AnyObject
        paramDict["sub_cat_id"] = subCatiD as AnyObject
        
        print(paramDict)
        
        Api.shared.requestTourismChildCategory(vC, paramDict) { [weak self] responseData in
            guard let self = self else {return}
            
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayTourismChildCat = res
                        
                        collectionVw.backgroundView = UIView()
                        collectionVw.reloadData()
                    }
                }
            } else {
                self.arrayTourismChildCat = []

                collectionVw.isHidden = true
            }
            self.cloTourismChildCatSuccessfully?()
        }
    }
}
