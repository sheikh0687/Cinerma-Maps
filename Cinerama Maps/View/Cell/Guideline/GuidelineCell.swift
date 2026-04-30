//
//  GuidelineCell.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 22/08/24.
//

import UIKit
import SkeletonView

class GuidelineCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbl_Text: UILabel!
    @IBOutlet weak var btn_MoreOt: UIButton!
    
    var cloMore:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        isSkeletonable = true
        
        img.isSkeletonable = true
        lbl_Text.isSkeletonable = true
        lbl_Text.linesCornerRadius = 4
        btn_MoreOt.isSkeletonable = true
        contentView.isSkeletonable = true
        self.img.roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }
    
    @IBAction func btn_More(_ sender: UIButton) {
        self.cloMore?()
    }
}
