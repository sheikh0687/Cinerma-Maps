//
//  OfferVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 23/08/24.
//

import UIKit
import Parchment
import SnapKit
import SkeletonView

class OfferVC: UIViewController {
    
    // MARK: PROPERTY
    @IBOutlet weak var searchVw: UIView!
    @IBOutlet weak var viewContentPaging: UIView!
    @IBOutlet weak var search_Bar: UISearchBar!
    @IBOutlet weak var serviceTableVw: UITableView!
    
    @IBOutlet weak var btn_TourismOt: UIButton!
    @IBOutlet weak var btn_PartnerOt: UIButton!
    @IBOutlet weak var btn_OfferOt: UIButton!
    @IBOutlet weak var btn_AllCategory: UIButton!
    
    @IBOutlet weak var mainCatCollectionVw: UICollectionView!
    @IBOutlet weak var subCatCollectionVw: UICollectionView!
    @IBOutlet weak var childCatCollectionVw: UICollectionView!
    
    @IBOutlet weak var mainCatStackVw: UIStackView!
    
    var selectedMainIndex: IndexPath?
    var selectedSubIndex: IndexPath?
    var selectedChildIndex: IndexPath?
    
    let viewModel = CompanyOfferViewModel()
    let tourismViewModel = ToursimViewModel()
    let partnerViewModel = PartnerViewModel()
    
    let mainCatRTL = RTLCollectionViewFlowLayout()
    let subCatRTL = RTLCollectionViewFlowLayout()
    let childCatRTL = RTLCollectionViewFlowLayout()
    
    var dependonUi:String = "Tourism"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serviceTableVw.isSkeletonable = true
        
        self.viewModel.setupSearchBar(searchBar: search_Bar)
        self.serviceTableVw.register(UINib(nibName: "MoreServiceCell", bundle: nil), forCellReuseIdentifier: "MoreServiceCell")
        self.serviceTableVw.register(UINib(nibName: "DiscountCell", bundle: nil), forCellReuseIdentifier: "DiscountCell")
        self.serviceTableVw.register(UINib(nibName: "PartnerServiceCell", bundle: nil), forCellReuseIdentifier: "PartnerServiceCell")


        self.mainCatCollectionVw.register(UINib(nibName: "CategoryCell", bundle: nil),forCellWithReuseIdentifier: "CategoryCell")
        self.subCatCollectionVw.register(UINib(nibName: "CategoryCell", bundle: nil),forCellWithReuseIdentifier: "CategoryCell")
        self.childCatCollectionVw.register(UINib(nibName: "CategoryCell", bundle: nil),forCellWithReuseIdentifier: "CategoryCell")
        
        self.mainCatStackVw.isHidden = false
        self.setMainToursimCategory()
        self.setToursimService(strCatiD: "", subCatiD: "", strChildiD: "")
        
        search_Bar.delegate = self
        self.search_Bar.showsScopeBar = true
        self.search_Bar.returnKeyType = .done
        serviceTableVw.rowHeight = UITableView.automaticDimension
        serviceTableVw.estimatedRowHeight = 250
        // ⭐️ This prevents jumpy scroll when heights change
        serviceTableVw.contentInsetAdjustmentBehavior = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func btn_TourismService(_ sender: UIButton) {
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = .main
        btn_PartnerOt.setTitleColor(.main, for: .normal)
        btn_PartnerOt.backgroundColor = .clear
        btn_OfferOt.setTitleColor(.main, for: .normal)
        btn_OfferOt.backgroundColor = .clear
        serviceTableVw.isHidden = false
        self.mainCatStackVw.isHidden = false
        self.dependonUi = "Tourism"
        
        selectedMainIndex = nil
        selectedSubIndex = nil
        selectedChildIndex = nil
        
        // Refresh UI
        mainCatCollectionVw.reloadData()
        subCatCollectionVw.isHidden = true
        childCatCollectionVw.isHidden = true
        
        self.setMainToursimCategory()
        setToursimService(strCatiD: "", subCatiD: "", strChildiD: "")
    }
    
    @IBAction func btn_PartnerService(_ sender: UIButton) {
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = .main
        btn_TourismOt.setTitleColor(.main, for: .normal)
        btn_TourismOt.backgroundColor = .clear
        btn_OfferOt.setTitleColor(.main, for: .normal)
        btn_OfferOt.backgroundColor = .clear
        serviceTableVw.isHidden = false
        self.mainCatStackVw.isHidden = false
        self.dependonUi = "Partner"
        
        selectedMainIndex = nil
        selectedSubIndex = nil
        selectedChildIndex = nil
        
        // Refresh UI
        mainCatCollectionVw.reloadData()
        subCatCollectionVw.isHidden = true
        childCatCollectionVw.isHidden = true
        
        self.setMainPartnerCategory()
        setPartnerService(strCatiD: "", subCatiD: "", strChildiD: "")
    }
    
