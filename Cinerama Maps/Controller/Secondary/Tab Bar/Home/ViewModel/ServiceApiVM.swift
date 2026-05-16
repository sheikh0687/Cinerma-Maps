//
//  ServiceApiViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 05/09/24.
//

import Foundation

class ServiceApiViewModel {
    
    var arrayOfServices: [Res_Services] = []
    var fetchedSuccesfully:(() -> Void)?
    var arrayOfImages: [String] = []
    
    //func requestToServices(vC: UIViewController,_ pageControl: UIPageControl) {
    //
    //    var paramDict: [String : AnyObject] = [:]
    //    paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
    //    paramDict["type"] = k.emptyString as AnyObject
    //
    //    print(paramDict)
    //
    //    Api.shared.requestAllServices(vC, paramDict) { responseData in
    //        if responseData.status == "1" {
    //            if let obj_Res = responseData.result {
    //                if obj_Res.count > 0 {
    //                    self.arrayOfServices = obj_Res
    //
    //                    if let image1 = obj_Res.first?.image1, Router.BASE_IMAGE_URL != image1 {
    //                        self.arrayOfImages.append(image1)
    //                    }
    //
    //                    if let image2 = obj_Res.first?.image2, Router.BASE_IMAGE_URL != image2 {
    //                        self.arrayOfImages.append(image2)
    //                    }
    //
    //                    if let image3 = obj_Res.first?.image3, Router.BASE_IMAGE_URL != image3 {
    //                        self.arrayOfImages.append(image3)
    //                    }
    //                } else {
    //                    self.arrayOfServices = []
    //                }
    //            }
    //        } else {
    //            pageControl.isHidden = true
    //        }
    //        self.fetchedSuccesfully?()
    //    }
    //}
}
