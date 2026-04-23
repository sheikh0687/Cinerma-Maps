//
//  SubscriptionVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 23/08/24.
//

import UIKit

class SubscriptionVC: UIViewController {
    
    @IBOutlet weak var subscription_TableVw: UITableView!
    @IBOutlet weak var subscription_TableHeight: NSLayoutConstraint!
    
    var viewModel: PurchasedCityViewModel
    
    init(viewModel: PurchasedCityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = PurchasedCityViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subscription_TableVw.register(UINib(nibName: "SubscriptionCell", bundle: nil), forCellReuseIdentifier: "SubscriptionCell")
        setUpBinding()
    }
    
    @IBAction func btn_Back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setUpBinding()
    {
        viewModel.fetchPurchaseCityMap(vC: self, tableHeight: subscription_TableHeight)
        viewModel.requestSuccessfull = {[] in
            self.subscription_TableVw.reloadData()
        }
    }
}

extension SubscriptionVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.arrayOfPurchasedCityMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCell", for: indexPath) as! SubscriptionCell
        
        let obj = self.viewModel.arrayOfPurchasedCityMap[indexPath.row]
        cell.lbl_MapName.text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
        cell.lbl_Amount.text = "\(obj.city_map_price ?? "") SAR for \(obj.city_map_month ?? "") \(R.string.localizable.month())"
        cell.lbl_AboutCity.text = L102Language.currentAppleLanguage() == "en" ? obj.about_city ?? "" : obj.about_city_ar ?? ""
        cell.lbl_ExpiryDate.text = "\(R.string.localizable.expiryDate()): \(obj.exp_date ?? "")"
//        cell.btn_CancelPackageOt.setTitle("\(obj.exp_date ?? "")", for: .normal)
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

