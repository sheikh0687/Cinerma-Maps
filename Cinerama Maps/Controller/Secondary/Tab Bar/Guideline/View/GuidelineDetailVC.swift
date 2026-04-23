//
//  GuidelineDetailVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 18/12/24.
//

import UIKit

class GuidelineDetailVC: UIViewController {

//    MARK: PROPERTIES
    @IBOutlet weak var guidelineCollectionVw: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var mainCategoryCollectionVw: UICollectionView!
    @IBOutlet weak var subCategoryCollectionVw: UICollectionView!
    @IBOutlet weak var childCategoryCollectionVw: UICollectionView!

    @IBOutlet weak var btn_NonSubscribeOt: UIButton!
    @IBOutlet weak var btn_SubscribeOt: UIButton!
    
    @IBOutlet weak var lbl_CityName: UILabel!
    @IBOutlet weak var btnDropOt: UIButton!
    @IBOutlet weak var btn_AllCategory: UIButton!
    
    @IBOutlet weak var categoryStackVw: UIView!
    
    //    MARK: DECLARATION
    let viewModel = GuidelineTipApiViewModel()
    let subscriberVM = SubscriberViewModel()
    
    var isFor: String = "NonSubscriber"
    
    var selectedMainIndex: IndexPath?
    var selectedSubIndex: IndexPath?
    var selectedChildIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.setupSearchBar(for: searchBar)
        self.lbl_CityName.font = UIFont(name: "Avenir-Heavy", size: 14)
        self.guidelineCollectionVw.register(UINib(nibName: "GuidelineCell", bundle: nil), forCellWithReuseIdentifier: "GuidelineCell")
        
        self.mainCategoryCollectionVw.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        self.subCategoryCollectionVw.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        self.childCategoryCollectionVw.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        
        self.searchBar.delegate = self
        self.searchBar.showsScopeBar = true
        self.searchBar.returnKeyType = .done
        
        setSubscriberView(strCatiD: "", strSubCatiD: "", strChildCatiD: "")
        setUpCityNames()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func btn_Back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_CityName(_ sender: UIButton) {
        subscriberVM.dropDown.show()
    }
        
    @IBAction func btn_All(_ sender: UIButton) {
        sender.backgroundColor = R.color.main()
        sender.setTitleColor(.white, for: .normal)
        
        // Clear all selections
        selectedMainIndex = nil
        selectedSubIndex = nil
        selectedChildIndex = nil

        // Refresh UI
        mainCategoryCollectionVw.reloadData()
        subCategoryCollectionVw.isHidden = true
        childCategoryCollectionVw.isHidden = true

        setSubscriberView(strCatiD: "", strSubCatiD: "", strChildCatiD: "")
    }
}

// MARK: NETWORK MANAGMENT
extension GuidelineDetailVC {
    
