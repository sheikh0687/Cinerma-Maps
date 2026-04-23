//
//  SubcriberCategory.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 01/08/25.
//

import Foundation

struct Api_SubscriberCategory : Codable {
    let result : [Res_SubscriberCategory]?
    let message : String?
    let status : String?

    enum CodingKeys: String, CodingKey {

        case result = "result"
        case message = "message"
        case status = "status"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = try values.decodeIfPresent([Res_SubscriberCategory].self, forKey: .result)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }

}

struct Res_SubscriberCategory : Codable {
    let id : String?
    let city_id : String?
    let name : String?
    let name_ar : String?
    let date_time : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case city_id = "city_id"
        case name = "name"
        case name_ar = "name_ar"
        case date_time = "date_time"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        city_id = try values.decodeIfPresent(String.self, forKey: .city_id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        name_ar = try values.decodeIfPresent(String.self, forKey: .name_ar)
        date_time = try values.decodeIfPresent(String.self, forKey: .date_time)
    }

}
