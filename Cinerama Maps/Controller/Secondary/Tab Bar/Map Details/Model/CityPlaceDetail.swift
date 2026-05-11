//
//  CityPlaceDetail.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 05/09/24.
//

import Foundation

struct Api_CityPlaceDetails : Codable {
    let result : Res_CityPlaceDetails?
    let message : String?
    let status : String?

    enum CodingKeys: String, CodingKey {

        case result = "result"
        case message = "message"
        case status = "status"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = try values.decodeIfPresent(Res_CityPlaceDetails.self, forKey: .result)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }

}

struct Res_CityPlaceDetails : Codable {
    let id : String?
    let country_id : String?
    let tag_id : String?
    let name : String?
    let name_ar : String?
    let about_city : String?
    let about_city_ar : String?
    let tag : String?
    let tag_ar : String?
    let image : String?
    let currency : String?
    let currency_ar : String?
    let clothing : String?
    let clothing_ar : String?
    let health : String?
    let health_ar : String?
    let communications : String?
    let communications_ar : String?
    let offical_language : String?
    let offical_language_ar : String?
    let best_time_to_visit : String?
    let best_time_to_visit_ar : String?
    let electrical_socket : String?
    let electrical_socket_ar : String?
    let the_waether : String?
    let the_waether_ar : String?
    let car_police_number : String?
    let police_number : String?
    let address : String?
    let lat : String?
    let lon : String?
    let date_time : String?
    let city_map_price : String?
    let city_map_month : String?
    let remove_status : String?
    let youtube_video_link: String?
    let youtube_video_link_arabic: String?
    let tags : [Tag_details]?
    let places_images : [Places_images]?
    let rating_review : [Rating_review]?
    let place_details : [Place_details]?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case country_id = "country_id"
        case tag_id = "tag_id"
        case name = "name"
        case name_ar = "name_ar"
        case about_city = "about_city"
        case about_city_ar = "about_city_ar"
        case tag = "tag"
        case tag_ar = "tag_ar"
        case image = "image"
        case currency = "currency"
        case currency_ar = "currency_ar"
        case clothing = "clothing"
        case clothing_ar = "clothing_ar"
        case health = "health"
        case health_ar = "health_ar"
        case communications = "communications"
        case communications_ar = "communications_ar"
        case offical_language = "offical_language"
        case offical_language_ar = "offical_language_ar"
        case best_time_to_visit = "best_time_to_visit"
        case best_time_to_visit_ar = "best_time_to_visit_ar"
        case electrical_socket = "electrical_socket"
        case electrical_socket_ar = "electrical_socket_ar"
        case the_waether = "the_waether"
        case the_waether_ar = "the_waether_ar"
        case car_police_number = "car_police_number"
        case police_number = "police_number"
        case address = "address"
        case lat = "lat"
        case lon = "lon"
        case date_time = "date_time"
        case tags = "tags"
        case places_images = "places_images"
        case rating_review = "rating_review"
        case place_details = "place_details"
        case city_map_price = "city_map_price"
        case city_map_month = "city_map_month"
        case remove_status = "remove_status"
        case youtube_video_link = "youtube_video_link"
        case youtube_video_link_arabic = "youtube_video_link_arabic"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        country_id = try values.decodeIfPresent(String.self, forKey: .country_id)
        tag_id = try values.decodeIfPresent(String.self, forKey: .tag_id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        name_ar = try values.decodeIfPresent(String.self, forKey: .name_ar)
        about_city = try values.decodeIfPresent(String.self, forKey: .about_city)
        about_city_ar = try values.decodeIfPresent(String.self, forKey: .about_city_ar)
        tag = try values.decodeIfPresent(String.self, forKey: .tag)
        tag_ar = try values.decodeIfPresent(String.self, forKey: .tag_ar)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        currency = try values.decodeIfPresent(String.self, forKey: .currency)
        currency_ar = try values.decodeIfPresent(String.self, forKey: .currency_ar)
        clothing = try values.decodeIfPresent(String.self, forKey: .clothing)
        clothing_ar = try values.decodeIfPresent(String.self, forKey: .clothing_ar)
        health = try values.decodeIfPresent(String.self, forKey: .health)
        health_ar = try values.decodeIfPresent(String.self, forKey: .health_ar)
        communications = try values.decodeIfPresent(String.self, forKey: .communications)
        communications_ar = try values.decodeIfPresent(String.self, forKey: .communications_ar)
        offical_language = try values.decodeIfPresent(String.self, forKey: .offical_language)
        offical_language_ar = try values.decodeIfPresent(String.self, forKey: .offical_language_ar)
        best_time_to_visit = try values.decodeIfPresent(String.self, forKey: .best_time_to_visit)
        best_time_to_visit_ar = try values.decodeIfPresent(String.self, forKey: .best_time_to_visit_ar)
        electrical_socket = try values.decodeIfPresent(String.self, forKey: .electrical_socket)
        electrical_socket_ar = try values.decodeIfPresent(String.self, forKey: .electrical_socket_ar)
        the_waether = try values.decodeIfPresent(String.self, forKey: .the_waether)
        the_waether_ar = try values.decodeIfPresent(String.self, forKey: .the_waether_ar)
        car_police_number = try values.decodeIfPresent(String.self, forKey: .car_police_number)
        police_number = try values.decodeIfPresent(String.self, forKey: .police_number)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        lat = try values.decodeIfPresent(String.self, forKey: .lat)
        lon = try values.decodeIfPresent(String.self, forKey: .lon)
        date_time = try values.decodeIfPresent(String.self, forKey: .date_time)
        tags = try values.decodeIfPresent([Tag_details].self, forKey: .tags)
        places_images = try values.decodeIfPresent([Places_images].self, forKey: .places_images)
        rating_review = try values.decodeIfPresent([Rating_review].self, forKey: .rating_review)
        place_details = try values.decodeIfPresent([Place_details].self, forKey: .place_details)
        city_map_price = try values.decodeIfPresent(String.self, forKey: .city_map_price)
        city_map_month = try values.decodeIfPresent(String.self, forKey: .city_map_month)
        remove_status = try values.decodeIfPresent(String.self, forKey: .remove_status)
        youtube_video_link = try values.decodeIfPresent(String.self, forKey: .youtube_video_link)
        youtube_video_link_arabic = try values.decodeIfPresent(String.self, forKey: .youtube_video_link_arabic)
    }
}

