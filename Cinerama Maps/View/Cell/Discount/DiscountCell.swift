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
    @IBOutlet weak var stackVw: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        offer_Img.translatesAutoresizingMaskIntoConstraints = false
        offer_Img.heightAnchor.constraint(equalToConstant: 180).isActive = true
        offer_Img.contentMode = .scaleToFill
        offer_Img.clipsToBounds = true
        
        // MARK: Enable Skeleton for full hierarchy
        self.isSkeletonable = true
        self.contentView.isSkeletonable = true
        
        // Recursively enable skeleton for all nested subviews
        self.enableSkeleton(self.contentView)
        
        setupSkeletonUI()
    }
    
    private func enableSkeleton(_ view: UIView) {
        view.isSkeletonable = true
        if let stack = view as? UIStackView {
            stack.arrangedSubviews.forEach { enableSkeleton($0) }
        }
        view.subviews.forEach { enableSkeleton($0) }
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
        
        // 📦 StackView skeleton matching its rounded corners
        stackVw.skeletonCornerRadius = 8
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        offer_Img.roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }
}
