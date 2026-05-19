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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        offer_Img.translatesAutoresizingMaskIntoConstraints = false
        offer_Img.heightAnchor.constraint(equalToConstant: 180).isActive = true
        offer_Img.contentMode = .scaleToFill
        offer_Img.clipsToBounds = true
        
        // MARK: Enable Skeleton for full hierarchy
        isSkeletonable = true
        contentView.isSkeletonable = true
        
        offer_Img.isSkeletonable = true
        offer_CodeAndPercent.isSkeletonable = true
        lbl_OfferDescription.isSkeletonable = true
        textDiscount.isSkeletonable = true
        
        setupSkeletonUI()
    }
    
    private func setupSkeletonUI() {
        
        // 🟧 Offer image skeleton
        offer_Img.skeletonCornerRadius = 10
        
        // 💰 Coupon code / percentage (big bold line)
        offer_CodeAndPercent.linesCornerRadius = 6
        offer_CodeAndPercent.skeletonTextLineHeight = .relativeToFont
        offer_CodeAndPercent.lastLineFillPercent = 70
        
        // 📝 Offer description → multiline paragraph
        lbl_OfferDescription.linesCornerRadius = 6
        lbl_OfferDescription.skeletonTextLineHeight = .relativeToFont
        lbl_OfferDescription.numberOfLines = 3
        lbl_OfferDescription.lastLineFillPercent = 60
        
        // 🏷️ "Discount" label small line
        textDiscount.linesCornerRadius = 6
        textDiscount.skeletonTextLineHeight = .relativeToFont
        textDiscount.lastLineFillPercent = 40
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        offer_Img.roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }
}
