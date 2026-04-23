//
//  ApplyOffers.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 17/12/24.
//

import Foundation

struct Api_ApplyOffer : Codable {
    let total_amount : String?
    let discount_amount : Double?
    let after_discount : Double?
    
    let offer_id : String?
    let result : String?
    let message : String?
    let status : String?

    enum CodingKeys: String, CodingKey {

        case total_amount = "total_amount"
        case discount_amount = "discount_amount"
        case after_discount = "after_discount"
        case offer_id = "offer_id"
        case result = "result"
        case message = "message"
        case status = "status"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        total_amount = try values.decodeIfPresent(String.self, forKey: .total_amount)
        discount_amount = try values.decodeIfPresent(Double.self, forKey: .discount_amount)
        after_discount = try values.decodeIfPresent(Double.self, forKey: .after_discount)
        offer_id = try values.decodeIfPresent(String.self, forKey: .offer_id)
        result = try values.decodeIfPresent(String.self, forKey: .result)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }

}
