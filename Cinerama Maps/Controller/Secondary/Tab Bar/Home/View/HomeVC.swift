//
//  HomeVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 22/08/24.
//

import UIKit
import SnapKit
import SkeletonView

class HomeVC: UIViewController {
    
    // MARK: PROPERTIES
    @IBOutlet weak var profile_Img: UIImageView!
    @IBOutlet weak var lbl_UserName: UILabel!
    
    @IBOutlet weak var btnCurrency: UIButton!
    @IBOutlet weak var service_CollectionVw: UICollectionView!
    @IBOutlet weak var map_CollectionVw: UICollectionView!
    @IBOutlet weak var guideline_CollectionVw: UICollectionView!
    @IBOutlet weak var advertisementCollection: UICollectionView!
    @IBOutlet weak var advertisementCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var advertisementPage: UIPageControl!
    @IBOutlet weak var lbl_UseriD: UILabel!
    
    //  MARK: ViewModel
    let viewModel = HomeViewModel()
    let countryMapVM = CountryMapApiViewModel()
    let guidelinesTipVM = GuidelineTipApiViewModel()
    let serviceVM = ServiceApiViewModel()
    let advertisementVM = AdvertisementViewModel()
    
    //  MARK: CollectionViewLayout
    let mapRTLLayout = RTLCollectionViewFlowLayout()
    let guidelineRTLLayout = RTLCollectionViewFlowLayout()
    let serviceRTLLayout = RTLCollectionViewFlowLayout()
    let advertisementRTLLayout = RTLCollectionViewFlowLayout()
    
    //  MARK: Variable
    var strSubscriptionStatus: String?
    var isLoadingBanners = true
    var isLoadingCountryMaps = true
    var isLoadingGuidelines = true
    var isLoadingProfile = true
    var isLoadingServices = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerResuableCellIdentifier()
        
        advertisementCollection.isSkeletonable = true
        map_CollectionVw.isSkeletonable = true
        guideline_CollectionVw.isSkeletonable = true
        
        if L102Language.currentAppleLanguage() == "ar" {
            mapRTLLayout.scrollDirection = .horizontal
            map_CollectionVw.collectionViewLayout = mapRTLLayout
            map_CollectionVw.semanticContentAttribute = .forceLeftToRight
            
            guidelineRTLLayout.scrollDirection = .horizontal
            guideline_CollectionVw.collectionViewLayout = guidelineRTLLayout
            guideline_CollectionVw.semanticContentAttribute = .forceLeftToRight
            
            advertisementRTLLayout.scrollDirection = .horizontal
            advertisementCollection.collectionViewLayout = advertisementRTLLayout
            advertisementCollection.semanticContentAttribute = .forceLeftToRight
        }
        
        self.btnCurrency.setTitle(CurrencyHandler.shared.selectedCurrency?["currencyCode"].stringValue, for: .normal)
        self.map_CollectionVw.isPagingEnabled = false
        self.guideline_CollectionVw.isPagingEnabled = false
        
        if L102Language.currentAppleLanguage() == "en" {
            advertisementPage.semanticContentAttribute = .forceLeftToRight
        } else {
            advertisementPage.semanticContentAttribute = .forceRightToLeft
        }