    private func setUpCityNames()
    {
        subscriberVM.fetchuserSubscriberCity(vC: self, sender: btnDropOt, cityName: lbl_CityName)
        subscriberVM.cloUserSubscribeSuccess = { [weak self] strItem in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if strItem == "Choose City" {
                    self.setSubscriberView(strCatiD: "", strSubCatiD: "", strChildCatiD: "")
                    
                    self.categoryStackVw.isHidden = true
                    self.subCategoryCollectionVw.isHidden = true
                    self.childCategoryCollectionVw.isHidden = true
                    
                    self.selectedMainIndex = nil
                    self.selectedSubIndex = nil
                    self.selectedChildIndex = nil
                } else {
                    self.setUpCityCategory()
                    
                    self.btn_AllCategory.backgroundColor = R.color.main()
                    self.btn_AllCategory.setTitleColor(.white, for: .normal)
                    
                    self.selectedMainIndex = nil
                    self.selectedSubIndex = nil
                    self.selectedChildIndex = nil
                    
                    self.mainCategoryCollectionVw.reloadData()
                    self.subCategoryCollectionVw.isHidden = true
                    self.childCategoryCollectionVw.isHidden = true
                    
                    self.setSubscriberView(strCatiD: "", strSubCatiD: "", strChildCatiD: "")
                }
            }
        }
    }

    private func setUpCityCategory()
    {
        self.subscriberVM.requestToGetSubscriberCat(vC: self, strCity: subscriberVM.cityiD, collectionVw: mainCategoryCollectionVw)
        self.subscriberVM.cloMainCatSuccess = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.categoryStackVw.isHidden = false
                self.mainCategoryCollectionVw.reloadData()
            }
        }
    }
    
    private func setCitySubCategory(strCatiD: String) {
        self.subscriberVM.fetchSubscriberSubCat(catId: strCatiD, vC: self, collectionVw: subCategoryCollectionVw)
        self.subscriberVM.cloSubCatSuccess = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.subCategoryCollectionVw.reloadData()
            }
        }
    }
    
    private func setCityChildCategory(strCatiD: String, strSubiD: String) {
        self.subscriberVM.fetchSubscriberChildCat(subCatId: strSubiD, catiD: strCatiD, vC: self, collectionVw: childCategoryCollectionVw)
        self.subscriberVM.cloChildCatSuccess = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.childCategoryCollectionVw.reloadData()
            }
        }
    }
    
    private func setSubscriberView(strCatiD: String, strSubCatiD: String, strChildCatiD: String) {
        subscriberVM.fetchGuidelineTips(vC: self, catId: strCatiD, subCatId: strSubCatiD, childSubCatId: strChildCatiD, guidelineCollectionVw)
        subscriberVM.fethcedSuccessfully = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.guidelineCollectionVw.reloadData()
            }
        }
    }
}

