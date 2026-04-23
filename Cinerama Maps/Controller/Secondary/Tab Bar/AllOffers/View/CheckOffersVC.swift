//
//  CheckOffersVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 17/12/24.
//

import UIKit

class CheckOffersVC: UIViewController {

    @IBOutlet weak var offers_TableVe: UITableView!
    
    var arrayOfCoupons: [Res_Coupons] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.offers_TableVe.register(UINib(nibName: "CheckOfferCell", bundle: nil), forCellReuseIdentifier: "CheckOfferCell")
        fetchCoupons()
    }
    
    @IBAction func btn_Back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CheckOffersVC {
    
    func fetchCoupons()
    {
        Api.shared.requestToAllCoupons(self) { [self] responseData in
            if responseData.count > 0 {
                self.arrayOfCoupons = responseData
            } else {
                self.arrayOfCoupons = []
            }
            self.offers_TableVe.reloadData()
        }
    }
    
}

extension CheckOffersVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfCoupons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckOfferCell", for: indexPath) as! CheckOfferCell
        let obj = self.arrayOfCoupons[indexPath.row]
        
        cell.lbl_CouponCOde.text = "Code: \(obj.code ?? "")\n\(obj.percentage ?? "")% Discount\n\(obj.description ?? "")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}
