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
        // Initialization code
        CountryImage.isSkeletonable = true
        countryMap.isSkeletonable = true
        lbl_CountryName.isSkeletonable = true
        lbl_CountryName.linesCornerRadius = 4
        contentView.isSkeletonable = true
    }
}