// MARK: COLLECION VIEW
extension GuidelineDetailVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == guidelineCollectionVw {
            subscriberVM.arrayGuidelinesTip.count
        } else if collectionView == mainCategoryCollectionVw {
            subscriberVM.arrayOfSubscriberCat.count
        } else if collectionView == subCategoryCollectionVw {
            subscriberVM.arrayOfSubscribeSubCat.count
        } else {
            subscriberVM.arrayOfSubChildCat.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == guidelineCollectionVw {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuidelineCell", for: indexPath) as! GuidelineCell
            
            let obj = subscriberVM.arrayGuidelinesTip[indexPath.row]
            
            cell.lbl_Text.text = L102Language.currentAppleLanguage() == "en" ? obj.title ?? "" :
            obj.title_ar ?? ""
            
            if Router.BASE_IMAGE_URL != obj.image {
                Utility.setImageWithSDWebImage(obj.image ?? "", cell.img)
            } else {
                cell.img.image = R.image.blank()
            }
            
            return cell

        } else if collectionView == mainCategoryCollectionVw {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            
            let obj = subscriberVM.arrayOfSubscriberCat[indexPath.row]
            
            cell.lbl_CategoryName.text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
            
            if selectedMainIndex == indexPath {
                cell.backgroundColor = R.color.main()
                cell.lbl_CategoryName.textColor = .white
            } else {
                cell.backgroundColor = .clear
                cell.lbl_CategoryName.textColor = .main
            }
            return cell
        } else if collectionView == subCategoryCollectionVw {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            
            let obj = subscriberVM.arrayOfSubscribeSubCat[indexPath.row]
            
            cell.lbl_CategoryName.text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
            
            if selectedSubIndex == indexPath {
                cell.backgroundColor = R.color.main()
                cell.lbl_CategoryName.textColor = .white
            } else {
                cell.backgroundColor = .clear
                cell.lbl_CategoryName.textColor = .main
            }
            
            return cell

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            
            let obj = subscriberVM.arrayOfSubChildCat[indexPath.row]
            
            cell.lbl_CategoryName.text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
            
            if selectedChildIndex == indexPath {
                cell.backgroundColor = R.color.main()
                cell.lbl_CategoryName.textColor = .white
            } else {
                cell.backgroundColor = .clear
                cell.lbl_CategoryName.textColor = .main
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == guidelineCollectionVw {
            let collectionWidth = collectionView.frame.width
            return CGSize(width: collectionWidth / 2, height: 190)
            
        } else if collectionView == mainCategoryCollectionVw {
            let obj = subscriberVM.arrayOfSubscriberCat[indexPath.row]
            
            let text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
            
            let padding: CGFloat = 20
            
            let textWidth = (text as NSString).size(withAttributes: [.font: UIFont(name: "Avenir-Medium", size: 14)!]).width
            
            return CGSize(width: textWidth + padding, height: collectionView.frame.height)
            
        } else if collectionView == subCategoryCollectionVw {
            let obj = subscriberVM.arrayOfSubscribeSubCat[indexPath.row]
            
            let text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
            
            let padding: CGFloat = 20
            
            let textWidth = (text as NSString).size(withAttributes: [.font: UIFont(name: "Avenir-Medium", size: 14)!]).width
            
            return CGSize(width: textWidth + padding, height: collectionView.frame.height)
            
        } else {
            let obj = subscriberVM.arrayOfSubChildCat[indexPath.row]
            
            let text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
            
            let padding: CGFloat = 20
            
            let textWidth = (text as NSString).size(withAttributes: [.font: UIFont(name: "Avenir-Medium", size: 14)!]).width
            
            return CGSize(width: textWidth + padding, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == guidelineCollectionVw {
            let obj = subscriberVM.arrayGuidelinesTip[indexPath.row]
            self.viewModel.navigateToGuidlineViewController(from: self.navigationController, title: obj.title ?? "", dateTime: obj.date_time ?? "", description: obj.description ?? "", image: obj.image ?? "", isFrom: "Guideline", titleArabic: obj.title_ar ?? "", descriptionArabic: obj.description_ar ?? "")
            
        } else if collectionView == mainCategoryCollectionVw {
            selectedMainIndex = indexPath
            selectedSubIndex = nil
            selectedChildIndex = nil

            let obj = self.subscriberVM.arrayOfSubscriberCat[indexPath.row]
            self.subCategoryCollectionVw.isHidden = false
            self.childCategoryCollectionVw.isHidden = true
            
            self.setCitySubCategory(strCatiD: obj.id ?? "")
            
            self.setSubscriberView(strCatiD: obj.id ?? "", strSubCatiD: k.emptyString, strChildCatiD: k.emptyString)
    
            self.btn_AllCategory.backgroundColor = .clear
            self.btn_AllCategory.setTitleColor(R.color.main(), for: .normal)
            
            self.mainCategoryCollectionVw.reloadData()
            self.subCategoryCollectionVw.reloadData()
            self.childCategoryCollectionVw.reloadData()
            
        } else if collectionView == subCategoryCollectionVw {
            self.selectedSubIndex = indexPath
            self.selectedChildIndex = nil

            let obj = self.subscriberVM.arrayOfSubscribeSubCat[indexPath.row]
            self.childCategoryCollectionVw.isHidden = false
            
            self.setCityChildCategory(strCatiD: obj.cat_id ?? "", strSubiD: obj.id ?? "")
            self.setSubscriberView(strCatiD: obj.cat_id ?? "", strSubCatiD: obj.id ?? "", strChildCatiD: k.emptyString)
            
            self.subCategoryCollectionVw.reloadData()
            self.childCategoryCollectionVw.reloadData()

        } else {
            selectedChildIndex = indexPath
            
            let obj = self.subscriberVM.arrayOfSubChildCat[indexPath.row]
            
            self.setSubscriberView(strCatiD: obj.category_id ?? "", strSubCatiD: obj.sub_cat_id ?? "", strChildCatiD: obj.id ?? "")

            childCategoryCollectionVw.reloadData()
        }
    }
}

// MARK: SEARCH BAR
extension GuidelineDetailVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            subscriberVM.arrayGuidelinesTip = subscriberVM.arrayFilteredGuidelinesTip
        } else {
            subscriberVM.arrayGuidelinesTip = subscriberVM.arrayFilteredGuidelinesTip.filter {
                $0.title?.range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil
            }
        }
        self.guidelineCollectionVw.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
}
