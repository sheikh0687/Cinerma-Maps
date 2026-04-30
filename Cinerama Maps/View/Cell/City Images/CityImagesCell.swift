//
//  CityImagesCell.swift
//  Cinerama Maps
//
//  Created by Arbaz  on 17/04/26.
//

import UIKit
import SkeletonView

class CityImagesCell: UICollectionViewCell {

    @IBOutlet weak var cityImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        isSkeletonable = true
        cityImg.isSkeletonable = true
        contentView.isSkeletonable = true
    }

}
