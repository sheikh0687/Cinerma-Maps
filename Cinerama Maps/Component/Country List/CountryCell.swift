//
//  CountryCell.swift
//  CountryListExample
//
//  Created by Juan Pablo on 9/8/17.
//  Copyright © 2017 Juan Pablo Fernandez. All rights reserved.
//

import UIKit

class CountryCell: UITableViewCell {
    
    var nameLabel: UILabel?
    var extensionLabel: UILabel?
    
    var country: Country? {
        didSet {
            if let country = country {
                nameLabel?.text = country.name ?? country.countryCode
                extensionLabel?.text = "+\(country.phoneExtension)"
                let isRTL = Locale.characterDirection(forLanguage: Locale.preferredLanguages.first ?? "en") == .rightToLeft
                nameLabel?.textAlignment = isRTL ? .right : .left
                extensionLabel?.textAlignment = isRTL ? .left : .right
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel?.text = ""
        self.extensionLabel?.text = ""
    }

    func setup() {
        nameLabel = UILabel()
        nameLabel?.textColor = UIColor.black
        nameLabel?.font = UIFont.systemFont(ofSize: 20)
        nameLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(nameLabel!)

        extensionLabel = UILabel()
        extensionLabel?.textColor = UIColor.gray
        extensionLabel?.font = UIFont.systemFont(ofSize: 18)
        extensionLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(extensionLabel!)

        // Constraints: RTL support!
        let isRTL = Locale.characterDirection(forLanguage: Locale.preferredLanguages.first ?? "en") == .rightToLeft

        if isRTL {
            nameLabel?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
            extensionLabel?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        } else {
            nameLabel?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
            extensionLabel?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        }
        nameLabel?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        extensionLabel?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
