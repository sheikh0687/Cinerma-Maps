//
//  MapTagCells.swift
//  Cinerama Maps
//
//  Created by Farooq Haroon on 6/20/25.
//

import UIKit
import SkeletonView

class MapTagCells: UICollectionViewCell {

    @IBOutlet weak var lbl_place: UILabel!
    @IBOutlet weak var index: UILabel!
    @IBOutlet weak var indexview: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        isSkeletonable = true
        
        indexview.isSkeletonable = true
        lbl_place.isSkeletonable = true
        lbl_place.linesCornerRadius = 4
        contentView.isSkeletonable = true
    }

}
