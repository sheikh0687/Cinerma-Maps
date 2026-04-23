//
//  Api.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 02/09/24.
//

import Foundation
import Alamofire
import SwiftyJSON

class Api: NSObject {
    
    static let shared = Api()
    
    
    func paramGetUserId() -> [String : AnyObject]
    {
        var dict: [String : AnyObject] = [:]
        dict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject
        //        dict["city_id"] = "" as AnyObject
        //        dict["country_id"] = "" as AnyObject
        //        dict["token"] = "" as AnyObject
        print(dict)
        return dict
    }
    
    func requestOtpToVerifyNum(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Api_SendOtp) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.send_otp_mail.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_SendOtp.self, from: response)
                if root.result != nil {
                    success(root)
                } else {
                    k.userDefault.set(false, forKey: k.session.status)
                    k.userDefault.set(k.emptyString, forKey: k.session.userId)
                    k.userDefault.set(k.emptyString, forKey: k.session.userEmail)
                }
                vC.hideProgressBar()
            } catch {
                print(error)
                
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func signup(_ vc: UIViewController, _ params: [String: String], images: [String : UIImage?]?, videos: [String : Data?]?, _ success: @escaping(_ responseData : Res_Signup) -> Void) {
        vc.showProgressBar()
        Service.postSingleMedia(url: Router.signup.url(), params: params, imageParam: images, videoParam: videos, parentViewController: vc, successBlock: { (responseData) in
            do {
                let decoder = JSONDecoder()
                let root = try decoder.decode(Api_Signup.self, from: responseData)
                if root.status == "1" {
                    vc.hideProgressBar()
                    if let result = root.result {
                        success(result)
                        vc.hideProgressBar()
                    }
                } else {
                    vc.hideProgressBar()
                    vc.alert(alertmessage: root.message ?? "Something went wrong")
                }
            } catch {
                print(error)
                vc.hideProgressBar()
            }
            vc.hideProgressBar()
        }) { (error: Error) in
            vc.alert(alertmessage: error.localizedDescription)
            vc.hideProgressBar()
        }
    }
    
    func updateUserProfile(_ vc: UIViewController, _ params: [String: String], images: [String : UIImage?]?, videos: [String : Data?]?, _ success: @escaping(_ responseData : Res_Signup) -> Void) {
        vc.showProgressBar()
        Service.postSingleMedia(url: Router.update_profile.url(), params: params, imageParam: images, videoParam: videos, parentViewController: vc, successBlock: { (responseData) in
            do {
                let decoder = JSONDecoder()
                let root = try decoder.decode(Api_Signup.self, from: responseData)
                if root.status == "1" {
                    vc.hideProgressBar()
                    if let result = root.result {
                        success(result)
                    }
                }
            } catch {
                print(error)
                vc.hideProgressBar()
            }
            vc.hideProgressBar()
        }) { (error: Error) in
            vc.alert(alertmessage: error.localizedDescription)
            vc.hideProgressBar()
        }
    }
    
    //    func requestToSocialLogin(_ vc: UIViewController, _ params: [String: String], images: [String : UIImage?]?, videos: [String : Data?]?, _ success: @escaping(_ responseData : Res_Signup) -> Void) {
    //        vc.showProgressBar()
    //        Service.postSingleMedia(url: Router.social_login.url(), params: params, imageParam: images, videoParam: videos, parentViewController: vc, successBlock: { (responseData) in
    //            do {
    //                let decoder = JSONDecoder()
    //                let root = try decoder.decode(Api_Signup.self, from: responseData)
    //                if root.status == "1" {
    //                    vc.hideProgressBar()
    //                    if let result = root.result {
    //                        success(result)
    //                    }
    //                } else {
    //                    vc.hideProgressBar()
    //                    vc.alert(alertmessage: root.message ?? "Something went wrong")
    //                }
    //            } catch {
    //                vc.hideProgressBar()
    //                print(error)
    //            }
    //            vc.hideProgressBar()
    //        }) { (error: Error) in
    //            vc.alert(alertmessage: error.localizedDescription)
    //            vc.hideProgressBar()
    //        }
    //    }
    
    //    func requestUserProfile(_ vC: UIViewController,_ success: @escaping(_ responseData: Res_UserProfile) -> Void) {
    //        vC.showProgressBar()
    //        Service.post(url: Router.get_profile.url(), params: paramGetUserId(), method: .get, vc: vC, successBlock: { (response) in
    //            do {
    //                let jsonDecoder = JSONDecoder()
    //                let root = try jsonDecoder.decode(Api_UserProfile.self, from: response)
    //                if root.status == "1" {
    //                    if let result = root.result {
    //                        success(result)
    //                        vC.hideProgressBar()
    //                    }
    //                } else {
    //                    print(root.message ?? "")
    //                    vC.hideProgressBar()
    //                }
    //            } catch {
    //                print(error)
    //                vC.hideProgressBar()
    //            }
    //        }) { (error: Error) in
    //            vC.alert(alertmessage: error.localizedDescription)
    //            vC.hideProgressBar()
    //        }
    //    }
    
    func requestUserProfile(_ vC: UIViewController,_ success: @escaping(_ responseData: Res_UserProfile) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.get_profile.url(), params: paramGetUserId(), method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_UserProfile.self, from: response)
                    DispatchQueue.main.async {
                        if root.status == "1" {
                            if let result = root.result {
                                success(result)
                            }
                        } else {
                            vC.alert(alertmessage: root.message ?? "")
                        }
                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                vC.hideProgressBar()
            }
        })
    }
    
    func requestToSocialLogin(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Res_Signup) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.social_login.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_Signup.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestCountryMap(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: [Res_CountryMap]) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.get_country_map.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_CountryMap.self, from: response)
                    DispatchQueue.main.async {
                        if root.status == "1" {
                            if let result = root.result {
                                success(result)
                            }
                        } else {
                            print(root.message ?? "")
                        }
                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                vC.hideProgressBar()
            }
        })
    }
    
    //    func requestCityMap(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: [Res_CityMap]) -> Void) {
    //        vC.showProgressBar()
    //        Service.post(url: Router.get_country_map_city.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
    //            do {
    //                let jsonDecoder = JSONDecoder()
    //                let root = try jsonDecoder.decode(Api_CityMaps.self, from: response)
    //                if root.status == "1" {
    //                    if let result = root.result {
    //                        success(result)
    //                        vC.hideProgressBar()
    //                    }
    //                } else {
    //                    print(vC.alert(alertmessage: "No data Available"))
    //                    vC.hideProgressBar()
    //                }
    //            } catch {
    //                print(error)
    //                vC.hideProgressBar()
    //            }
    //        }) { (error: Error) in
    //            vC.alert(alertmessage: error.localizedDescription)
    //            vC.hideProgressBar()
    //        }
    //    }
    //
    //    func requestGuidelineTips(_ vC: UIViewController,_ success: @escaping(_ responseData: [Res_GuidelineTips]) -> Void) {
    //        vC.showProgressBar()
    //        Service.post(url: Router.get_guidelines_tips.url(), params: paramGetUserId(), method: .get, vc: vC, successBlock: { (response) in
    //            do {
    //                let jsonDecoder = JSONDecoder()
    //                let root = try jsonDecoder.decode(Api_GuidelinesTips.self, from: response)
    //                if root.status == "1" {
    //                    if let result = root.result {
    //                        success(result)
    //                        vC.hideProgressBar()
    //                    }
    //                } else {
    //                    vC.hideProgressBar()
    //                    print(root.message ?? "")
    //                }
    //            } catch {
    //                print(error)
    //                vC.hideProgressBar()
    //            }
    //        }) { (error: Error) in
    //            vC.alert(alertmessage: error.localizedDescription)
    //            vC.hideProgressBar()
    //        }
    //    }
    
    func requestCityMap(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: [Res_CityMap]) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.get_country_map_city.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_CityMaps.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    print(vC.alert(alertmessage: R.string.localizable.noDataAvailable()))
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestGuidelineTips(_ vC: UIViewController,_ paramDict: [String : AnyObject],_ success: @escaping(_ responseData: Api_GuidelinesTips) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_guidelines_tips_new.url(), params: paramDict, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_GuidelinesTips.self, from: response)
                    DispatchQueue.main.async {
                        if root.result != nil {
                            success(root)
                        } else {
                            print(root.message ?? "")
                        }
                        //                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        //                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                //                vC.hideProgressBar()
            }
        })
    }
    
    func requestTourismServices(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Api_ToursimService) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.get_tourism_services.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_ToursimService.self, from: response)
                    DispatchQueue.main.async {
                        if root.result != nil {
                            success(root)
                        } else {
                            print(root.message ?? "")
                        }
                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                vC.hideProgressBar()
            }
        })
    }
    
    func requestTourismMainCategory(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Api_ToursimCategory) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_tourism_services_category.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_ToursimCategory.self, from: response)
                    DispatchQueue.main.async {
                        if root.result != nil {
                            success(root)
                        } else {
                            print(root.message ?? "")
                        }
                        //                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        //                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                //                vC.hideProgressBar()
            }
        })
    }
    
    func requestTourismSubCategory(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Api_TourismSubCategory) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_tourism_services_sub_category.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_TourismSubCategory.self, from: response)
                    DispatchQueue.main.async {
                        if root.result != nil {
                            success(root)
                        } else {
                            print(root.message ?? "")
                        }
                        //                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        //                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                //                vC.hideProgressBar()
            }
        })
    }
    
    func requestTourismChildCategory(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Api_ToursimChildCategory) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_tourism_services_child_sub_category.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_ToursimChildCategory.self, from: response)
                    DispatchQueue.main.async {
                        if root.result != nil {
                            success(root)
                        } else {
                            print(root.message ?? "")
                        }
                        //                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        //                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                //                vC.hideProgressBar()
            }
        })
    }
    
    func requestPartnerServices(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Api_PartnerService) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.get_partner_services.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_PartnerService.self, from: response)
                    DispatchQueue.main.async {
                        if root.result != nil {
                            success(root)
                        } else {
                            print(root.message ?? "")
                        }
                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                vC.hideProgressBar()
            }
        })
    }
    
    func requestPartnerMainCategory(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Api_PartnerMainCategory) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_partner_services_category.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_PartnerMainCategory.self, from: response)
                    DispatchQueue.main.async {
                        if root.result != nil {
                            success(root)
                        } else {
                            print(root.message ?? "")
                        }
                        //                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        //                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                //                vC.hideProgressBar()
            }
        })
    }
    
    func requestPartnerSubCategory(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Api_PartnerSubCategory) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_partner_services_sub_category.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_PartnerSubCategory.self, from: response)
                    DispatchQueue.main.async {
                        if root.result != nil {
                            success(root)
                        } else {
                            print(root.message ?? "")
                        }
                        //                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        //                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                //                vC.hideProgressBar()
            }
        })
    }
    
    func requestPartnerChildCategory(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Api_PartnerChildCategory) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_partner_services_child_sub_category.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_PartnerChildCategory.self, from: response)
                    DispatchQueue.main.async {
                        if root.result != nil {
                            success(root)
                        } else {
                            print(root.message ?? "")
                        }
                        //                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        //                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                //                vC.hideProgressBar()
            }
        })
    }
    
    func requestCompanyOffers(_ vC: UIViewController,_ paramDict: [String : AnyObject],_ success: @escaping(_ responseData: ApiAllOffers) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.get_company_offer.url(), params: paramDict, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(ApiAllOffers.self, from: response)
                if root.result != nil {
                    success(root)
                } else {
                    print("No Data Available to show!!")
                }
                vC.hideProgressBar()
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToSubscriberMainCategory(_ vC: UIViewController,_ paramDict: [String : AnyObject],_ success: @escaping(_ responseData: Api_SubscriberCategory) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_category_behalf_city.url(), params: paramDict, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_SubscriberCategory.self, from: response)
                    DispatchQueue.main.async {
                        if root.result != nil {
                            success(root)
                        } else {
                            print(root.message ?? "")
                        }
                        //                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        //                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                //                vC.hideProgressBar()
            }
        })
    }
    
    func requestToSubscriberSubCategory(_ vC: UIViewController,_ paramDict: [String : AnyObject],_ success: @escaping(_ responseData: Api_SubscriberSubCategory) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_guidelines_tips_sub_category.url(), params: paramDict, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_SubscriberSubCategory.self, from: response)
                    DispatchQueue.main.async {
                        if root.result != nil {
                            success(root)
                        } else {
                            print(root.message ?? "")
                        }
                        //                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        //                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                //                vC.hideProgressBar()
            }
        })
    }
    
    func requestToSubscriberChildCategory(_ vC: UIViewController,_ paramDict: [String : AnyObject],_ success: @escaping(_ responseData: Api_SubscriberChildCategory) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_guidelines_tips_child_sub_category.url(), params: paramDict, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_SubscriberChildCategory.self, from: response)
                    DispatchQueue.main.async {
                        if root.result != nil {
                            success(root)
                        } else {
                            print(root.message ?? "")
                        }
                        //                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        //                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                //                vC.hideProgressBar()
            }
        })
    }
    
    func requestToNonSubscriberMainCategory(_ vC: UIViewController,_ success: @escaping(_ responseData: [Res_NonSubsCategory]) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_guidelines_tips_category_NonSubcriber.url(), params: paramGetUserId(), method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_NonSubsCategory.self, from: response)
                    DispatchQueue.main.async {
                        if root.status == "1" {
                            if let result = root.result {
                                success(result)
                            }
                        } else {
                            print(root.message ?? "")
                        }
                        //                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        //                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                //                vC.hideProgressBar()
            }
        })
    }
    
    func requestToNonSubscriberSubCategory(_ vC: UIViewController,_ paramDict: [String : AnyObject],_ success: @escaping(_ responseData: [Res_NonSubscribeSubCategory]) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_guidelines_tips_sub_category_NonSubcriber.url(), params: paramDict, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_NonSubscriveSubCategory.self, from: response)
                    DispatchQueue.main.async {
                        if root.status == "1" {
                            if let result = root.result {
                                success(result)
                            }
                        } else {
                            print(root.message ?? "")
                        }
                        //                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        //                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                //                vC.hideProgressBar()
            }
        })
    }
    
    func requestToNonSubscriberChildCategory(_ vC: UIViewController,_ paramDict: [String : AnyObject],_ success: @escaping(_ responseData: [Res_NonSubChildCategory]) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_guidelines_tips_child_sub_category_NonSubcriber.url(), params: paramDict, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_NonSubChildCategory.self, from: response)
                    DispatchQueue.main.async {
                        if root.status == "1" {
                            if let result = root.result {
                                success(result)
                            }
                        } else {
                            print(root.message ?? "")
                        }
                        //                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        //                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                //                vC.hideProgressBar()
            }
        })
    }
    
    func requestToGuidlineNonSubscribe(_ vC: UIViewController? = nil,_ param: [String : AnyObject],_ success: @escaping(_ responseData: [Res_GuidelineTips]) -> Void) {
        vC?.showProgressBar()
        Service.post(url: Router.get_guidelines_tips_new_NonSubcriber.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_GuidelinesTips.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC?.hideProgressBar()
                    }
                } else {
                    print("No Data Available to show!!")
                    vC?.hideProgressBar()
                }
            } catch {
                print(error)
                vC?.hideProgressBar()
            }
        }) { (error: Error) in
            vC?.alert(alertmessage: error.localizedDescription)
            vC?.hideProgressBar()
        }
    }
    
    func requestToUserSubscriberCity(_ vC: UIViewController,_ success: @escaping(_ responseData: [Res_UserSubscriberCity]) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_user_subcriber_city.url(), params: paramGetUserId(), method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_UserSubscriberCity.self, from: response)
                    DispatchQueue.main.async {
                        if root.status == "1" {
                            if let result = root.result {
                                success(result)
                            }
                        } else {
                            print(root.message ?? "")
                        }
                        //                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        //                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                //                vC.hideProgressBar()
            }
        })
    }
    
    func requestOffersCategory(_ vC: UIViewController,_ success: @escaping(_ responseData: ApiMainOfferCategory) -> Void) {
        Service.post(url: Router.get_offer_category.url(), params: paramGetUserId(), method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(ApiMainOfferCategory.self, from: response)
                if root.result != nil {
                    success(root)
                } else {
                    print("No Data Available to show!!")
                }
            } catch {
                print(error)
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
        }
    }
    
    func requestOffersSubCategory(_ vC: UIViewController,_ paramDict: [String : AnyObject],_ success: @escaping(_ responseData: ApiOfferSubCategory) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_offer_sub_category.url(), params: paramDict, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(ApiOfferSubCategory.self, from: response)
                if root.result != nil {
                    success(root)
                } else {
                    print("No Data Available to show!!")
                    //                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                //                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            //            vC.hideProgressBar()
        }
    }
    
    func requestOffersChildCategory(_ vC: UIViewController,_ paramDict: [String : AnyObject],_ success: @escaping(_ responseData: Api_OfferChildCategory) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_offer_child_sub_category.url(), params: paramDict, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_OfferChildCategory.self, from: response)
                if root.result != nil {
                    success(root)
                } else {
                    print("No Data Available to show!!")
                    //                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                //                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            //            vC.hideProgressBar()
        }
    }
    
    func requestCityPlaceDt(_ vC: UIViewController?,_ param: [String : AnyObject],progress: Bool = true,_ success: @escaping(_ responseData: Res_CityPlaceDetails) -> Void) {
        if progress{vC?.showProgressBar()}
        Service.post(url: Router.get_country_map_city_places_new.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_CityPlaceDetails.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC?.hideProgressBar()
                    }
                } else {
                    print("No Data Available to show!!")
                    vC?.hideProgressBar()
                }
            } catch {
                print(error)
                vC?.hideProgressBar()
            }
        }) { (error: Error) in
            vC?.alert(alertmessage: error.localizedDescription)
            vC?.hideProgressBar()
        }
    }
    
    func requestScheduleTrip(_ vC: UIViewController,_ success: @escaping(_ responseData: [Res_ScheduleTrip]) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_user_trip_schedule.url(), params: paramGetUserId(), method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_ScheduleTrip.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    print("No Data Available to show!!")
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToAddToFavorite(_ vC: UIViewController?, placeId: String, progress: Bool = true, success: @escaping(_ responseData: Api_BasicModel) -> Void) {
        if progress{vC?.showProgressBar()}
        var params: [String: AnyObject] = [:]
        params["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject
        params["place_id"] = placeId as AnyObject
        
        Service.post(url: Router.add_to_favorite.url(), params: params, method: .post, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_BasicModel.self, from: response)
                if root.result != nil {
                    success(root)
                } else {
                    vC?.alert(alertmessage: root.message ?? "Failed to add to favorites")
                }
                vC?.hideProgressBar()
            } catch {
                print(error)
                vC?.hideProgressBar()
                vC?.alert(alertmessage: "Failed to process response")
            }
        }) { (error: Error) in
            vC?.alert(alertmessage: error.localizedDescription)
            vC?.hideProgressBar()
        }
    }
    
    func requestDetailsScheduleTrip(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Res_DetailScheduleTrip) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_user_trip_schedule_details.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_DetailScheduleTrip.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    print("No Data Available to show!!")
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToSelectFavUnFavCityMap(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Api_BasicModel) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.fav_unfav_citymap.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_BasicModel.self, from: response)
                if root.result != nil {
                    success(root)
                } else {
                    print("No Data Available to show!!")
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToSelectFavUnFavPlace(_ vC: UIViewController?,_ param: [String : AnyObject], progress: Bool = true,_ success: @escaping(_ responseData: Api_BasicModel) -> Void) {
        if progress{vC?.showProgressBar()}
        Service.post(url: Router.fav_unfav_place.url(), params: param, method: .get, vc: vC != nil ? vC : nil, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_BasicModel.self, from: response)
                if root.result != nil {
                    success(root)
                } else {
                    print("No Data Available to show!!")
                    vC?.hideProgressBar()
                }
            } catch {
                print(error)
                vC?.hideProgressBar()
            }
        }) { (error: Error) in
            vC?.alert(alertmessage: error.localizedDescription)
            vC?.hideProgressBar()
        }
    }
    
    func requestToPurchasedCityMap(_ vC: UIViewController,_ success: @escaping(_ responseData: [Res_PurchasedCityMap]) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.get_purcahse_city_map_list.url(), params: paramGetUserId(), method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_PurchasedCityMaps.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                    }
                } else {
                    print("No Data Available to show!!")
                }
                vC.hideProgressBar()
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToFavCityMap(_ vC: UIViewController,_ success: @escaping(_ responseData: [Res_FavCityMaps]) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.my_fav_citymap.url(), params: paramGetUserId(), method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_FavCityMaps.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    print("No Data Available to show!!")
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToSuggest(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Res_Suggestion) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.add_country_map_suggestion.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_Suggestion.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                    }
                } else {
                    print("No Data Available to show!!")
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToServiceDetail(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Res_ServiceDetails) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.get_service_details.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_ServiceDetails.self, from: response)
                    DispatchQueue.main.async {
                        if root.status == "1" {
                            if let result = root.result {
                                success(result)
                            }
                        } else {
                            print("No Data Available to show!!")
                        }
                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                vC.hideProgressBar()
            }
        })
    }
    
    func requestToAddServiceRating(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Res_ServiceRating) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.add_service_rating_review.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_ServiceRating.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                    }
                } else {
                    vC.hideProgressBar()
                    vC.alert(alertmessage: root.message ?? "")
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToAddScheduleTrip(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Res_DetailScheduleTrip) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.add_user_trip_schedule.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_DetailScheduleTrip.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    print("No Data Available to show!!")
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToUpdateScheduleTrip(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Res_DetailScheduleTrip) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.update_user_trip_schedule.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_DetailScheduleTrip.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    print("No Data Available to show!!")
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToCancelSubcription(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Api_BasicModel) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.cancel_plan_purchase.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            vC.hideProgressBar()
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_BasicModel.self, from: response)
                if root.result != nil {
                    success(root)
                } else {
                    print("No Data Available to show!!")
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToGeneratePlaceId(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Res_GenerateGMPI) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_place_id_by_addresss_googlemap.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_GenerateGMPI.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    print("No Data Available to show!!")
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToGooplePlaceDetails(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Res_GooglePlaceDetail) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.get_details_by_place_id_googlemap.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_GooglePlaceDetail.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    print("No Data Available to show!!")
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToGooplePhotos(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: [Res_GooglePhotos]) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_photos_by_place_id_googlemap.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_GooglePhotos.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    print("No Data Available to show!!")
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToMoreAboutTrip(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: [Res_MoreAboutTrip]) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.get_user_trip_schedule_by_day.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_MoreAboutTrip.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    print("No Data Available to show!!")
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToDeleteTripSchedule(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Api_BasicModel) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.delete_user_trip_schedule.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_BasicModel.self, from: response)
                if root.result != nil {
                    success(root)
                } else {
                    print("No Data Available to show!!")
                }
                vC.hideProgressBar()
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToScheduleTripMapName(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: [Res_ScheduleTripMapName]) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_user_trip_schedule_map_name.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_ScheduleTripMapName.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    vC.hideProgressBar()
                    print(root.message ?? "")
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToDaySelection(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: [Res_DaysSelection]) -> Void) {
        //        vC.showProgressBar()
        Service.post(url: Router.get_days.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_DaysSelection.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    print(vC.alert(alertmessage: R.string.localizable.noDataAvailable()))
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToNotification(_ vC: UIViewController,_ success: @escaping(_ responseData: [Res_Notification]) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.get_notification_list.url(), params: paramGetUserId(), method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_Notification.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    print(vC.alert(alertmessage: R.string.localizable.noDataAvailable()))
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToAdvertismentBanner(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: [Res_Banner]) -> Void) {
        Service.post(url: Router.get_banner.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let jsonDecoder = JSONDecoder()
                    let root = try jsonDecoder.decode(Api_Banner.self, from: response)
                    DispatchQueue.main.async {
                        if root.status == "1" {
                            if let result = root.result {
                                success(result)
                            }
                        } else {
                            print(root.message ?? "")
                        }
                        vC.hideProgressBar()
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(error)
                        vC.hideProgressBar()
                    }
                }
            }
        }, failureBlock: { error in
            DispatchQueue.main.async {
                vC.alert(alertmessage: error.localizedDescription)
                vC.hideProgressBar()
            }
        })
    }
    
    func requestToAddPayment(_ vc: UIViewController, _ params: [String: AnyObject], _ success: @escaping(_ responseData : AnyObject) -> Void) {
        vc.blockUi()
        Service.callPostService(apiUrl: Router.addPayment_moyasar.url(), parameters: params, Method: .get, parentViewController: vc, successBlock: { (response, message) in
            success(response)
            vc.unBlockUi()
        }) { (error) in
            vc.alert(alertmessage: error.localizedDescription)
            vc.unBlockUi()
        }
    }
    
    func requestToPurchasePlan(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Res_PurchasePlan) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.plan_purchase.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_PurchasePlan.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToDeleteCityTrip(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Api_BasicModel) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.delete_user_trip_schedule_by_city.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_BasicModel.self, from: response)
                if root.result != nil {
                    success(root)
                } else {
                    print("No Data Available to show!!")
                }
                vC.hideProgressBar()
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToAppPolicies(_ vC: UIViewController,_ success: @escaping(_ responseData: Res_Policies) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.get_user_page.url(), params: paramGetUserId(), method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_Policies.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToAllCoupons(_ vC: UIViewController,_ success: @escaping(_ responseData: [Res_Coupons]) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.get_coupons.url(), params: paramGetUserId(), method: .get, vc: vC, successBlock: { (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_AllCoupons.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
                vC.hideProgressBar()
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToApplyForOffer(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: Api_ApplyOffer) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.apply_offer.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            vC.hideProgressBar()
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_ApplyOffer.self, from: response)
                if root.result != nil {
                    success(root)
                } else {
                    print("No Data Available to show!!")
                }
            } catch {
                print(error)
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func requestToCityImages(_ vC: UIViewController,_ param: [String : AnyObject],_ success: @escaping(_ responseData: [Res_CityImages]) -> Void) {
        vC.showProgressBar()
        Service.post(url: Router.get_country_map_city_images.url(), params: param, method: .get, vc: vC, successBlock: { (response) in
            vC.hideProgressBar()
            do {
                let jsonDecoder = JSONDecoder()
                let root = try jsonDecoder.decode(Api_CityImages.self, from: response)
                if root.status == "1" {
                    if let result = root.result {
                        success(result)
                        vC.hideProgressBar()
                    }
                } else {
                    vC.hideProgressBar()
                }
            } catch {
                print(error)
            }
        }) { (error: Error) in
            vC.alert(alertmessage: error.localizedDescription)
            vC.hideProgressBar()
        }
    }
    
    func reuestForCurrencyRate(code: String, completion: @escaping (Double) -> Void) {
        Alamofire.request(Router.live_currency_conversion_list_api.url())
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    print("Error converting data to JSON")
                    return
                }
                let currency = JSON(json)["sar"][code.lowercased()].doubleValue
                completion(currency)
            }
    }
    
    func reuestForPaymentVerification(param : [String: Any], completion: @escaping (Bool) -> Void) {
        Alamofire.request(Router.verify_payment_moyasar.url(), parameters: param)
            .responseJSON { response in
                guard let json = response.result.value as? [String: Any] else {
                    print("Error converting data to JSON")
                    return
                }
                print(json)
                let status = JSON(json)["result"]["status"].stringValue
                completion(status == "paid")
                
            }
    }
    
}
