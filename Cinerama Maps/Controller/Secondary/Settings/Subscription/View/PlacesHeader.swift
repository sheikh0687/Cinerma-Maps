//
//  PlacesHeader.swift
//  Cinerama Maps
//
//  Created by TeamX on 13/05/2025.
//

import UIKit

class PlacesHeader: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var textViewAll: UILabel!
    @IBOutlet weak var imgHeart: UIImageView!
    @IBOutlet weak var imgWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
