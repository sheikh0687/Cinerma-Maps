//
//  Router.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 02/09/24.
//

import Foundation

enum Router: String {
    
    static let BASE_SERVICE_URL = "https://www.ci-maps.com/CineramaMaps/webservice/"
    static let BASE_IMAGE_URL = "https://www.ci-maps.com/CineramaMaps/uploads/images/"
    
    case send_otp_mail
    case signup
    case social_login
    
    case get_profile
    case get_country_map
    case get_country_map_city
    
    case get_company_offer
    case get_offer_category
    case get_offer_sub_category
    case get_offer_child_sub_category
    
    case get_tourism_services
    case get_tourism_services_category
    case get_tourism_services_sub_category
    case get_tourism_services_child_sub_category
    
    case get_partner_services
    case get_partner_services_category
    case get_partner_services_sub_category
    case get_partner_services_child_sub_category
    
    case get_guidelines_tips_new
    case get_guidelines_tips_category
    case get_guidelines_tips_sub_category
    case get_guidelines_tips_child_sub_category
    
    case get_guidelines_tips_category_NonSubcriber
    case get_guidelines_tips_sub_category_NonSubcriber
    case get_guidelines_tips_child_sub_category_NonSubcriber
    case get_guidelines_tips_new_NonSubcriber
    
    case get_country_map_city_places_new
    case get_user_trip_schedule
    case get_user_trip_schedule_details
    case get_purcahse_city_map_list
    case get_service_details
    case my_fav_citymap
    
    case get_place_id_by_addresss_googlemap
    case get_details_by_place_id_googlemap
    case get_photos_by_place_id_googlemap
    case get_user_trip_schedule_by_day
    case get_user_trip_schedule_map_name
    case get_days
    case get_banner
    case get_notification_list
    case get_user_page
    case get_coupons
    
    case add_user_trip_schedule
    case add_service_rating_review
    case add_city_rating_review
    case add_country_map_suggestion
    case fav_unfav_citymap
    case update_user_trip_schedule
    case fav_unfav_place
    case apply_offer
    case update_profile
    
    case addPayment_moyasar
    case plan_purchase
    
    case cancel_plan_purchase
    
    case delete_user_trip_schedule_by_city
    case delete_user_trip_schedule
    case live_currency_conversion_list_api
    case verify_payment_moyasar
    case paymentWithTapPaymentGateway
    case add_to_favorite
    
    case get_user_subcriber_city
    case get_category_behalf_city
    case get_country_map_city_images
    