struct Place_details : Codable, Identifiable {
    var id : String?
    var user_id : String?
    var placeid : String?
    var country_id : String?
    var city_id : String?
    var tag_id : String?
    var place_name : String?
    var place_name_ar : String?
    var description : String?
    var description_ar : String?
    var distance : String?
    var tag : String?
    var tag_ar : String?
    var address : String?
    var lat : String?
    var lon : String?
    var icon : String?
    var icon_background_color : String?
    var show_only_icon : String?
    var promo_code_and_discount : String?
    var promo_code_percentage: String?
    var suggested_time: String?
    var end_date: String?
    var mobile : String?
    var email : String?
    var site_url : String?
    var video_link_en : String?
    var video_link_ar : String?
    var google_map_link : String?
    var date_time : String?
    var fav_status : String?
    var total_unfav_place : String?
    var total_fav_place : String?
    var favoriteCount : Int?
    var country_name : String?
    var country_name_ar : String?
    var city_name : String?
    var city_name_ar : String?
    var advice: String?
    var advice_arabic: String?
    var rating: String?
    var avg_rating : String?
    var plan_purchase_status : String?
    var tag_details : [Tag_details]?
    var currentUserFavorite : Bool?
    public var tags_detail: NSSet?
    var uiImage: UIImage?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case user_id = "user_id"
        case placeid = "placeid"
        case country_id = "country_id"
        case city_id = "city_id"
        case tag_id = "tag_id"
        case place_name = "place_name"
        case place_name_ar = "place_name_ar"
        case description = "description"
        case description_ar = "description_ar"
        case distance = "distance"
        case suggested_time = "suggested_time"
        case tag = "tag"
        case tag_ar = "tag_ar"
        case address = "address"
        case lat = "lat"
        case lon = "lon"
        case icon = "icon"
        case icon_background_color = "icon_background_color"
        case show_only_icon = "show_only_icon"
        case promo_code_and_discount = "promo_code_and_discount"
        case promo_code_percentage = "promo_code_percentage"
        case end_date = "end_date"
        case mobile = "mobile"
        case email = "email"
        case site_url = "site_url"
        case video_link_en = "video_link_en"
        case video_link_ar = "video_link_ar"
        case google_map_link = "google_map_link"
        case date_time = "date_time"
        case fav_status = "fav_status"
        case total_unfav_place = "total_unfav_place"
        case total_fav_place = "total_fav_place"
        case favoriteCount = "favoriteCount"
        case country_name = "country_name"
        case country_name_ar = "country_name_ar"
        case city_name = "city_name"
        case city_name_ar = "city_name_ar"
        case advice = "advice"
        case advice_arabic = "advice_arabic"
        case rating = "rating"
        case avg_rating = "avg_rating"
        case plan_purchase_status = "plan_purchase_status"
        case tag_details = "tag_details"
        case currentUserFavorite = "currentUserFavorite"
    }

    init() {
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        user_id = try values.decodeIfPresent(String.self, forKey: .user_id)
        placeid = try values.decodeIfPresent(String.self, forKey: .placeid)
        country_id = try values.decodeIfPresent(String.self, forKey: .country_id)
        city_id = try values.decodeIfPresent(String.self, forKey: .city_id)
        tag_id = try values.decodeIfPresent(String.self, forKey: .tag_id)
        place_name = try values.decodeIfPresent(String.self, forKey: .place_name)
        place_name_ar = try values.decodeIfPresent(String.self, forKey: .place_name_ar)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        description_ar = try values.decodeIfPresent(String.self, forKey: .description_ar)
        distance = try values.decodeIfPresent(String.self, forKey: .distance)
        tag = try values.decodeIfPresent(String.self, forKey: .tag)
        suggested_time = try values.decodeIfPresent(String.self, forKey: .suggested_time)
        tag_ar = try values.decodeIfPresent(String.self, forKey: .tag_ar)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        lat = try values.decodeIfPresent(String.self, forKey: .lat)
        lon = try values.decodeIfPresent(String.self, forKey: .lon)
        icon = try values.decodeIfPresent(String.self, forKey: .icon)
        icon_background_color = try values.decodeIfPresent(String.self, forKey: .icon_background_color)
        show_only_icon = try values.decodeIfPresent(String.self, forKey: .show_only_icon)
        promo_code_percentage = try values.decodeIfPresent(String.self, forKey: .promo_code_percentage)
        promo_code_and_discount = try values.decodeIfPresent(String.self, forKey: .promo_code_and_discount)
        end_date = try values.decodeIfPresent(String.self, forKey: .end_date)
        mobile = try values.decodeIfPresent(String.self, forKey: .mobile)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        site_url = try values.decodeIfPresent(String.self, forKey: .site_url)
        video_link_en = try values.decodeIfPresent(String.self, forKey: .video_link_en)
        video_link_ar = try values.decodeIfPresent(String.self, forKey: .video_link_ar)
        google_map_link = try values.decodeIfPresent(String.self, forKey: .google_map_link)
        date_time = try values.decodeIfPresent(String.self, forKey: .date_time)
        fav_status = try values.decodeIfPresent(String.self, forKey: .fav_status)
        total_unfav_place = try values.decodeIfPresent(String.self, forKey: .total_unfav_place)
        total_fav_place = try values.decodeIfPresent(String.self, forKey: .total_fav_place)
        country_name = try values.decodeIfPresent(String.self, forKey: .country_name)
        country_name_ar = try values.decodeIfPresent(String.self, forKey: .country_name_ar)
        city_name = try values.decodeIfPresent(String.self, forKey: .city_name)
        city_name_ar = try values.decodeIfPresent(String.self, forKey: .city_name_ar)
        advice = try values.decodeIfPresent(String.self, forKey: .advice)
        advice_arabic = try values.decodeIfPresent(String.self, forKey: .advice_arabic)
        rating = try values.decodeIfPresent(String.self, forKey: .rating)
        avg_rating = try values.decodeIfPresent(String.self, forKey: .avg_rating)
        plan_purchase_status = try values.decodeIfPresent(String.self, forKey: .plan_purchase_status)
        tag_details = try values.decodeIfPresent([Tag_details].self, forKey: .tag_details)
        currentUserFavorite = try values.decodeIfPresent(Bool.self, forKey: .currentUserFavorite)
        favoriteCount = try values.decodeIfPresent(Int.self, forKey: .favoriteCount)
    }
}