    @IBAction func btn_Offer(_ sender: UIButton) {
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = .main
        btn_PartnerOt.setTitleColor(.main, for: .normal)
        btn_PartnerOt.backgroundColor = .clear
        btn_TourismOt.setTitleColor(.main, for: .normal)
        btn_TourismOt.backgroundColor = .clear
        serviceTableVw.isHidden = false
        self.mainCatStackVw.isHidden = false
        self.dependonUi = "Offer"
        
        selectedMainIndex = nil
        selectedSubIndex = nil
        selectedChildIndex = nil
        
        // Refresh UI
        mainCatCollectionVw.reloadData()
        subCatCollectionVw.isHidden = true
        childCatCollectionVw.isHidden = true
        
        self.setMainOfferCatgory()
        self.setUpComanyOffers(strCatiD: k.emptyString, strSubCatiD: k.emptyString, strChildiD: k.emptyString)
    }
    
    @IBAction func btn_AllCategory(_ sender: UIButton) {
        sender.backgroundColor = R.color.main()
        sender.setTitleColor(.white, for: .normal)
        
        // Clear all selections
        selectedMainIndex = nil
        selectedSubIndex = nil
        selectedChildIndex = nil
        
        // Refresh UI
        mainCatCollectionVw.reloadData()
        subCatCollectionVw.isHidden = true
        childCatCollectionVw.isHidden = true
        
        // Call API with empty filters
        if dependonUi == "Tourism" {
            setToursimService(strCatiD: "", subCatiD: "", strChildiD: "")
        } else if dependonUi == "Partner" {
            setPartnerService(strCatiD: "", subCatiD: "", strChildiD: "")
        } else {
            setUpComanyOffers(strCatiD: "", strSubCatiD: "", strChildiD: "")
        }
    }
}

// MARK: TOURISM OFFER NETWORK
extension OfferVC {
    
    private func setMainToursimCategory() {
        tourismViewModel.fetchTourismMainCategory(vC: self, collectionvW: mainCatCollectionVw)
        tourismViewModel.cloTourismMainCatSuccessfully = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if L102Language.currentAppleLanguage() == "ar" {
                    self.mainCatRTL.scrollDirection = .horizontal
                    self.mainCatCollectionVw.collectionViewLayout = self.mainCatRTL
                    self.mainCatCollectionVw.semanticContentAttribute = .forceLeftToRight
                }
                self.mainCatCollectionVw.reloadData()
            }
        }
    }
    
    private func setSubToursimCategory(strCatiD: String) {
        tourismViewModel.fetchTourismSubCategory(vC: self, strCatiD, collectionVw: subCatCollectionVw)
        tourismViewModel.cloTourismSubCatSuccessfully = { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if L102Language.currentAppleLanguage() == "ar" {
                    self.subCatRTL.scrollDirection = .horizontal
                    self.subCatCollectionVw.collectionViewLayout = self.subCatRTL
                    self.subCatCollectionVw.semanticContentAttribute = .forceLeftToRight
                }
                self.subCatCollectionVw.reloadData()
            }
        }
    }
    
    private func setChildToursimCategory(strCatiD: String, strSubCatiD: String) {
        tourismViewModel.fetchTourismChildCategory(vC: self, strCatiD, subCatiD: strSubCatiD, collectionVw: childCatCollectionVw)
        tourismViewModel.cloTourismChildCatSuccessfully = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if L102Language.currentAppleLanguage() == "ar" {
                    self.childCatRTL.scrollDirection = .horizontal
                    self.childCatCollectionVw.collectionViewLayout = self.childCatRTL
                    self.childCatCollectionVw.semanticContentAttribute = .forceLeftToRight
                }
                self.childCatCollectionVw.reloadData()
            }
        }
    }
    
    private func setToursimService(strCatiD: String, subCatiD: String, strChildiD: String) {
        serviceTableVw.showAnimatedSkeleton()
        
        tourismViewModel.fetchToursimServiceDetails(vC: self, catiD: strCatiD, subCatiD: subCatiD, childiD: strChildiD, tableVw: serviceTableVw)
        tourismViewModel.cloTourismServiceSuccessfully = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                
                self.serviceTableVw.stopSkeletonAnimation()
                self.serviceTableVw.hideSkeleton()

                self.serviceTableVw.reloadData()
            }
        }
    }
}

