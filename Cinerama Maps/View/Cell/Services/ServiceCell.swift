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
        // Initialization code
        isSkeletonable = true
        service_Img.isSkeletonable = true
        contentView.isSkeletonable = true
    }

}
