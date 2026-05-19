//
//  MoreServiceCell.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 16/11/24.
//

import UIKit
import WebKit
import SkeletonView

class MoreServiceCell: UITableViewCell, WKNavigationDelegate {
    
    @IBOutlet weak var view_Company: UIView!
    @IBOutlet weak var lbl_CompanyName: UILabel!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Description: UILabel!
    @IBOutlet weak var company_Img: UIImageView!
    @IBOutlet weak var stackVw: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Image setup
        company_Img.translatesAutoresizingMaskIntoConstraints = false
        company_Img.heightAnchor.constraint(equalToConstant: 180).isActive = true
        company_Img.contentMode = .scaleToFill
        company_Img.clipsToBounds = true

        // ⭐️ IMPORTANT — Enable skeleton per view
        isSkeletonable = true
        contentView.isSkeletonable = true
        view_Company.isSkeletonable = true
        stackVw.isSkeletonable = true
        
        company_Img.isSkeletonable = true
        lbl_Title.isSkeletonable = true
        lbl_CompanyName.isSkeletonable = true
        lbl_Description.isSkeletonable = true
        
        setupSkeletonUI()
    }
    
    private func setupSkeletonUI() {
        
        // Title → single line
        lbl_Title.linesCornerRadius = 6
        lbl_Title.skeletonTextLineHeight = .relativeToFont
        lbl_Title.lastLineFillPercent = 80
        
        // Company name → single line small
        lbl_CompanyName.linesCornerRadius = 6
        lbl_CompanyName.skeletonTextLineHeight = .relativeToFont
        lbl_CompanyName.lastLineFillPercent = 60
        
        // Description → multiline paragraph 😍
        lbl_Description.linesCornerRadius = 6
        lbl_Description.skeletonTextLineHeight = .relativeToFont
        lbl_Description.numberOfLines = 3
        lbl_Description.lastLineFillPercent = 70
        
        // Image rounded skeleton
        company_Img.skeletonCornerRadius = 10
    }

    // ✅ Round corners HERE — after layout is finalized, not in awakeFromNib
    override func layoutSubviews() {
        super.layoutSubviews()
        company_Img.roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }
}