// MARK: PARTNER OFFER NETWORK
extension OfferVC {
    
    private func setMainPartnerCategory() {
        partnerViewModel.fetchPartnerMainCategory(vC: self, collectionVw: mainCatCollectionVw)
        partnerViewModel.cloPartnerMainCatSuccessful = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if L102Language.currentAppleLanguage() == "ar" {
                    self.mainCatRTL.scrollDirection = .horizontal
                    self.mainCatCollectionVw.collectionViewLayout = self.mainCatRTL
                    self.mainCatCollectionVw.semanticContentAttribute = .forceLeftToRight
                }
                self.mainCatCollectionVw.reloadData()
            }
        }
    }
    
    private func setPartnerSubCategory(strCatiD: String) {
        partnerViewModel.fetchPartnerSubCategory(vC: self, strCatiD, collectionVw: subCatCollectionVw)
        partnerViewModel.cloPartnerSubCatSuccessful = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if L102Language.currentAppleLanguage() == "ar" {
                    self.subCatRTL.scrollDirection = .horizontal
                    self.subCatCollectionVw.collectionViewLayout = self.subCatRTL
                    self.subCatCollectionVw.semanticContentAttribute = .forceLeftToRight
                }
                self.subCatCollectionVw.reloadData()
            }
        }
    }
    
    private func setPartnerChildCategory(strCatiD: String, strSubCatiD: String) {
        partnerViewModel.fetchPartnerChildCategory(vC: self, strCatiD, subCatiD: strSubCatiD, collectionVw: childCatCollectionVw)
        partnerViewModel.cloPartnerChildCatSuccessfull = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if L102Language.currentAppleLanguage() == "ar" {
                    self.childCatRTL.scrollDirection = .horizontal
                    self.childCatCollectionVw.collectionViewLayout = self.childCatRTL
                    self.childCatCollectionVw.semanticContentAttribute = .forceLeftToRight
                }
                self.childCatCollectionVw.reloadData()
            }
        }
    }
    
    private func setPartnerService(strCatiD: String, subCatiD: String, strChildiD: String) {
        serviceTableVw.showAnimatedSkeleton()
        
        partnerViewModel.fetchPartnerServiceDetails(vC: self, catiD: strCatiD, subCatiD: subCatiD, childiD: strChildiD, tableVw: serviceTableVw)
        partnerViewModel.fetchedPartnerServiceSuccessfully = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.serviceTableVw.stopSkeletonAnimation()
                self.serviceTableVw.hideSkeleton()
                
                self.serviceTableVw.reloadData()
            }
        }
    }
}

// MARK: COMPANY OFFER NETWORK
extension OfferVC {
    
    private func setMainOfferCatgory() {
        viewModel.fetchMainOfferCategory(vC: self, collectionVw: mainCatCollectionVw)
        viewModel.cloMainOfferSuccessful = { [] in
            DispatchQueue.main.async {
                if L102Language.currentAppleLanguage() == "ar" {
                    self.mainCatRTL.scrollDirection = .horizontal
                    self.mainCatCollectionVw.collectionViewLayout = self.mainCatRTL
                    self.mainCatCollectionVw.semanticContentAttribute = .forceLeftToRight
                }
                self.mainCatCollectionVw.reloadData()
            }
        }
    }
    
    private func setSubofferCategory(strCatiD: String)
    {
        viewModel.requestSubOfferCategory(vC: self, catiD: strCatiD, collectionVw: subCatCollectionVw)
        viewModel.cloSubOfferSuccessful = { [] in
            DispatchQueue.main.async {
                if L102Language.currentAppleLanguage() == "ar" {
                    self.subCatRTL.scrollDirection = .horizontal
                    self.subCatCollectionVw.collectionViewLayout = self.subCatRTL
                    self.subCatCollectionVw.semanticContentAttribute = .forceLeftToRight
                }
                self.subCatCollectionVw.reloadData()
            }
        }
    }
    
    private func setChildOfferCategory(strCatiD: String, strSubCatiD: String)
    {
        viewModel.requestChildOfferCategory(vC: self, catiD: strCatiD, subCatiD: strSubCatiD, collectionVw: childCatCollectionVw)
        viewModel.cloChildOfferSuccessfull = { [] in
            DispatchQueue.main.async {
                if L102Language.currentAppleLanguage() == "ar" {
                    self.childCatRTL.scrollDirection = .horizontal
                    self.childCatCollectionVw.collectionViewLayout = self.childCatRTL
                    self.childCatCollectionVw.semanticContentAttribute = .forceLeftToRight
                }
                self.childCatCollectionVw.reloadData()
            }
        }
    }
    
