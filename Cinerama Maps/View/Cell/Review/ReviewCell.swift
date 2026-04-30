//
//  ReviewCell.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 23/08/24.
//

import UIKit
import Cosmos
import SkeletonView

class ReviewCell: UITableViewCell {

    @IBOutlet weak var lbl_Name: UILabel!
    @IBOutlet weak var lbl_Date: UILabel!
    @IBOutlet weak var ratingStar: CosmosView!
    @IBOutlet weak var ratingCount: UILabel!
    @IBOutlet weak var lbl_Message: UILabel!
    @IBOutlet weak var user_Img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        isSkeletonable = true
        lbl_Name.isSkeletonable = true
        lbl_Date.isSkeletonable = true
        lbl_Message.isSkeletonable = true
        ratingCount.isSkeletonable = true
        
        lbl_Name.linesCornerRadius = 4
        lbl_Date.linesCornerRadius = 4
        lbl_Message.linesCornerRadius = 4
        ratingCount.linesCornerRadius = 4
        
        user_Img.isSkeletonable = true
        
        contentView.isSkeletonable = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
