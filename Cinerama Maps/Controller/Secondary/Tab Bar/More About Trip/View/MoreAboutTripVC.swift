//
//  MoreAboutTripVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 14/11/24.
//

import UIKit

class MoreAboutTripVC: UIViewController {

    @IBOutlet weak var table_Vw: UITableView!
//    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    let viewModel: MoreAboutTripVM
    
    init(viewModel: MoreAboutTripVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        // Provide a default ViewModel to avoid crash
        self.viewModel = MoreAboutTripVM()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table_Vw.register(UINib(nibName: "MoreAboutTripCell", bundle: nil), forCellReuseIdentifier: "MoreAboutTripCell")
        table_Vw.estimatedRowHeight = 100
        table_Vw.rowHeight = UITableView.automaticDimension
        table_Vw.sectionHeaderHeight = UITableView.automaticDimension
        table_Vw.estimatedSectionHeaderHeight = 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBinding()
    }

    @IBAction func btn_Back(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupBinding()
    {
        viewModel.fetchMoreAboutTrip(vC: self)
        viewModel.fetchSuccessfully = { [] in
            self.table_Vw.reloadData()
        }
    }
}

extension MoreAboutTripVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.arrayOfMoreTrip.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.arrayOfMoreTrip[section].day_wise_trip?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreAboutTripCell", for: indexPath) as! MoreAboutTripCell
        
        let obj = self.viewModel.arrayOfMoreTrip[indexPath.section].day_wise_trip?[indexPath.row]
        
        cell.lbl_Address.text = obj?.address ?? ""
        cell.lbl_Distance.text = "\(obj?.distance ?? "") \(R.string.localizable.awayFromYou())"
        cell.lbl_Time.text = "\(obj?.time ?? "")"
        cell.lbl_CityName.text = obj?.trip_name ?? ""
        
        if obj?.trip_by_cineramap == "Yes" {
            cell.lbl_CretedByCNRM.isHidden = false
        } else {
            cell.lbl_CretedByCNRM.isHidden = true
        }
        
        cell.cloEdit = { [self] in
            self.viewModel.navigateToPlaceTableViewController(from: self.navigationController, tripID: obj?.id ?? "", cityId: obj?.place_id ?? "")
        }
        
        cell.cloDelete = { [] in
            self.viewModel.deleteTripSchedule(vC: self, cityiD: obj?.id ?? "")
            self.viewModel.fetchSuccessfully = { [] in
                self.setupBinding()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let day = self.viewModel.arrayOfMoreTrip[section]
        return  day.day_name
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 0.67, green: 0.27, blue: 0.27, alpha: 1.0) // Custom color
        
        let label = UILabel()
        if L102Language.currentAppleLanguage() == "en" {
            label.text = self.viewModel.arrayOfMoreTrip[section].day_name
        } else {
            label.text = self.viewModel.arrayOfMoreTrip[section].day_name_ar
        }
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
