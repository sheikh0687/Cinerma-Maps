//
//  CityMapsVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 27/08/24.
//

import UIKit
import SkeletonView

class CityMapsVC: UIViewController {

    @IBOutlet weak var city_MapTableVw: UITableView!
    @IBOutlet weak var search_Bar: UISearchBar!
    
    @IBOutlet weak var lbl_CountryMapHeading: UILabel!
    @IBOutlet weak var lbl_CountryRepublicText: UILabel!
    
    let viewModel = CityViewModel()
    var countryName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.setupSearchBar(for: search_Bar)
        city_MapTableVw.isSkeletonable = true
        
        self.city_MapTableVw.register(UINib(nibName: "CityMapCell", bundle: nil), forCellReuseIdentifier: "CityMapCell")
        self.lbl_CountryMapHeading.text = "\(countryName) \(R.string.localizable.maps())"
        self.lbl_CountryRepublicText.text = "\(R.string.localizable.cityMapsInTheRepublicOf()) \(countryName)"
        fetchCityMapDetails()
        search_Bar.delegate = self
        self.search_Bar.showsScopeBar = true
        self.search_Bar.returnKeyType = .done
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    @IBAction func btn_Back(_ sender: UIButton) {
        viewModel.returnBackk(from: self.navigationController)
    }
    
    func fetchCityMapDetails() {
        city_MapTableVw.showAnimatedSkeleton()
        
        viewModel.requestCityMapDetails(vC: self)
        viewModel.requestSuccessfull = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.city_MapTableVw.stopSkeletonAnimation()
                self.city_MapTableVw.hideSkeleton()
                
                self.city_MapTableVw.reloadData()
            }
        }
    }
}

extension CityMapsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.arrayOfDetailCityMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityMapCell", for: indexPath) as! CityMapCell
        
        let obj = self.viewModel.arrayOfDetailCityMap[indexPath.row]
        
        cell.lbl_CountryName.text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
        
        cell.lbl_Rating.text = obj.avg_rating ?? ""
        cell.lbl_Address.text = obj.address ?? ""
        cell.rating_Vw.rating = Double(obj.avg_rating ?? "") ?? 0.0
        
        if Router.BASE_IMAGE_URL != obj.image {
            Utility.setImageWithSDWebImage(obj.image ?? "", cell.img)
        } else {
            cell.img.image = R.image.blank()
        }
        
        if obj.fav_status == "Yes" {
            cell.btn_FavOt.tintColor = R.color.main()
        } else {
            cell.btn_FavOt.tintColor = .lightGray
        }
        
        cell.cloFav = { [] in
            self.viewModel.fetchFavAndUnFavMap(vC: self, cityId: obj.id ?? "")
            self.viewModel.requestSuccessfull = { [] in
                self.fetchCityMapDetails()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = self.viewModel.arrayOfDetailCityMap[indexPath.row]
        viewModel.navigateToCityMapsDetailViewController(from: self.navigationController, cityId: obj.id ?? "", isSubscribed: obj.subscription_status ?? "",cityName: L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? "", cityAmount: obj.city_map_price ?? "", cityRating: obj.avg_rating ?? "", cityAddress: obj.address ?? "", cityMonth: obj.city_map_month ?? "", cityLat: obj.lat ?? "", cityLon: obj.lon ?? "", countryiD: obj.country_id ?? "", cityImg: obj.image ?? "")
    }
}

extension CityMapsVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.viewModel.arrayOfDetailCityMap = self.viewModel.arrayOfFilteredDetails
        } else {
            self.viewModel.arrayOfDetailCityMap = self.viewModel.arrayOfFilteredDetails.filter {
                $0.name?.range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil
            }
        }
        self.city_MapTableVw.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.search_Bar.endEditing(true)
    }
}

extension CityMapsVC: SkeletonTableViewDataSource {
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "CityMapCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 // ✅ Show 4 shimmer placeholders while loading
    }
}
