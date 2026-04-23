//
//  SubscriptionCell.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 23/08/24.
//

import UIKit

class SubscriptionCell: UITableViewCell {

    @IBOutlet weak var lbl_MapName: UILabel!
    @IBOutlet weak var lbl_Amount: UILabel!
    @IBOutlet weak var lbl_AboutCity: UILabel!
    @IBOutlet weak var lbl_ExpiryDate: UILabel!
    
    var cloCancelPackage:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        self.lbl_ExpiryDate.roundCorners(corners: [.allCorners], radius: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btn_CancelPackage(_ sender: UIButton) {
        self.cloCancelPackage?()
    }
}