    public func url() -> String {
        switch self {
        case .send_otp_mail:
            return Router.oAuthPath(path: "send_otp_mail")
        case .signup:
            return Router.oAuthPath(path: "signup")
        case .social_login:
            return Router.oAuthPath(path: "social_login")
            
        case .get_profile:
            return Router.oAuthPath(path: "get_profile")
        case .get_tourism_services:
            return Router.oAuthPath(path: "get_tourism_services")
        case .get_country_map:
            return Router.oAuthPath(path: "get_country_map")
        case .get_country_map_city:
            return Router.oAuthPath(path: "get_country_map_city")
        case .get_guidelines_tips_new:
            return Router.oAuthPath(path: "get_guidelines_tips_new")
        case .get_company_offer:
            return Router.oAuthPath(path: "get_company_offer_new")
//        case .get_country_map_city_places:
//            return Router.oAuthPath(path: "get_country_map_city_places")
        case .get_country_map_city_places_new:
            return Router.oAuthPath(path: "get_country_map_city_places_new")
        case .get_user_trip_schedule:
            return Router.oAuthPath(path: "get_user_trip_schedule")
        case .get_user_trip_schedule_details:
            return Router.oAuthPath(path: "get_user_trip_schedule_details")
        case .get_purcahse_city_map_list:
            return Router.oAuthPath(path: "get_purcahse_city_map_list")
        case .get_service_details:
            return Router.oAuthPath(path: "get_service_details")
        case .get_user_page:
            return Router.oAuthPath(path: "get_user_page")
            
        case .get_place_id_by_addresss_googlemap:
            return Router.oAuthPath(path: "get_place_id_by_addresss_googlemap")
        case .get_details_by_place_id_googlemap:
            return Router.oAuthPath(path: "get_details_by_place_id_googlemap")
        case .get_photos_by_place_id_googlemap:
            return Router.oAuthPath(path: "get_photos_by_place_id_googlemap")
        case .get_user_trip_schedule_by_day:
            return Router.oAuthPath(path: "get_user_trip_schedule_by_day")
        case .get_user_trip_schedule_map_name:
            return Router.oAuthPath(path: "get_user_trip_schedule_map_name")
        case .get_days:
            return Router.oAuthPath(path: "get_days")
        case .get_banner:
            return Router.oAuthPath(path: "get_banner")
        case .get_notification_list:
            return Router.oAuthPath(path: "get_notification_list")
        case .get_coupons:
            return Router.oAuthPath(path: "get_coupons")
            
        case .add_service_rating_review:
            return Router.oAuthPath(path: "add_service_rating_review")
        case .add_city_rating_review:
            return Router.oAuthPath(path: "add_city_rating_review")
        case .add_country_map_suggestion:
            return Router.oAuthPath(path: "add_country_map_suggestion")
        case .fav_unfav_citymap:
            return Router.oAuthPath(path: "fav_unfav_citymap")
        case .my_fav_citymap:
            return Router.oAuthPath(path: "my_fav_citymap")
        case .add_user_trip_schedule:
            return Router.oAuthPath(path: "add_user_trip_schedule")
        case .update_user_trip_schedule:
            return Router.oAuthPath(path: "update_user_trip_schedule")
        case .fav_unfav_place:
            return Router.oAuthPath(path: "fav_unfav_place")
        case .apply_offer:
            return Router.oAuthPath(path: "apply_offer")
        case .update_profile:
            return Router.oAuthPath(path: "update_profile")
            
        case .cancel_plan_purchase:
            return Router.oAuthPath(path: "cancel_plan_purchase")
            
        case .delete_user_trip_schedule_by_city:
            return Router.oAuthPath(path: "delete_user_trip_schedule_by_city")
        case .delete_user_trip_schedule:
            return Router.oAuthPath(path: "delete_user_trip_schedule")
       
        case .addPayment_moyasar:
            return Router.oAuthPath(path: "addPayment_moyasar")
        case .plan_purchase:
            return Router.oAuthPath(path: "plan_purchase")
    
        case .live_currency_conversion_list_api:
            return "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/sar.json"
        case .paymentWithTapPaymentGateway:
            //return "https://staginglabs.in/tab-pay/checkoutpay.php"
            return "http://35.183.250.236/CineramaMaps/webservice/checkout"
            
        case .verify_payment_moyasar:
           return Router.oAuthPath(path: "verifyPayment_moyasar")
        case .add_to_favorite:
            return Router.oAuthPath(path: "addTofavorite")
            
        case .get_offer_category:
            return Router.oAuthPath(path: "get_offer_category")
        case .get_offer_sub_category:
            return Router.oAuthPath(path: "get_offer_sub_category")
        case .get_offer_child_sub_category:
            return Router.oAuthPath(path: "get_offer_child_sub_category")
        
        case .get_tourism_services_category:
            return Router.oAuthPath(path: "get_tourism_services_category")
        case .get_tourism_services_sub_category:
            return Router.oAuthPath(path: "get_tourism_services_sub_category")
        case .get_tourism_services_child_sub_category:
            return Router.oAuthPath(path: "get_tourism_services_child_sub_category")
            
        case .get_partner_services:
            return Router.oAuthPath(path: "get_partner_services")
        case .get_partner_services_category:
            return Router.oAuthPath(path: "get_partner_services_category")
        case .get_partner_services_sub_category:
            return Router.oAuthPath(path: "get_partner_services_sub_category")
        case .get_partner_services_child_sub_category:
            return Router.oAuthPath(path: "get_partner_services_child_sub_category")
        
        case .get_guidelines_tips_category_NonSubcriber:
            return Router.oAuthPath(path: "get_guidelines_tips_category_NonSubcriber")
        case .get_guidelines_tips_sub_category_NonSubcriber:
            return Router.oAuthPath(path: "get_guidelines_tips_sub_category_NonSubcriber")
        case .get_guidelines_tips_child_sub_category_NonSubcriber:
            return Router.oAuthPath(path: "get_guidelines_tips_child_sub_category_NonSubcriber")
        case .get_guidelines_tips_new_NonSubcriber:
            return Router.oAuthPath(path: "get_guidelines_tips_new_NonSubcriber")

        case .get_guidelines_tips_category:
            return Router.oAuthPath(path: "get_guidelines_tips_category")
        case .get_guidelines_tips_sub_category:
            return Router.oAuthPath(path: "get_guidelines_tips_sub_category")
        case .get_guidelines_tips_child_sub_category:
            return Router.oAuthPath(path: "get_guidelines_tips_child_sub_category")
            
        case .get_user_subcriber_city:
            return Router.oAuthPath(path: "get_user_subcriber_city")
        case .get_category_behalf_city:
            return Router.oAuthPath(path: "get_category_behalf_city")
            
        case .get_country_map_city_images:
            return Router.oAuthPath(path: "get_country_map_city_images")
        }
    }
    
    private static func oAuthPath(path: String) -> String {
        return Router.BASE_SERVICE_URL + path
    }
}
