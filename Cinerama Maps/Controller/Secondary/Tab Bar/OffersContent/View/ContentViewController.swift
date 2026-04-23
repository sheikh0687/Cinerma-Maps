//
//  ContentViewController.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 23/08/24.
//

import UIKit

class ContentViewController: UIViewController {

//    let identifier = "DiscountCell"
//    var arrOfferSubCategory: [Company_offer] = []
//    var arrayOfFilteresCategory: [Company_offer] = []
//    
//    var obj_TableVw: UITableView!
//    var uiSearchBar: UISearchBar!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        uiSearchBar.delegate = self
//        self.uiSearchBar.showsScopeBar = true
//        self.uiSearchBar.returnKeyType = .done
//    }
//    
//    convenience init(index: String, arrOfferSubCategory: [Company_offer], catId : String, uisearchBar: UISearchBar) {
//        self.init(title: "\(index)", arrSub: arrOfferSubCategory, catId: catId, uisearchBar: uisearchBar)
//    }
//    
//    convenience init(title: String, arrOfferSubCategory: [Company_offer], catId : String, uisearchBar: UISearchBar) {
//        self.init(title: title, arrSub: arrOfferSubCategory, catId: catId, uisearchBar: uisearchBar)
//    }
//    
//    init(title: String, arrSub: [Company_offer], catId : String, uisearchBar: UISearchBar) {
//        super.init(nibName: nil, bundle: nil)
//        self.title = title
//        let tableView = UITableView(frame: .zero)
//        tableView.backgroundColor = .systemGroupedBackground
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
//        tableView.separatorStyle = .none
//        self.arrOfferSubCategory = arrSub
//        self.arrayOfFilteresCategory = arrSub
//        obj_TableVw = tableView
//        self.uiSearchBar = uisearchBar
//        tableView.reloadData()
//        view.addSubview(tableView)
//        view.backgroundColor = .clear
//        view.constrainToEdgesAfterMargin(tableView, after: 10)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}

//extension ContentViewController: UITableViewDataSource, UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.arrOfferSubCategory.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscountCell", for: indexPath) as! DiscountCell
//        
//        let obj = self.arrOfferSubCategory[indexPath.row]
//        
//        cell.offer_CodeAndPercent.setTitle("\(obj.discount_code ?? "") \(obj.discount_percentage ?? "")% Off", for: .normal)
//        
//        if L102Language.currentAppleLanguage() == "en" {
//            cell.lbl_OfferDescription.text = obj.company_name ?? ""
//        } else {
//            cell.lbl_OfferDescription.text = obj.company_name_ar ?? ""
//        }
//        
//        if Router.BASE_IMAGE_URL != obj.image {
//            Utility.setImageWithSDWebImage(obj.image ?? "", cell.offer_Img)
//        } else {
//            cell.offer_Img.image = R.image.blank()
//        }
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 180
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GuidelinesVC") as! GuidelinesVC
//        let obj = self.arrOfferSubCategory[indexPath.row]
//        if L102Language.currentAppleLanguage() == "en" {
//            vC.titleVal = obj.company_name ?? ""
//            vC.descriptionVal = obj.description ?? ""
//            vC.placeImg = obj.image ?? ""
//            vC.offerCode = "\(obj.discount_code ?? "") \(obj.discount_percentage ?? "")% Off"
//            vC.isFrom = "Offers"
//        } else {
//            vC.titleVal = obj.company_name_ar ?? ""
//            vC.descriptionVal = obj.description_ar ?? ""
//            vC.placeImg = obj.image ?? ""
//            vC.offerCode = "\(obj.discount_code ?? "") \(obj.discount_percentage ?? "")% Off"
//            vC.isFrom = "Offers"
//        }
//        navigationController?.pushViewController(vC, animated: true)
//
//    }
//}
//
//extension ContentViewController: UISearchBarDelegate {
//    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText.isEmpty {
//            arrOfferSubCategory = arrayOfFilteresCategory
//        } else {
//            arrOfferSubCategory = arrayOfFilteresCategory.filter {
//                $0.company_name?.range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil
//            }
//        }
//        self.obj_TableVw.reloadData()
//    }
//    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        self.uiSearchBar.endEditing(true)
//    }
//}
