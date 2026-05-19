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
        
        // MARK: Enable Skeleton
        isSkeletonable = true
        contentView.isSkeletonable = true
        
        // Mark container view and its subviews as skeletonable
        if let containerView = contentView.subviews.first {
            containerView.isSkeletonable = true
            containerView.subviews.forEach { $0.isSkeletonable = true }
        }
        
        img.isSkeletonable = true
        lbl_Text.isSkeletonable = true
        btn_MoreOt.isSkeletonable = true
        
        setupSkeletonUI()
        
        self.img.roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }
    
    private func setupSkeletonUI() {
        // Image skeleton
        img.skeletonCornerRadius = 10
        
        // Text → multiline paragraph
        lbl_Text.linesCornerRadius = 4
        lbl_Text.skeletonTextLineHeight = .relativeToFont
        lbl_Text.lastLineFillPercent = 70
        
        // More button
        btn_MoreOt.skeletonCornerRadius = 4
    }
    
    @IBAction func btn_More(_ sender: UIButton) {
        self.cloMore?()
    }
}
