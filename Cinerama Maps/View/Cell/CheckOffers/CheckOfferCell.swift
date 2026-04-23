//
//  CheckOfferCell.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 17/12/24.
//

import UIKit

class CheckOfferCell: UITableViewCell {

    @IBOutlet weak var offer_Img: UIImageView!
    @IBOutlet weak var lbl_CouponCOde: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
