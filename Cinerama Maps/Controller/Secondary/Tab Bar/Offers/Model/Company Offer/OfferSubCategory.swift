//
//  OfferSubCategory.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 24/07/25.
//

import Foundation

struct ApiOfferSubCategory : Codable {
    let result : [Res_OfferSubCategory]?
    let message : String?
    let status : String?

    enum CodingKeys: String, CodingKey {

        case result = "result"
        case message = "message"
        case status = "status"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = try values.decodeIfPresent([Res_OfferSubCategory].self, forKey: .result)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }
}

struct Res_OfferSubCategory : Codable {
    let id : String?
    let cat_id : String?
    let name : String?
    let name_ar : String?
    let date_time : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case cat_id = "cat_id"
        case name = "name"
        case name_ar = "name_ar"
        case date_time = "date_time"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        cat_id = try values.decodeIfPresent(String.self, forKey: .cat_id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        name_ar = try values.decodeIfPresent(String.self, forKey: .name_ar)
        date_time = try values.decodeIfPresent(String.self, forKey: .date_time)
    }

}
