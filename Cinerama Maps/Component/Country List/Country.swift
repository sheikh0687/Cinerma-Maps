//
//  Country.swift
//  CountryListExample
//
//  Created by Juan Pablo on 9/8/17.
//  Copyright © 2017 Juan Pablo Fernandez. All rights reserved.
//

import UIKit

public class Country: NSObject {
    public var countryCode: String
    public var phoneExtension: String

    /// Returns the localized country name according to the current app locale,
    /// and uses Arabic if the app is in Arabic.
    public var name: String? {
        let preferredLang = Locale.preferredLanguages.first ?? "en"
        let id: String
        if preferredLang.starts(with: "ar") {
            id = "ar"
        } else {
            id = "en"
        }
        let current = Locale(identifier: id)
        return current.localizedString(forRegionCode: countryCode)
    }

    public var flag: String? {
        return flag(country: countryCode)
    }

    init(countryCode: String, phoneExtension: String) {
        self.countryCode = countryCode
        self.phoneExtension = phoneExtension
    }

    private func flag(country: String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            if let scalar = UnicodeScalar(base + v.value) {
                s.unicodeScalars.append(scalar)
            }
        }
        return String(s)
    }
}
