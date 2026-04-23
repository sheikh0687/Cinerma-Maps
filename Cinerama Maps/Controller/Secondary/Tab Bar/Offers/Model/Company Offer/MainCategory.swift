//
//  MainCategory.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 24/07/25.
//

import Foundation

struct ApiMainOfferCategory : Codable {
    let result : [Res_MainOfferCategory]?
    let message : String?
    let status : String?

    enum CodingKeys: String, CodingKey {

        case result = "result"
        case message = "message"
        case status = "status"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = try values.decodeIfPresent([Res_MainOfferCategory].self, forKey: .result)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }

}

struct Res_MainOfferCategory : Codable {
    let id : String?
    let category_name : String?
    let category_name_ar : String?
    let image : String?
    let status : String?
    let date_time : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case category_name = "category_name"
        case category_name_ar = "category_name_ar"
        case image = "image"
        case status = "status"
        case date_time = "date_time"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        category_name = try values.decodeIfPresent(String.self, forKey: .category_name)
        category_name_ar = try values.decodeIfPresent(String.self, forKey: .category_name_ar)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        date_time = try values.decodeIfPresent(String.self, forKey: .date_time)
    }
}
