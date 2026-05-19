//
//  CityMapCell.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 27/08/24.
//

import UIKit
import Cosmos
import SkeletonView

class CityMapCell: UITableViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbl_CountryName: UILabel!
    @IBOutlet weak var lbl_Address: UILabel!
    @IBOutlet weak var lbl_Rating: UILabel!
    @IBOutlet weak var rating_Vw: CosmosView!
    
    @IBOutlet weak var btn_FavOt: UIButton!
    
    var cloFav:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // MARK: Enable Skeleton
        isSkeletonable = true
        contentView.isSkeletonable = true
        
        // Mark container view and its children as skeletonable
        if let containerView = contentView.subviews.first {
            containerView.isSkeletonable = true
            // Recursively enable for nested views if needed, 
            // but for this cell, let's target the immediate children and outlets
            containerView.subviews.forEach { subview in
                subview.isSkeletonable = true
                // Check for nested views like the bottom info view
                subview.subviews.forEach { $0.isSkeletonable = true }
            }
        }
        
        img.isSkeletonable = true
        lbl_CountryName.isSkeletonable = true
        lbl_Address.isSkeletonable = true
        lbl_Rating.isSkeletonable = true
        rating_Vw.isSkeletonable = true
        
        setupSkeletonUI()
    }
    
    private func setupSkeletonUI() {
        
        // 🟧 Image skeleton
        img.skeletonCornerRadius = 12
        
        // 🏙 Country name → bold single line
        lbl_CountryName.linesCornerRadius = 6
        lbl_CountryName.skeletonTextLineHeight = .relativeToFont
        lbl_CountryName.lastLineFillPercent = 70
        
        // 📍 Address → multiline paragraph
        lbl_Address.linesCornerRadius = 6
        lbl_Address.skeletonTextLineHeight = .relativeToFont
        lbl_Address.numberOfLines = 2
        lbl_Address.lastLineFillPercent = 60
        
        // ⭐ Rating small text
        lbl_Rating.linesCornerRadius = 6
        lbl_Rating.skeletonTextLineHeight = .relativeToFont
        lbl_Rating.lastLineFillPercent = 40
        
        // ⭐ Stars shimmer (CosmosView)
        rating_Vw.skeletonCornerRadius = 6
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func btn_Fav(_ sender: UIButton) {
        self.cloFav?()
    }
    
}