        startProfileShimmering()
        // Apply the custom layout to the collection view
        requestBanners()
        requestCountryMap()
        requestGuidelineTip()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !advertisementVM.arrayOfBanners.isEmpty {
            updateBannerHeight()
        }
    }
    
    private func startProfileShimmering() {
        self.profile_Img.showAnimatedSkeleton()
        self.lbl_UserName.showAnimatedSkeleton()
        self.lbl_UseriD.showAnimatedSkeleton()
    }
    
    private func stopProfileShimmering() {
        self.profile_Img.hideSkeleton()
        self.lbl_UserName.hideSkeleton()
        self.lbl_UseriD.hideSkeleton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        reUseProfile()
    }
    
    @IBAction func btn_Search(_ sender: UIButton) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapVC") as! MapVC
        vC.decided_Ui = "Search"
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_MapsMore(_ sender: UIButton) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapVC") as! MapVC
        vC.decided_Ui = "Search"
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Setting(_ sender: UIButton) {
        viewModel.navigateToSettingViewController(from: self.navigationController)
    }
    
    @IBAction func btn_Notify(_ sender: UIButton) {
        let vC = Kstoryboard.instantiateViewController(withIdentifier: "NotifyVC") as! NotifyVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_AddTrip(_ sender: UIButton) {
        if k.userDefault.value(forKey: k.session.subcription) as? String == "Yes" {
            viewModel.navigateToTripViewController(from: self.navigationController)
        } else {
            self.alert(alertmessage: L102Language.currentAppleLanguage() == "en" ? "For add place first you need to subscribe your city map." : "أولاً، عليك الاشتراك في خريطة مدينتك قبل إضافة المكان")
        }
    }
    
    @IBAction func btn_MoreService(_ sender: UIButton) {
        let vC = Kstoryboard.instantiateViewController(withIdentifier: "MoreServiceVC") as! MoreServiceVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_MoreGuidelines(_ sender: UIButton) {
        viewModel.navigateToGuidlineDetailViewController(from: self.navigationController, res_Guidelines: guidelinesTipVM.arrayGuidelinesTip, res_FilteredGuideline: guidelinesTipVM.arrayGuidelinesTip)
    }
    
    @IBAction func btn_SelectCurrency(_ sender: Any) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CurrencyVC") as! CurrencyVC
        
        vC.modalTransitionStyle = .crossDissolve
        vC.modalPresentationStyle = .overFullScreen
        
        vC.selectedCurrency = { [weak self] json in
            guard let self else { return }
            
            self.btnCurrency.setTitle(json["currencyCode"].stringValue, for: .normal)
            CurrencyHandler.shared.selectedCurrency = json
        }
        
        self.present(vC, animated: true)
    }
}

// MARK: CALLING API
extension HomeVC {
    
    private func reUseProfile() {
        DispatchQueue.main.async {
            self.isLoadingProfile = false
            self.stopProfileShimmering()
            let uFirstName = k.userDefault.value(forKey: k.session.firstName) as? String
            let uLastName = k.userDefault.value(forKey: k.session.lastName) as? String
            let uiD = k.userDefault.value(forKey: k.session.userId) as? String
            let uImage = k.userDefault.value(forKey: k.session.userImg) as? String
            
            self.lbl_UserName.text = "\(uFirstName ?? "") \(uLastName ?? "")"
            self.lbl_UseriD.text = "\(L102Language.currentAppleLanguage() == "en" ? "User ID" : "معرف المستخدم"): \(uiD ?? "")"
            
            if Router.BASE_IMAGE_URL != uImage {
                Utility.setImageWithSDWebImage(uImage ?? "", self.profile_Img)
            } else {
                self.profile_Img.image = R.image.profile_ic()
            }
        }
    }
    
