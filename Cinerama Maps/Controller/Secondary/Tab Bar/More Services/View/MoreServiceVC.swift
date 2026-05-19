//
//  MoreServiceVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 16/11/24.
//

import UIKit

class MoreServiceVC: UIViewController {
    
    @IBOutlet weak var table_View: UITableView!
    @IBOutlet weak var btn_CompanyOt: UIButton!
    @IBOutlet weak var btn_CityOt: UIButton!
    @IBOutlet weak var search: UISearchBar!
    
    var arrayOfServices: [Res_Services] = []
    var arrayOfFilteredService: [Res_Services] = []
    var dependonUi:String = "Company"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.table_View.register(UINib(nibName: "MoreServiceCell", bundle: nil), forCellReuseIdentifier: "MoreServiceCell")
//        fetchServiceDetails("Company")
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    private func setupSearchBar() {
        search.placeholder = R.string.localizable.search()
        search.barTintColor = UIColor.white
        search.searchTextField.backgroundColor = UIColor.white
        search.searchTextField.textColor = UIColor.black
        
        if let clearButton = search.searchTextField.value(forKey: "_clearButton") as? UIButton {
            clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        }
        
        search.layer.cornerRadius = 10
        search.layer.masksToBounds = true
        search.delegate = self
        self.search.showsScopeBar = true
        self.search.returnKeyType = .done
    }
    
    @IBAction func btn_Company(_ sender: UIButton) {
        self.dependonUi = "Company"
        btn_CompanyOt.setTitleColor(.white, for: .normal)
        btn_CompanyOt.backgroundColor = R.color.main()
        btn_CityOt.setTitleColor(R.color.main(), for: .normal)
        btn_CityOt.backgroundColor = .clear
//        fetchServiceDetails("Company")
        self.table_View.reloadData()
    }
    
    @IBAction func btn_City(_ sender: UIButton) {
        self.dependonUi = "City"
        btn_CityOt.setTitleColor(.white, for: .normal)
        btn_CityOt.backgroundColor = R.color.main()
        btn_CompanyOt.setTitleColor(R.color.main(), for: .normal)
        btn_CompanyOt.backgroundColor = .clear
//        fetchServiceDetails("City")
        self.table_View.reloadData()
    }
    
    @IBAction func btn_Back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MoreServiceVC {
    
//    func fetchServiceDetails(_ type: String)
//    {
//        var paramDict: [String : AnyObject] = [:]
//        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
//        paramDict["type"] = type as AnyObject
//        
//        Api.shared.requestAllServices(self, paramDict) { responseData in
//            if responseData.status == "1" {
//                self.arrayOfServices = responseData.result ?? []
//                self.arrayOfFilteredService = responseData.result ?? []
//            } else {
//                self.arrayOfServices = []
//                self.arrayOfFilteredService = []
//            }
//            self.table_View.reloadData()
//        }
//    }
}

extension MoreServiceVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfServices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreServiceCell", for: indexPath) as! MoreServiceCell
        if dependonUi == "Company" {
            let obj = self.arrayOfServices[indexPath.row]
            cell.view_Company.isHidden = false
            cell.lbl_Title.text = obj.company_name ?? ""
            cell.lbl_CompanyName.text = obj.address ?? ""
            
            let html = obj.description ?? ""
            
            if let attributedText = html.htmlAttributedString3 {
                cell.lbl_Description.attributedText = attributedText
            }
            
            if Router.BASE_IMAGE_URL != obj.image1 {
                Utility.setImageWithSDWebImage(obj.image1 ?? "", cell.company_Img)
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailVC
        let obj = self.arrayOfServices[indexPath.row]
        vC.viewModel.service_ID = obj.id ?? ""
        navigationController?.pushViewController(vC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dependonUi == "Company" {
            return 200
        } else {
            return 120
        }
    }
}

extension MoreServiceVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.arrayOfServices = arrayOfFilteredService
        } else {
            arrayOfServices = arrayOfFilteredService.filter {
                $0.company_name?.range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil
            }
        }
        self.table_View.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.search.endEditing(true)
    }
}
