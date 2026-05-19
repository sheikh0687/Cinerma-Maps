//
//  ServiceCell.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 22/08/24.
//

import UIKit
import SkeletonView

class ServiceCell: UICollectionViewCell {

    @IBOutlet weak var service_Img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        // MARK: Enable Skeleton
//        isSkeletonable = true
//        contentView.isSkeletonable = true
//        
//        service_Img.isSkeletonable = true
//        service_Img.skeletonCornerRadius = 10
    }

}
