//
//  DiscountCell.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 23/08/24.
//

import UIKit
import SkeletonView

class DiscountCell: UITableViewCell {

    @IBOutlet weak var offer_Img: UIImageView!
    @IBOutlet weak var offer_CodeAndPercent: UILabel!
    @IBOutlet weak var lbl_OfferDescription: UILabel!
    @IBOutlet weak var textDiscount: UILabel!
    
    @IBOutlet weak var subVw: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isSkeletonable = true
        
        offer_Img.isSkeletonable = true
        offer_CodeAndPercent.isSkeletonable = true
        lbl_OfferDescription.isSkeletonable = true
        lbl_OfferDescription.linesCornerRadius = 4
        contentView.isSkeletonable = true
        offer_Img.roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
