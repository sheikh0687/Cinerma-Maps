//
//  Coupons.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 17/12/24.
//

import Foundation

struct Api_AllCoupons : Codable {
    let result : [Res_Coupons]?
    let message : String?
    let status : String?

    enum CodingKeys: String, CodingKey {

        case result = "result"
        case message = "message"
        case status = "status"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = try values.decodeIfPresent([Res_Coupons].self, forKey: .result)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }
}

struct Res_Coupons : Codable {
    let id : String?
    let user_id : String?
    let user_name : String?
    let code : String?
    let percentage : String?
    let image : String?
    let end_date : String?
    let description : String?
    let description_ar : String?
    let date_time : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case user_id = "user_id"
        case user_name = "user_name"
        case code = "code"
        case percentage = "percentage"
        case image = "image"
        case end_date = "end_date"
        case description = "description"
        case description_ar = "description_ar"
        case date_time = "date_time"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        user_id = try values.decodeIfPresent(String.self, forKey: .user_id)
        user_name = try values.decodeIfPresent(String.self, forKey: .user_name)
        code = try values.decodeIfPresent(String.self, forKey: .code)
        percentage = try values.decodeIfPresent(String.self, forKey: .percentage)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        end_date = try values.decodeIfPresent(String.self, forKey: .end_date)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        description_ar = try values.decodeIfPresent(String.self, forKey: .description_ar)
        date_time = try values.decodeIfPresent(String.self, forKey: .date_time)
    }

}
