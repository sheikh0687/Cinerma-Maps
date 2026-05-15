//
//  PartnerServiceCell.swift
//  Cinerama Maps
//
//  Created by Arbaz  on 14/05/26.
//

import UIKit

class PartnerServiceCell: UITableViewCell {

    @IBOutlet weak var city_Img: UIImageView!
    @IBOutlet weak var lbl_CityTitle: UILabel!
    @IBOutlet weak var lbl_CityAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
