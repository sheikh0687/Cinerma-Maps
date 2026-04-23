//
//  PartnerViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 29/07/25.
//

import Foundation

class PartnerViewModel {
    
    //    MARK: PROPERTIES
    var arrayPartnerService: [Res_PartnerService] = []
    var arrayFilteredPartnerService: [Res_PartnerService] = []
    
    var arrayOfPartnerMainCategory: [Res_PartnerMainCategory] = []
    var arrayOfPartnerSubCategory: [Res_PartnerSubCategory] = []
    var arrayOfPartnerChildCategory: [Res_PartnerChildCategory] = []
    
    //    MARK: CLOSURES
    var fetchedPartnerServiceSuccessfully:(() -> Void)?
    var cloPartnerMainCatSuccessful:(() -> Void)?
    var cloPartnerSubCatSuccessful:(() -> Void)?
    var cloPartnerChildCatSuccessfull:(() -> Void)?
    
    func fetchPartnerServiceDetails(vC: UIViewController,catiD: String, subCatiD: String, childiD: String, tableVw: UITableView)
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        paramDict["cat_id"] = catiD as AnyObject
        paramDict["sub_cat_id"] = subCatiD as AnyObject
        paramDict["child_sub_cat_id"] = childiD as AnyObject
        
        print(paramDict)
        
        Api.shared.requestPartnerServices(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayPartnerService = res
                        self.arrayFilteredPartnerService = res
                        
                        tableVw.backgroundView = UIView()
                        tableVw.reloadData()
                    }
                }
            } else {
                self.arrayPartnerService = []
                self.arrayFilteredPartnerService = []
                
                tableVw.backgroundView = UIView()
                tableVw.reloadData()
                Utility.showNoDataView(R.string.localizable.noDataAvailable(), k.emptyString, in: tableVw, parentViewController: vC, image: #imageLiteral(resourceName: "empty_notification"))
            }
            self.fetchedPartnerServiceSuccessfully?()
        }
    }
    
    func fetchPartnerMainCategory(vC: UIViewController, collectionVw: UICollectionView)
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        
        print(paramDict)
        
        Api.shared.requestPartnerMainCategory(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayOfPartnerMainCategory = res
                        
                        collectionVw.backgroundView = UIView()
                        collectionVw.reloadData()
                    }
                }
            } else {
                self.arrayOfPartnerMainCategory = []
                
                collectionVw.isHidden = true
            }
            self.cloPartnerMainCatSuccessful?()
        }
    }
    
    func fetchPartnerSubCategory(vC: UIViewController,_ catiD: String, collectionVw: UICollectionView)
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        paramDict["cat_id"] = catiD as AnyObject
        
        print(paramDict)
        
        Api.shared.requestPartnerSubCategory(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayOfPartnerSubCategory = res
                        
                        collectionVw.backgroundView = UIView()
                        collectionVw.reloadData()
                    }
                }
            } else {
                self.arrayOfPartnerSubCategory = []
                
                collectionVw.isHidden = true
            }
             self.cloPartnerSubCatSuccessful?()
        }
    }
    
    func fetchPartnerChildCategory(vC: UIViewController,_ catiD: String, subCatiD: String, collectionVw: UICollectionView)
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        paramDict["cat_id"] = catiD as AnyObject
        paramDict["sub_cat_id"] = subCatiD as AnyObject
        
        print(paramDict)
        
        Api.shared.requestPartnerChildCategory(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayOfPartnerChildCategory = res
                        
                        collectionVw.backgroundView = UIView()
                        collectionVw.reloadData()
                    }
                }
            } else {
                self.arrayOfPartnerChildCategory = []
                
                collectionVw.isHidden = true
            }
            self.cloPartnerChildCatSuccessfull?()
        }
    }
}
