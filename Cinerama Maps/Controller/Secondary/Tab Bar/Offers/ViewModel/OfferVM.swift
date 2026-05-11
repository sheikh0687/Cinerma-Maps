//
//  OfferViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 05/09/24.
//

import Foundation

class CompanyOfferViewModel {
    
    //    MARK: PROPERTIES
    var arrayOfOffers: [Res_Offers] = []
    var arrayFilteredCompanyOffer: [Res_Offers] = []

    var arrayOfMainOfferCat: [Res_MainOfferCategory] = []
    var arrayOfSubOfferCat: [Res_OfferSubCategory] = []
    var arrayOfChildOfferCat: [Res_OfferChildCategory] = []
    
    //    MARK: CLOSURES
    var fetchedSuccessfully:(() -> Void)?
    var cloMainOfferSuccessful:(() -> Void)?
    var cloSubOfferSuccessful:(() -> Void)?
    var cloChildOfferSuccessfull:(() -> Void)?
    
    var isLoading = true
    
    //    MARK: SEARCHBAR
    func setupSearchBar(searchBar: UISearchBar!) {
        searchBar.placeholder = R.string.localizable.search()
        searchBar.barTintColor = UIColor.white
        searchBar.searchTextField.backgroundColor = UIColor.white
        searchBar.searchTextField.textColor = UIColor.black
        
        if let clearButton = searchBar.searchTextField.value(forKey: "_clearButton") as? UIButton {
            clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        }
        
        searchBar.layer.cornerRadius = 10
        searchBar.layer.masksToBounds = true
    }
    
    func requestCompanyOffer(vC: UIViewController, catiD: String, subCatiD: String, childiD: String, tableView: UITableView) {
        
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject
        paramDict["cat_id"] = catiD as AnyObject
        paramDict["sub_cat_id"] = subCatiD as AnyObject
        paramDict["child_sub_cat_id"] = childiD as AnyObject
        
        print(paramDict)
        
        Api.shared.requestCompanyOffers(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayOfOffers = res
                        self.arrayFilteredCompanyOffer = res

                        tableView.backgroundView = UIView()
                        tableView.reloadData()
                    }
                }
            } else {
                self.arrayOfOffers = []
                self.arrayFilteredCompanyOffer = []

                tableView.backgroundView = UIView()
                tableView.reloadData()
                Utility.showNoDataView(R.string.localizable.noDataAvailable(), k.emptyString, in: tableView, parentViewController: vC, image: #imageLiteral(resourceName: "empty_notification"))
            }
            self.fetchedSuccessfully?()
        }
    }
    
    func fetchMainOfferCategory(vC: UIViewController, collectionVw: UICollectionView) {
        Api.shared.requestOffersCategory(vC) { [weak self] responseData in
            guard let self = self else { return }
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayOfMainOfferCat = res

                        collectionVw.backgroundView = UIView()
                        collectionVw.reloadData()
                    }
                }
            } else {
                self.arrayOfMainOfferCat = []

                collectionVw.isHidden = true
            }
            self.cloMainOfferSuccessful?()
        }
    }
    
    func requestSubOfferCategory(vC: UIViewController, catiD: String, collectionVw: UICollectionView) {
        
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject
        paramDict["cat_id"] = catiD as AnyObject
        
        print(paramDict)
        
        Api.shared.requestOffersSubCategory(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayOfSubOfferCat = res

                        collectionVw.backgroundView = UIView()
                        collectionVw.reloadData()
                    }
                }
            } else {
                self.arrayOfSubOfferCat = []

                collectionVw.isHidden = true
            }
            self.cloSubOfferSuccessful?()
        }
    }
    
    func requestChildOfferCategory(vC: UIViewController, catiD: String, subCatiD: String, collectionVw: UICollectionView) {
        
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject
        paramDict["cat_id"] = catiD as AnyObject
        paramDict["sub_cat_id"] = subCatiD as AnyObject
        
        print(paramDict)
        
        Api.shared.requestOffersChildCategory(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayOfChildOfferCat = res

                        collectionVw.backgroundView = UIView()
                        collectionVw.reloadData()
                    }
                }
            } else {
                self.arrayOfChildOfferCat = []

                collectionVw.isHidden = true
            }
            self.cloChildOfferSuccessfull?()
        }
    }
}
