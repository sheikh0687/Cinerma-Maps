//
//  Policies.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 16/12/24.
//

import Foundation

struct Api_Policies : Codable {
    let result : Res_Policies?
    let message : String?
    let status : String?

    enum CodingKeys: String, CodingKey {

        case result = "result"
        case message = "message"
        case status = "status"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = try values.decodeIfPresent(Res_Policies.self, forKey: .result)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }
}

struct Res_Policies : Codable {
    let id : String?
    let about_us : String?
    let about_us_sp : String?
    let term : String?
    let term_sp : String?
    let privacy : String?
    let privacy_sp : String?
    let date_time : String?
    let type : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case about_us = "about_us"
        case about_us_sp = "about_us_sp"
        case term = "term"
        case term_sp = "term_sp"
        case privacy = "privacy"
        case privacy_sp = "privacy_sp"
        case date_time = "date_time"
        case type = "type"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        about_us = try values.decodeIfPresent(String.self, forKey: .about_us)
        about_us_sp = try values.decodeIfPresent(String.self, forKey: .about_us_sp)
        term = try values.decodeIfPresent(String.self, forKey: .term)
        term_sp = try values.decodeIfPresent(String.self, forKey: .term_sp)
        privacy = try values.decodeIfPresent(String.self, forKey: .privacy)
        privacy_sp = try values.decodeIfPresent(String.self, forKey: .privacy_sp)
        date_time = try values.decodeIfPresent(String.self, forKey: .date_time)
        type = try values.decodeIfPresent(String.self, forKey: .type)
    }

}
