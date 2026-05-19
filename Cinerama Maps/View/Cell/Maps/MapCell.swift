//
//  MapCell.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 22/08/24.
//

import UIKit
import SkeletonView

class MapCell: UICollectionViewCell {

    @IBOutlet weak var CountryImage: UIImageView!
    @IBOutlet weak var countryMap: UIImageView!
    @IBOutlet weak var lbl_CountryName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // MARK: Enable Skeleton
        isSkeletonable = true
        contentView.isSkeletonable = true
        
        // Mark container view and its subviews as skeletonable
        if let containerView = contentView.subviews.first {
            containerView.isSkeletonable = true
            containerView.subviews.forEach { $0.isSkeletonable = true }
        }
        
        CountryImage.isSkeletonable = true
        countryMap.isSkeletonable = true
        lbl_CountryName.isSkeletonable = true
        
        setupSkeletonUI()
    }
    
    private func setupSkeletonUI() {
        // Image rounded skeleton
        CountryImage.skeletonCornerRadius = 10
        
        // Mini map icon skeleton
        countryMap.skeletonCornerRadius = 4
        
        // Country Name → single line
        lbl_CountryName.linesCornerRadius = 4
        lbl_CountryName.skeletonTextLineHeight = .relativeToFont
        lbl_CountryName.lastLineFillPercent = 80
    }
}