    private func requestCountryMap() {
        map_CollectionVw.showAnimatedSkeleton()
        
        countryMapVM.fetchCountryMaps(vC: self)
        countryMapVM.fethcedSuccessfully = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                if L102Language.currentAppleLanguage() == "ar" {
                    self.mapRTLLayout.scrollDirection = .horizontal
                    self.map_CollectionVw.collectionViewLayout = self.mapRTLLayout
                    self.map_CollectionVw.semanticContentAttribute = .forceLeftToRight
                }
                
                self.map_CollectionVw.stopSkeletonAnimation()
                self.map_CollectionVw.hideSkeleton(reloadDataAfter: false)
                
                self.map_CollectionVw.reloadData()
            }
        }
    }
    
    private func requestGuidelineTip() {
        guideline_CollectionVw.showAnimatedSkeleton()
        
        guidelinesTipVM.fetchGuidelineTips(vC: self)
        guidelinesTipVM.fethcedSuccessfully = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                if L102Language.currentAppleLanguage() == "ar" {
                    self.guidelineRTLLayout.scrollDirection = .horizontal
                    self.guideline_CollectionVw.collectionViewLayout = self.guidelineRTLLayout
                    self.guideline_CollectionVw.semanticContentAttribute = .forceLeftToRight
                }
                
                self.guideline_CollectionVw.stopSkeletonAnimation()
                self.guideline_CollectionVw.hideSkeleton(reloadDataAfter: false)
                
                self.guideline_CollectionVw.reloadData()
            }
        }
    }
    
    private func requestBanners() {
        advertisementCollection.showAnimatedSkeleton()
        
        advertisementVM.requestToFetchAdvertisement(vC: self)
        advertisementVM.fetchedSuccessfully = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                self.advertisementPage.numberOfPages = self.advertisementVM.arrayOfBanners.count
                
                if L102Language.currentAppleLanguage() == "ar" {
                    self.advertisementRTLLayout.scrollDirection = .horizontal
                    self.advertisementCollection.collectionViewLayout = self.advertisementRTLLayout
                    self.advertisementCollection.semanticContentAttribute = .forceLeftToRight
                }
                
                self.advertisementCollection.stopSkeletonAnimation()
                self.advertisementCollection.hideSkeleton(reloadDataAfter: false)
                
                self.advertisementCollection.reloadData()
                self.setupAdvertisementCollection()
                self.updateBannerHeight()
            }
        }
    }
}

