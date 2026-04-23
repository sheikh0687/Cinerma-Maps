//
//  GuidelineCell.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 22/08/24.
//

import UIKit

class GuidelineCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbl_Text: UILabel!
    @IBOutlet weak var btn_MoreOt: UIButton!
    
    var cloMore:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.img.roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }
    
    @IBAction func btn_More(_ sender: UIButton) {
        self.cloMore?()
    }
}
