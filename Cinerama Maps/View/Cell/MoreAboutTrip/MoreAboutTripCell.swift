//
//  MoreAboutTripCell.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 14/11/24.
//

import UIKit

class MoreAboutTripCell: UITableViewCell {
    
    @IBOutlet weak var lbl_DayName: UILabel!
    @IBOutlet weak var viewHeadline: UIView!
    
    @IBOutlet weak var lbl_Address: UILabel!
    @IBOutlet weak var lbl_Distance: UILabel!
    @IBOutlet weak var lbl_Time: UILabel!
    @IBOutlet weak var lbl_CityName: UILabel!
    @IBOutlet weak var lbl_CretedByCNRM: UILabel!
    
    var cloEdit:(() -> Void)?
    var cloDelete:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
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

//extension MoreAboutTripCell: UITableViewDataSource, UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        arrayOfDayWise.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "DayWIseCell", for: indexPath) as! DayWIseCell
//        
//        let val = self.arrayOfDayWise[indexPath.row]
//        

//        
//        cell.cloEdit = { [self] in
//            self.cloEdit?(val.place_id ?? "", val.id ?? "")
//        }
//        
//        cell.cloDelete = { [] in
//            self.cloDelete?(val.id ?? "")
//        }
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let val = self.arrayOfDayWise[indexPath.row]
//        Utility.openGoogleMap(latitude: Double(val.lat ?? "") ?? 0.0, longitude: Double(val.lon ?? "") ?? 0.0)
//    }
//}