// MARK: COLLECTIONVIEW DATASOURCE, DELEGATE
extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func registerResuableCellIdentifier() {
        self.service_CollectionVw.register(UINib(nibName: "ServiceCell", bundle: nil), forCellWithReuseIdentifier: "ServiceCell")
        self.advertisementCollection.register(UINib(nibName: "ServiceCell", bundle: nil), forCellWithReuseIdentifier: "ServiceCell")
        self.map_CollectionVw.register(UINib(nibName: "MapCell", bundle: nil), forCellWithReuseIdentifier: "MapCell")
        self.guideline_CollectionVw.register(UINib(nibName: "GuidelineCell", bundle: nil), forCellWithReuseIdentifier: "GuidelineCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == advertisementCollection {
            return self.advertisementVM.arrayOfBanners.count
        } else if collectionView == service_CollectionVw {
            return serviceVM.arrayOfImages.count
        } else if collectionView == map_CollectionVw {
            return self.countryMapVM.arrayCountryMaps.count
        } else {
            return guidelinesTipVM.arrayGuidelinesTip.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == advertisementCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
            
            let obj = self.advertisementVM.arrayOfBanners[indexPath.row]
            
            // Image styling
            cell.service_Img.contentMode = .scaleAspectFill
            cell.service_Img.clipsToBounds = true
            cell.service_Img.layer.cornerRadius = 12
            
            // Add padding by inset the imageView
            cell.contentView.backgroundColor = .clear
            cell.backgroundColor = .clear
            
            if Router.BASE_IMAGE_URL != obj.image {
                Utility.setImageWithSDWebImage(obj.image ?? "", cell.service_Img)
            } else {
                cell.service_Img.image = R.image.blank()
            }
            
            return cell
        } else if collectionView == service_CollectionVw {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
            
            let obj_Image = serviceVM.arrayOfImages[indexPath.row]
            print(obj_Image)
            Utility.setImageWithSDWebImage(obj_Image, cell.service_Img)
            return cell
        } else if collectionView == map_CollectionVw {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapCell", for: indexPath) as! MapCell
            
            let obj = countryMapVM.arrayCountryMaps[indexPath.row]
            
            if L102Language.currentAppleLanguage() == "en" {
                cell.lbl_CountryName.text = obj.name ?? ""
            } else {
                cell.lbl_CountryName.text = obj.name_ar ?? ""
            }
            
            if Router.BASE_IMAGE_URL != obj.image {
                Utility.setImageWithSDWebImage(obj.image ?? "", cell.CountryImage)
            } else {
                cell.CountryImage.image = R.image.blank()
            }
            
            if Router.BASE_IMAGE_URL != obj.country_icon {
                Utility.setImageWithSDWebImage(obj.country_icon ?? "", cell.countryMap)
            } else {
                cell.CountryImage.image = R.image.blank()
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuidelineCell", for: indexPath) as! GuidelineCell
            
            let obj = self.guidelinesTipVM.arrayGuidelinesTip[indexPath.row]
            
            cell.lbl_Text.text = L102Language.currentAppleLanguage() == "en" ? obj.title ?? "" : obj.title_ar ?? ""
            
            if Router.BASE_IMAGE_URL != obj.image {
                Utility.setImageWithSDWebImage(obj.image ?? "", cell.img)
            } else {
                cell.img.image = R.image.blank()
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == service_CollectionVw || collectionView == advertisementCollection {
//            let padding: CGFloat = 16  left + right padding
            let width = collectionView.frame.width
            let height = width * (9.0 / 16.0)
            return CGSize(width: width, height: height)
        } else if collectionView == map_CollectionVw {
            return CGSize(width: 190, height: 140)
        } else {
            return CGSize(width: 190, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == service_CollectionVw {
            let obj = serviceVM.arrayOfServices[0]
            self.viewModel.navigateToServicesViewController(from: self.navigationController, service_Id: obj.id ?? "")
            
        } else if collectionView == map_CollectionVw {
            
            let obj = countryMapVM.arrayCountryMaps[indexPath.row]
            self.viewModel.navigateToCityMapsViewController (
                from: self.navigationController,
                countryId: obj.id ?? "",
                countryName: L102Language.currentAppleLanguage() == "en"
                ? obj.name ?? ""
                : obj.name_ar ?? ""
            )
            
        } else if collectionView == guideline_CollectionVw {
            
            let obj = self.guidelinesTipVM.arrayGuidelinesTip[indexPath.row]
            self.viewModel.navigateToGuidlineViewController(from: self.navigationController, title: obj.title ?? "", dateTime: obj.date_time ?? "", description: obj.description ?? "", image: obj.image ?? "", isFrom: "Guideline",titleArabic: obj.title_ar ?? "", descriptionArabic: obj.description_ar ?? "")
            
        } else if collectionView == advertisementCollection {
            let obj = self.advertisementVM.arrayOfBanners[indexPath.row]
            
            self.viewModel.navigateToGuidlineViewController (
                from: self.navigationController,
                title: obj.title ?? "", dateTime: obj.date_time ?? "", description: obj.description ?? "", image: obj.image ?? "", isFrom: "Advertisement",titleArabic: obj.title_ar ?? "", descriptionArabic: obj.description_ar ?? "")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == service_CollectionVw {
            let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
            pageControl.currentPage = Int(pageIndex)
        } else if scrollView == advertisementCollection {
            let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
            advertisementPage.currentPage = Int(pageIndex)
        } else {
            // Ignore other collection views
        }
    }
    
    private func setupAdvertisementCollection() {
        advertisementCollection.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        advertisementCollection.decelerationRate = .fast
        advertisementCollection.isPagingEnabled = false
        
        // ✅ Cast to the base class so it works for both LTR and RTL layouts
        if let layout = advertisementCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 12
        }
    }
    
    private func updateBannerHeight() {
        let padding: CGFloat = 16
        let width = advertisementCollection.frame.width - (padding * 2)
        let height = width * (9.0 / 16.0)
        advertisementCollectionHeight.constant = height
        self.view.layoutIfNeeded()
    }
}

extension HomeVC: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if skeletonView == advertisementCollection {
            return "ServiceCell"
        } else if skeletonView == map_CollectionVw {
            return "MapCell"
        } else {
            return "GuidelineCell"
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    // ✅ ADD THIS — tells skeleton NOT to override your custom layout
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        return nil // let the normal cellForItemAt handle it
    }
    
    // ✅ ADD THIS — prevents skeleton from resetting layout after hide
    func collectionSkeletonView(_ skeletonView: UICollectionView, prepareCellForSkeleton cell: UICollectionViewCell, at indexPath: IndexPath) {
        // Do nothing — prevent skeleton from mutating cell layout
    }
}