struct Rating_review : Codable {
    let id : String?
    let user_id : String?
    let city_id : String?
    let place_id : String?
    let rating : String?
    let review : String?
    let type : String?
    let date_time : String?
    let user_name : String?
    let image : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case user_id = "user_id"
        case city_id = "city_id"
        case place_id = "place_id"
        case rating = "rating"
        case review = "review"
        case type = "type"
        case date_time = "date_time"
        case user_name = "user_name"
        case image = "image"
    }
    
    init(id: String?, user_id: String?, city_id: String?, place_id: String?, rating: String?, review: String?, type: String?, date_time: String?, user_name: String?, image: String?) {
        self.id = id
        self.user_id = user_id
        self.city_id = city_id
        self.place_id = place_id
        self.rating = rating
        self.review = review
        self.type = type
        self.date_time = date_time
        self.user_name = user_name
        self.image = image
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        user_id = try values.decodeIfPresent(String.self, forKey: .user_id)
        city_id = try values.decodeIfPresent(String.self, forKey: .city_id)
        place_id = try values.decodeIfPresent(String.self, forKey: .place_id)
        rating = try values.decodeIfPresent(String.self, forKey: .rating)
        review = try values.decodeIfPresent(String.self, forKey: .review)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        date_time = try values.decodeIfPresent(String.self, forKey: .date_time)
        user_name = try values.decodeIfPresent(String.self, forKey: .user_name)
        image = try values.decodeIfPresent(String.self, forKey: .image)
    }

}

