//
//  PartnerServiceCell.swift
//  Cinerama Maps
//
//  Created by Arbaz  on 14/05/26.
//

import UIKit
import SkeletonView

class PartnerServiceCell: UITableViewCell {

    @IBOutlet weak var city_Img: UIImageView!
    @IBOutlet weak var lbl_CityTitle: UILabel!
    @IBOutlet weak var lbl_CityAddress: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        city_Img.translatesAutoresizingMaskIntoConstraints = false
        city_Img.heightAnchor.constraint(equalToConstant: 100).isActive = true
        city_Img.contentMode = .scaleToFill
        city_Img.clipsToBounds = true
        
        // MARK: Skeleton Enable (IMPORTANT)
        isSkeletonable = true
        contentView.isSkeletonable = true
        
        // Mark container view and all its children as skeletonable
        if let containerView = contentView.subviews.first {
            containerView.isSkeletonable = true
            containerView.subviews.forEach { $0.isSkeletonable = true }
        }
        
        city_Img.isSkeletonable = true
        lbl_CityTitle.isSkeletonable = true
        lbl_CityAddress.isSkeletonable = true
        
        setupSkeletonUI()
    }
    
    private func setupSkeletonUI() {
        
        city_Img.skeletonCornerRadius = 12   // nice rounded image
        
        // City Title → single line bold text
        lbl_CityTitle.linesCornerRadius = 6
        lbl_CityTitle.skeletonTextLineHeight = .relativeToFont
        lbl_CityTitle.lastLineFillPercent = 80
        
        // Address → multiline small paragraph
        lbl_CityAddress.linesCornerRadius = 6
        lbl_CityAddress.skeletonTextLineHeight = .relativeToFont
        lbl_CityAddress.numberOfLines = 2
        lbl_CityAddress.lastLineFillPercent = 60
    }
}
