//
//  NonSubscriberViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 31/07/25.
//

import Foundation

class NonSubscriberViewModel {
    
    var arrayOfNonSubscribeCat: [Res_NonSubsCategory] = []
    var cloMainCatSuccess: (() -> Void)?
    
    func requestToGetNonSubscribeCat(vC: UIViewController) {
        Api.shared.requestToNonSubscriberMainCategory(vC) { [weak self] response in
            guard let self = self else { return }
            
            if response.count > 0 {
                self.arrayOfNonSubscribeCat = response
            } else {
                self.arrayOfNonSubscribeCat = []
            }
            self.cloMainCatSuccess?()
        }
    }
    
    var arrayOfNonSubscribeSubCat: [Res_NonSubscribeSubCategory] = []
    var cloSubCatSuccess: (() -> Void)?
    
    func fetchNonSubscribeSubCat(catId: String, vC: UIViewController) {
        
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject
        paramDict["cat_id"] = catId as AnyObject
        
        Api.shared.requestToNonSubscriberSubCategory(vC, paramDict) { [weak self] response in
            guard let self = self else { return }
            
            if response.count > 0 {
                self.arrayOfNonSubscribeSubCat = response
            } else {
                self.arrayOfNonSubscribeSubCat = []
            }
            self.cloSubCatSuccess?()
        }
    }
    
    var arrayOfNonSubChildCat: [Res_NonSubChildCategory] = []
    var cloChildCatSuccess: (() -> Void)?
    
    func fetchNonSubscribeChildCat(subCatId: String,catiD: String, vC: UIViewController) {
        
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject
        paramDict["cat_id"] = catiD as AnyObject
        paramDict["sub_cat_id"] = subCatId as AnyObject
        
        print(paramDict)
        
        Api.shared.requestToNonSubscriberChildCategory(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            
            if responseData.count > 0 {
                self.arrayOfNonSubChildCat = responseData
            } else {
                self.arrayOfNonSubscribeCat = []
            }
            self.cloChildCatSuccess?()
        }
    }
    
    var arrayNonSubGuidelineTip: [Res_GuidelineTips] = []
    var cloNonSubGuidelineTipSuccess: (() -> Void)?
    
    func fetchNonSubscribeGuidelineTips(vC: UIViewController, catId: String, subCatId: String, childSubCatId: String)
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject
        paramDict["cat_id"] = catId as AnyObject
        paramDict["sub_cat_id"] = subCatId as AnyObject
        paramDict["child_sub_cat_id"] = childSubCatId as AnyObject
        
        print(paramDict)
        
        Api.shared.requestToGuidlineNonSubscribe(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            
            if responseData.count > 0 {
                self.arrayNonSubGuidelineTip = responseData
            } else {
                self.arrayNonSubGuidelineTip = []
            }
            self.cloNonSubGuidelineTipSuccess?()
        }
    }
}
