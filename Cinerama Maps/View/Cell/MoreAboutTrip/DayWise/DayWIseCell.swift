//
//  DayWIseCell.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 20/12/24.
//

import UIKit

class DayWIseCell: UITableViewCell {

    @IBOutlet weak var lbl_Address: UILabel!
    
    @IBOutlet weak var lbl_KM: UILabel!
    @IBOutlet weak var lbl_Minutes: UILabel!
    @IBOutlet weak var lbl_CityName: UILabel!
    @IBOutlet weak var lbl_CretedByCNRM: UILabel!

    var cloDelete:(() -> Void)?
    var cloEdit:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_Delete(_ sender: UIButton) {
        self.cloDelete?()
    }
    
    @IBAction func btn_Edit(_ sender: UIButton) {
        self.cloEdit?()
    }
}