struct Places_images : Codable , Identifiable{
    var id : String?
    var place_id : String?
    var image : String?
    var uiImage: UIImage?
    var date_time : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case place_id = "place_id"
        case image = "image"
        case date_time = "date_time"
    }

    init() {}
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        place_id = try values.decodeIfPresent(String.self, forKey: .place_id)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        date_time = try values.decodeIfPresent(String.self, forKey: .date_time)
    }

}


class PlaceViewModel {
    static let shared = PlaceViewModel()
    var arrayPlaceDetail: Place_details?
    
    func updateFavoriteStatus(for placeId: String, status: String) {
        // Update the current place detail if it matches
        if arrayPlaceDetail?.placeid == placeId {
            arrayPlaceDetail?.fav_status = status
        }
        
        // Save to persistent storage
        UserDefaults.standard.set(status, forKey: "fav_\(placeId)")
    }
    
    func getFavoriteStatus(for placeId: String) -> String {
        // Get from persistent storage, default to "No" if not found
        return UserDefaults.standard.string(forKey: "fav_\(placeId)") ?? "No"
    }
    
    // Call this when loading place details
    func syncFavoriteStatus(for placeId: String) {
        if arrayPlaceDetail?.placeid == placeId {
            arrayPlaceDetail?.fav_status = getFavoriteStatus(for: placeId)
        }
    }
}
