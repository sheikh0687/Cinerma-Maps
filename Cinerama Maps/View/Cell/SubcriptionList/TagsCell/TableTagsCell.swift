//
//  TableTagsCell.swift
//  Cinerama Maps
//
//  Created by TeamX on 06/05/2025.
//

import UIKit

class TableTagsCell: UITableViewCell {
    
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var tag_lbl_name: UILabel!
    
    var onFavoriteTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
