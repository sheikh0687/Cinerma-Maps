//
//  FavVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 22/08/24.
//

import UIKit
import SkeletonView

class FavVC: UIViewController {

    @IBOutlet weak var fav_TableVw: UITableView!
    @IBOutlet weak var search_Bar: UISearchBar!
    
    let viewModel = FavCityMapViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fav_TableVw.isSkeletonable = true
        
        setupSearchBar()
        
        self.fav_TableVw.register(UINib(nibName: "CityMapCell", bundle: nil), forCellReuseIdentifier: "CityMapCell")
        
        self.setUpBindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func setupSearchBar() {
        search_Bar.placeholder = R.string.localizable.search()
        search_Bar.barTintColor = UIColor.white
        search_Bar.searchTextField.backgroundColor = UIColor.white
        search_Bar.searchTextField.textColor = UIColor.black
        
        if let clearButton = search_Bar.searchTextField.value(forKey: "_clearButton") as? UIButton {
            clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        }
        
        search_Bar.layer.cornerRadius = 10
        search_Bar.layer.masksToBounds = true
        search_Bar.delegate = self
        self.search_Bar.showsScopeBar = true
        self.search_Bar.returnKeyType = .done
    }
    
    func setUpBindViewModel() {
        viewModel.isLoading = true
        fav_TableVw.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .systemGray5))
        
        self.viewModel.fetchFavCityMap(vC: self)
        self.viewModel.fetchedSuccessfull = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                self.viewModel.isLoading = false
                
                self.fav_TableVw.stopSkeletonAnimation()
                self.fav_TableVw.hideSkeleton(reloadDataAfter: true)
                self.fav_TableVw.reloadData()
            }
        }
    }
}

extension FavVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.arrayOfFavCityMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityMapCell", for: indexPath) as! CityMapCell
        
        let obj = self.viewModel.arrayOfFavCityMap[indexPath.row]
                
        if L102Language.currentAppleLanguage() == "en" {
            cell.lbl_CountryName.text = obj.name ?? ""
        } else {
            cell.lbl_CountryName.text = obj.name_ar ?? ""
        }
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
            self.viewModel.fetchedSuccessfull = { [] in
                self.setUpBindViewModel()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = self.viewModel.arrayOfFavCityMap[indexPath.row]
        if obj.subscription_status == "Yes" {
            viewModel.navigateToSubscriptionViewController(from: self.navigationController, cityId: obj.id ?? "")
        } else {
            viewModel.navigateToCityMapsDetailViewController(from: self.navigationController, cityId: obj.id ?? "", isSubscribed: obj.subscription_status ?? "",cityName: obj.name ?? "", cityAmount: obj.city_map_price ?? "", cityRating: obj.avg_rating ?? "", cityAddress: obj.address ?? "", cityMonth: obj.city_map_month ?? "", cityLat: obj.lat ?? "", cityLon: obj.lon ?? "", countryiD: obj.country_id ?? "", cityImg: obj.image ?? "")
        }
    }
}

extension FavVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.viewModel.arrayOfFavCityMap = self.viewModel.arrayOfFilteredFav
        } else {
            self.viewModel.arrayOfFavCityMap = self.viewModel.arrayOfFilteredFav.filter {
                $0.name?.range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil
            }
        }
        self.fav_TableVw.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.search_Bar.endEditing(true)
    }
}

extension FavVC: SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "CityMapCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 // ✅ Show 4 shimmer placeholders while loading
    }
}