    private func setUpComanyOffers(strCatiD: String, strSubCatiD: String, strChildiD: String) {
        serviceTableVw.showAnimatedSkeleton()
        
        viewModel.requestCompanyOffer(vC: self, catiD: strCatiD,subCatiD: strSubCatiD, childiD: strChildiD, tableView: self.serviceTableVw)
        viewModel.fetchedSuccessfully = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.serviceTableVw.stopSkeletonAnimation()
                self.serviceTableVw.hideSkeleton()

                self.serviceTableVw.reloadData()
            }
        }
    }
}

// MARK: COLLECTION VIEW
extension OfferVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if dependonUi == "Tourism" {
            // MARKS Toursim Service
            if collectionView == mainCatCollectionVw {
                return tourismViewModel.arrayToursimMainCat.count
            } else if collectionView == subCatCollectionVw {
                return tourismViewModel.arrayTourismSubCat.count
            } else {
                return tourismViewModel.arrayTourismChildCat.count
            }
        } else if dependonUi == "Partner" {
            // MARKS Partner Service
            if collectionView == mainCatCollectionVw {
                return partnerViewModel.arrayOfPartnerMainCategory.count
            } else if collectionView == subCatCollectionVw {
                return partnerViewModel.arrayOfPartnerSubCategory.count
            } else {
                return partnerViewModel.arrayOfPartnerChildCategory.count
            }
        } else {
            // MARKS Offer Service
            if collectionView == mainCatCollectionVw {
                return viewModel.arrayOfMainOfferCat.count
            } else if collectionView == subCatCollectionVw {
                return viewModel.arrayOfSubOfferCat.count
            } else {
                return viewModel.arrayOfChildOfferCat.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        if dependonUi == "Tourism" {
            // MARKS Toursim Service
            if collectionView == mainCatCollectionVw {
                let obj = self.tourismViewModel.arrayToursimMainCat[indexPath.item]
                
                cell.lbl_CategoryName.text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
                
                if selectedMainIndex == indexPath {
                    cell.backgroundColor = R.color.main()
                    cell.lbl_CategoryName.textColor = .white
                } else {
                    cell.backgroundColor = .clear
                    cell.lbl_CategoryName.textColor = .main
                }
                
            } else if collectionView == subCatCollectionVw {
                let obj = self.tourismViewModel.arrayTourismSubCat[indexPath.item]
                
                cell.lbl_CategoryName.text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
                
                if selectedSubIndex == indexPath {
                    cell.backgroundColor = R.color.main()
                    cell.lbl_CategoryName.textColor = .white
                } else {
                    cell.backgroundColor = .clear
                    cell.lbl_CategoryName.textColor = .main
                }
                
            } else {
                let obj = self.tourismViewModel.arrayTourismChildCat[indexPath.item]
                
                cell.lbl_CategoryName.text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
                
                if selectedChildIndex == indexPath {
                    cell.backgroundColor = R.color.main()
                    cell.lbl_CategoryName.textColor = .white
                } else {
                    cell.backgroundColor = .clear
                    cell.lbl_CategoryName.textColor = .main
                }
            }
            return cell
            
        } else if dependonUi == "Partner" {
            // MARKS Partner Service
            if collectionView == mainCatCollectionVw {
                let obj = self.partnerViewModel.arrayOfPartnerMainCategory[indexPath.item]
                
                cell.lbl_CategoryName.text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
                
                if selectedMainIndex == indexPath {
                    cell.backgroundColor = R.color.main()
                    cell.lbl_CategoryName.textColor = .white
                } else {
                    cell.backgroundColor = .clear
                    cell.lbl_CategoryName.textColor = .main
                }
            } else if collectionView == subCatCollectionVw {
                let obj = self.partnerViewModel.arrayOfPartnerSubCategory[indexPath.item]
                
                cell.lbl_CategoryName.text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
                
                if selectedSubIndex == indexPath {
                    cell.backgroundColor = R.color.main()
                    cell.lbl_CategoryName.textColor = .white
                } else {
                    cell.backgroundColor = .clear
                    cell.lbl_CategoryName.textColor = .main
                }
            } else {
                let obj = self.partnerViewModel.arrayOfPartnerChildCategory[indexPath.item]
                
                cell.lbl_CategoryName.text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
                
                if selectedChildIndex == indexPath {
                    cell.backgroundColor = R.color.main()
                    cell.lbl_CategoryName.textColor = .white
                } else {
                    cell.backgroundColor = .clear
                    cell.lbl_CategoryName.textColor = .main
                }
            }
            return cell
        } else {
            // MARKS Company Offer Service
            if collectionView == mainCatCollectionVw {
                let obj = self.viewModel.arrayOfMainOfferCat[indexPath.item]
                
                cell.lbl_CategoryName.text = L102Language.currentAppleLanguage() == "en" ? obj.category_name ?? "" : obj.category_name_ar ?? ""
                
                if selectedMainIndex == indexPath {
                    cell.backgroundColor = R.color.main()
                    cell.lbl_CategoryName.textColor = .white
                } else {
                    cell.backgroundColor = .clear
                    cell.lbl_CategoryName.textColor = .main
                }
                
            } else if collectionView == subCatCollectionVw {
                let obj = self.viewModel.arrayOfSubOfferCat[indexPath.item]
                
                cell.lbl_CategoryName.text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
                
                if selectedSubIndex == indexPath {
                    cell.backgroundColor = R.color.main()
                    cell.lbl_CategoryName.textColor = .white
                } else {
                    cell.backgroundColor = .clear
                    cell.lbl_CategoryName.textColor = .main
                }
                
            } else {
                let obj = self.viewModel.arrayOfChildOfferCat[indexPath.item]
                
                cell.lbl_CategoryName.text = L102Language.currentAppleLanguage() == "en" ? obj.name ?? "" : obj.name_ar ?? ""
                
                if selectedChildIndex == indexPath {
                    cell.backgroundColor = R.color.main()
                    cell.lbl_CategoryName.textColor = .white
                } else {
                    cell.backgroundColor = .clear
                    cell.lbl_CategoryName.textColor = .main
                }
                
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var text = ""
        let font = UIFont(name: "Avenir-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        let padding: CGFloat = 16
        
        if dependonUi == "Tourism" {
            if collectionView == mainCatCollectionVw {
                text = L102Language.currentAppleLanguage() == "en" ? tourismViewModel.arrayToursimMainCat[indexPath.item].name ?? "" : tourismViewModel.arrayToursimMainCat[indexPath.item].name_ar ?? ""
            } else if collectionView == subCatCollectionVw {
                text = L102Language.currentAppleLanguage() == "en" ? tourismViewModel.arrayTourismSubCat[indexPath.item].name ?? "" : tourismViewModel.arrayTourismSubCat[indexPath.item].name_ar ?? ""
            } else {
                text = L102Language.currentAppleLanguage() == "en" ? tourismViewModel.arrayTourismChildCat[indexPath.item].name ?? "" : tourismViewModel.arrayTourismChildCat[indexPath.item].name_ar ?? ""
            }
        } else if dependonUi == "Partner" {
            if collectionView == mainCatCollectionVw {
                text = L102Language.currentAppleLanguage() == "en" ? partnerViewModel.arrayOfPartnerMainCategory[indexPath.item].name ?? "" : partnerViewModel.arrayOfPartnerMainCategory[indexPath.item].name_ar ?? ""
            } else if collectionView == subCatCollectionVw {
                text = L102Language.currentAppleLanguage() == "en" ? partnerViewModel.arrayOfPartnerSubCategory[indexPath.item].name ?? "" : partnerViewModel.arrayOfPartnerSubCategory[indexPath.item].name_ar ?? ""
            } else {
                text = L102Language.currentAppleLanguage() == "en" ? partnerViewModel.arrayOfPartnerChildCategory[indexPath.item].name ?? "" : partnerViewModel.arrayOfPartnerChildCategory[indexPath.item].name_ar ?? ""
            }
        } else {
            if collectionView == mainCatCollectionVw {
                text = L102Language.currentAppleLanguage() == "en" ? viewModel.arrayOfMainOfferCat[indexPath.item].category_name ?? "" : viewModel.arrayOfMainOfferCat[indexPath.item].category_name_ar ?? ""
            } else if collectionView == subCatCollectionVw {
                text = L102Language.currentAppleLanguage() == "en" ? viewModel.arrayOfSubOfferCat[indexPath.item].name ?? "" : viewModel.arrayOfSubOfferCat[indexPath.item].name_ar ?? ""
            } else {
                text = L102Language.currentAppleLanguage() == "en" ? viewModel.arrayOfChildOfferCat[indexPath.item].name ?? "" : viewModel.arrayOfChildOfferCat[indexPath.item].name_ar ?? ""
            }
        }
        
        // MARK: Calculate the width based on text size
        let label = UILabel()
        label.font = font
        label.text = text
        label.sizeToFit()
        
        let calculatedWidth = label.frame.width
        let finalWidth = calculatedWidth + padding
        
        print("""
                 Text: "\(text)"
                 Text width: \(calculatedWidth)
                 Cell width: \(finalWidth)
                 """)
        
        return CGSize(width: finalWidth, height: collectionView.frame.height)
        
        // Measure text width with the font from Storyboard
        //        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
        
        //        return CGSize(width: textWidth + padding, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if dependonUi == "Tourism" {
            // Mark: Toursim Offer
            if collectionView == mainCatCollectionVw {
                guard indexPath.row < self.tourismViewModel.arrayToursimMainCat.count else { return }
                
                selectedMainIndex = indexPath
                selectedSubIndex = nil
                selectedChildIndex = nil
                
                let obj = self.tourismViewModel.arrayToursimMainCat[indexPath.row]
                self.subCatCollectionVw.isHidden = false
                self.childCatCollectionVw.isHidden = true
                
                self.setSubToursimCategory(strCatiD: obj.id ?? "")
                self.setToursimService(strCatiD: obj.id ?? "", subCatiD: k.emptyString, strChildiD: k.emptyString)
                
                self.btn_AllCategory.backgroundColor = .clear
                self.btn_AllCategory.setTitleColor(R.color.main(), for: .normal)
                
                mainCatCollectionVw.reloadData()
                subCatCollectionVw.reloadData()
                childCatCollectionVw.reloadData()
                
            } else if collectionView == subCatCollectionVw {
                guard indexPath.row < self.tourismViewModel.arrayTourismSubCat.count else { return }
                
                selectedSubIndex = indexPath
                selectedChildIndex = nil
                
                let obj = self.tourismViewModel.arrayTourismSubCat[indexPath.row]
                self.childCatCollectionVw.isHidden = false
                
                self.setChildToursimCategory(strCatiD: obj.cat_id ?? "", strSubCatiD: obj.id ?? "")
                self.setToursimService(strCatiD: obj.cat_id ?? "", subCatiD: obj.id ?? "", strChildiD: k.emptyString)
                
                subCatCollectionVw.reloadData()
                childCatCollectionVw.reloadData()
                
            } else {
                guard indexPath.row < self.tourismViewModel.arrayTourismChildCat.count else { return }
                
                selectedChildIndex = indexPath
                
                let obj = self.tourismViewModel.arrayTourismChildCat[indexPath.row]
                self.setToursimService(strCatiD: obj.category_id ?? "", subCatiD: obj.sub_cat_id ?? "", strChildiD: obj.id ?? "")
                
                childCatCollectionVw.reloadData()
            }
            
        } else if dependonUi == "Partner" {
            // MARKS Partner Service
            if collectionView == mainCatCollectionVw {
                guard indexPath.row < self.partnerViewModel.arrayOfPartnerMainCategory.count else { return }
                
                selectedMainIndex = indexPath
                selectedSubIndex = nil
                selectedChildIndex = nil
                
                let obj = self.partnerViewModel.arrayOfPartnerMainCategory[indexPath.row]
                
                self.subCatCollectionVw.isHidden = false
                self.childCatCollectionVw.isHidden = true
                
                self.setPartnerSubCategory(strCatiD: obj.id ?? "")
                self.setPartnerService(strCatiD: obj.id ?? "", subCatiD: k.emptyString, strChildiD: k.emptyString)
                
                self.btn_AllCategory.backgroundColor = .clear
                self.btn_AllCategory.setTitleColor(R.color.main(), for: .normal)
                
                mainCatCollectionVw.reloadData()
                subCatCollectionVw.reloadData()
                childCatCollectionVw.reloadData()
                
            } else if collectionView == subCatCollectionVw {
                guard indexPath.row < self.partnerViewModel.arrayOfPartnerSubCategory.count else { return }
                
                selectedSubIndex = indexPath
                selectedChildIndex = nil
                
                let obj = self.partnerViewModel.arrayOfPartnerSubCategory[indexPath.row]
                
                self.childCatCollectionVw.isHidden = false
                
                self.setPartnerChildCategory(strCatiD: obj.cat_id ?? "", strSubCatiD: obj.id ?? "")
                self.setPartnerService(strCatiD: obj.cat_id ?? "", subCatiD: obj.id ?? "", strChildiD: k.emptyString)
                
                subCatCollectionVw.reloadData()
                childCatCollectionVw.reloadData()
                
            } else {
                guard indexPath.row < self.partnerViewModel.arrayOfPartnerChildCategory.count else { return }
                
                selectedChildIndex = indexPath
                
                let obj = self.partnerViewModel.arrayOfPartnerChildCategory[indexPath.row]
                self.setPartnerService(strCatiD: obj.category_id ?? "", subCatiD: obj.sub_cat_id ?? "", strChildiD: obj.id ?? "")
                
                childCatCollectionVw.reloadData()
            }
        } else {
            // MARKS Company Offer Service
            if collectionView == mainCatCollectionVw {
                guard indexPath.row < self.viewModel.arrayOfMainOfferCat.count else { return }
                
                selectedMainIndex = indexPath
                selectedSubIndex = nil
                selectedChildIndex = nil
                
                let obj = self.viewModel.arrayOfMainOfferCat[indexPath.row]
                self.subCatCollectionVw.isHidden = false
                self.childCatCollectionVw.isHidden = true
                
                self.setSubofferCategory(strCatiD: obj.id ?? "")
                self.setUpComanyOffers(strCatiD: obj.id ?? "", strSubCatiD: k.emptyString, strChildiD: k.emptyString)
                
                self.btn_AllCategory.backgroundColor = .clear
                self.btn_AllCategory.setTitleColor(R.color.main(), for: .normal)
                
                mainCatCollectionVw.reloadData()
                subCatCollectionVw.reloadData()
                childCatCollectionVw.reloadData()
                
            } else if collectionView == subCatCollectionVw {
                guard indexPath.row < self.viewModel.arrayOfSubOfferCat.count else { return }
                
                selectedSubIndex = indexPath
                selectedChildIndex = nil
                
                let obj = self.viewModel.arrayOfSubOfferCat[indexPath.row]
                self.childCatCollectionVw.isHidden = false
                
                self.setChildOfferCategory(strCatiD: obj.cat_id ?? "", strSubCatiD: obj.id ?? "")
                self.setUpComanyOffers(strCatiD: obj.cat_id ?? "", strSubCatiD: obj.id ?? "", strChildiD: k.emptyString)
                
                subCatCollectionVw.reloadData()
                childCatCollectionVw.reloadData()
                
            } else {
                guard indexPath.row < self.viewModel.arrayOfChildOfferCat.count else { return }
                
                selectedChildIndex = indexPath
                
                let obj = self.viewModel.arrayOfChildOfferCat[indexPath.row]
                self.setUpComanyOffers(strCatiD: obj.category_id ?? "", strSubCatiD: obj.sub_cat_id ?? "", strChildiD: obj.id ?? "")
                
                childCatCollectionVw.reloadData()
            }
        }
    }
}

// MARK: TABLEVIEW
extension OfferVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dependonUi == "Tourism" {
            return self.tourismViewModel.arrayTourismService.count
        } else if dependonUi == "Partner" {
            return self.partnerViewModel.arrayPartnerService.count
        } else {
            return self.viewModel.arrayOfOffers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dependonUi == "Tourism" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MoreServiceCell", for: indexPath) as! MoreServiceCell
            let obj = self.tourismViewModel.arrayTourismService[indexPath.row]
            
            cell.view_Cities.isHidden = true
            cell.view_Company.isHidden = false
            
            cell.lbl_Title.text = L102Language.currentAppleLanguage() == "en" ? obj.company_name ?? "" : obj.company_name_ar ?? ""
            
            cell.lbl_CompanyName.text = obj.address ?? ""
            
//            cell.setupCompanyWebView(processPool: webProcessPool)
            let html = L102Language.currentAppleLanguage() == "en" ? obj.description ?? "" : obj.description_ar ?? ""
            
            if let attributedText = html.htmlAttributedString3 {
                cell.lbl_Description.attributedText = attributedText
            }
            
            if Router.BASE_IMAGE_URL != obj.image1 {
                Utility.setImageWithSDWebImage(obj.image1 ?? "", cell.company_Img)
            }
            
            return cell
            
        } else if dependonUi == "Partner" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PartnerServiceCell", for: indexPath) as! PartnerServiceCell
            let obj = self.partnerViewModel.arrayPartnerService[indexPath.row]
                        
            cell.lbl_CityAddress.text = obj.address ?? ""
            
            cell.lbl_CityTitle.text = L102Language.currentAppleLanguage() == "en" ? obj.company_name ?? "" : obj.company_name_ar ?? ""
            
//            let html = L102Language.currentAppleLanguage() == "en" ? obj.description ?? "" : obj.description_ar ?? ""
//            
//            if let attributedText = html.htmlAttributedString3 {
//                cell.lbl_Description.attributedText = attributedText
//            }
            
            if Router.BASE_IMAGE_URL != obj.cover_image {
                Utility.setImageWithSDWebImage(obj.image1 ?? "", cell.city_Img)
            } else {
                cell.city_Img.image = R.image.backPlaceholder()
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DiscountCell", for: indexPath) as! DiscountCell
            
            let obj = self.viewModel.arrayOfOffers[indexPath.row]
            
            let percentText = "\(obj.discount_percentage ?? "")%"

            cell.offer_CodeAndPercent.text = percentText
            
            let text = R.string.localizable.discount()
            cell.textDiscount.text = text
            
            cell.lbl_OfferDescription.text = L102Language.currentAppleLanguage() == "en" ? obj.company_name ?? "" : obj.company_name_ar ?? ""
            
            if Router.BASE_IMAGE_URL != obj.image {
                Utility.setImageWithSDWebImage(obj.image ?? "", cell.offer_Img)
            } else {
                cell.offer_Img.image = R.image.blank()
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dependonUi == "Tourism" {
            let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailVC
            let obj = self.tourismViewModel.arrayTourismService[indexPath.row]
            vC.viewModel.service_ID = obj.id ?? ""
            navigationController?.pushViewController(vC, animated: true)
        } else if dependonUi == "Partner" {
            let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServiceDetailVC") as! ServiceDetailVC
            let obj = self.partnerViewModel.arrayPartnerService[indexPath.row]
            vC.viewModel.service_ID = obj.id ?? ""
            navigationController?.pushViewController(vC, animated: true)
        } else {
            let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GuidelinesVC") as! GuidelinesVC
            let obj = self.viewModel.arrayOfOffers[indexPath.row]
            if L102Language.currentAppleLanguage() == "en" {
                vC.titleVal = obj.company_name ?? ""
                print(vC.titleVal)
                vC.descriptionVal = obj.description ?? ""
                vC.placeImg = obj.image ?? ""
                vC.offerCode = "\(obj.discount_code ?? "") \(obj.discount_percentage ?? "")% Off"
                vC.isFrom = "Offers"
            } else {
                vC.titleVal = obj.company_name_ar ?? ""
                vC.descriptionVal = obj.description_ar ?? ""
                vC.placeImg = obj.image ?? ""
                vC.offerCode = "\(obj.discount_code ?? "") \(obj.discount_percentage ?? "")% Off"
                vC.isFrom = "Offers"
            }
            navigationController?.pushViewController(vC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dependonUi == "Tourism" {
            return 280
        } else if dependonUi == "Partner" {
            return 140
        } else {
            return 280
        }
    }
}

// MARK: SEARCH DELEGATE
extension OfferVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if dependonUi == "Tourism" {
            if searchText.isEmpty {
                self.tourismViewModel.arrayTourismService = tourismViewModel.arrayOfFilteredTourismService
            } else {
                self.tourismViewModel.arrayTourismService = L102Language.currentAppleLanguage() == "en"
                ? tourismViewModel.arrayOfFilteredTourismService.filter {
                    $0.company_name?.range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil
                }
                : tourismViewModel.arrayOfFilteredTourismService.filter {
                    $0.company_name_ar?.range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil
                }
            }
            
        } else if dependonUi == "Partner" {
            if searchText.isEmpty {
                self.partnerViewModel.arrayPartnerService = partnerViewModel.arrayFilteredPartnerService
            } else {
                self.partnerViewModel.arrayPartnerService = L102Language.currentAppleLanguage() == "en"
                ? partnerViewModel.arrayFilteredPartnerService.filter {
                    $0.company_name?.range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil
                }
                : partnerViewModel.arrayFilteredPartnerService.filter {
                    $0.company_name_ar?.range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil
                }
            }
            
        } else {
            if searchText.isEmpty {
                self.viewModel.arrayOfOffers = viewModel.arrayFilteredCompanyOffer
            } else {
                self.viewModel.arrayOfOffers = L102Language.currentAppleLanguage() == "en"
                ? viewModel.arrayFilteredCompanyOffer.filter {
                    $0.company_name?.range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil
                }
                : viewModel.arrayFilteredCompanyOffer.filter {
                    $0.company_name_ar?.range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil
                }
            }
        }
        
        self.serviceTableVw.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

extension OfferVC: SkeletonTableViewDataSource {
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "DiscountCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 // ✅ Show 4 shimmer placeholders while loading
    }
}


