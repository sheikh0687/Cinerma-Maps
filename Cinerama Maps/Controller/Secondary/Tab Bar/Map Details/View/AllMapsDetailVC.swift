//
//  AllMapsDetailVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 28/08/24.
//

import Cosmos
import GoogleMaps
import SwiftyJSON
import GoogleMapsUtils
import AVKit
import WebKit
import SwiftUI
import SkeletonView

enum MapDetailTab: Int {
    case aboutMap = 0
    case place
    case review
//    case images
    case moreFeature
}

class AllMapsDetailVC: UIViewController {
    
    @IBOutlet weak var lbl_MainHeadline: UILabel!
    
    //    Mark SubView Outlet
    @IBOutlet var labelLine1: UILabel!
    @IBOutlet var labelLine2: UILabel!
    @IBOutlet var labelLine3: UILabel!
    @IBOutlet var labelLine4: UILabel!
    @IBOutlet var labelLine5: UILabel!
    @IBOutlet weak var btnCurrency: UIButton!
    
    //    Mark SubView Outlet
    @IBOutlet weak var btn_AboutMap: UIButton!
    @IBOutlet weak var btn_Place: UIButton!
    @IBOutlet weak var btn_Review: UIButton!
    @IBOutlet weak var btn_Images: UIButton!
    @IBOutlet weak var btn_MoreFeature: UIButton!
    
    //    Mark SubView Outlet
    @IBOutlet weak var aboutCity_Vw: UIView!
    @IBOutlet weak var map_Vw: UIView!
    @IBOutlet weak var review_Vw: UIView!
    @IBOutlet weak var images_Vw: UIView!
    @IBOutlet weak var allViewScroll: UIScrollView!
    
    //    Mark SubView Outlet
    @IBOutlet weak var cityImagesSlider: UICollectionView!
    @IBOutlet weak var btn_FavUnfavOt: UIButton!
    @IBOutlet weak var lbl_CityNAme: UILabel!
    @IBOutlet weak var lbl_Amount: UILabel!
    @IBOutlet weak var ratingVw: CosmosView!
    @IBOutlet weak var lbl_RatingReview: UILabel!
    @IBOutlet weak var lbl_CityAddress: UILabel!
    
    //    Mark About City View Outlet's
    @IBOutlet weak var lbl_AboutCity: UILabel!
    @IBOutlet weak var btn_ReadMore: UIButton!
    @IBOutlet weak var lbl_Currrency: UILabel!
    @IBOutlet weak var lbl_Language: UILabel!
    @IBOutlet weak var lbl_Clothing: UILabel!
    @IBOutlet weak var lbl_Timing: UILabel!
    @IBOutlet weak var lbl_Health: UILabel!
    @IBOutlet weak var lbl_ElectricSocket: UILabel!
    @IBOutlet weak var lbl_Communication: UILabel!
    @IBOutlet weak var lbl_Weather: UILabel!
    @IBOutlet weak var lbl_PoliceCarNum: UILabel!
    @IBOutlet weak var textPoliceCarNum: UILabel!
    @IBOutlet weak var textPolicePhoneNum: UILabel!
    @IBOutlet weak var lbl_PolicePhoneNum: UILabel!
    
    //    Mark MapView Outlet
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var locationAddress_Vw: UIView!
    @IBOutlet weak var lbl_PlaceName: UILabel!
    @IBOutlet weak var lbl_PlaceAddress: UILabel!
    @IBOutlet weak var tag_CollectionVw: UICollectionView!
    @IBOutlet weak var tagHeight: NSLayoutConstraint!
    
    //    Mark RatingView Outlet
    @IBOutlet weak var rating_TableVw: UITableView!
    @IBOutlet weak var btn_SubmitReviewOt: UIButton!
    
    //    Mark ImagesView Outlet
    @IBOutlet weak var images_CollectionVw: UICollectionView!
    @IBOutlet weak var imgPageControl: UIPageControl!
    
    @IBOutlet weak var btn_SubscribeOt: UIButton!
    @IBOutlet weak var mapZoom: UIStepper!
    
    @IBOutlet weak var videoPlayerVW: UIView!
    
    var clusterManager: GMUClusterManager!
    var clusterRenderer: GMUDefaultClusterRenderer!
    var marklers: [AnnotationItem] = []
    let viewModel = AllMapViewModel()
    var bounds = GMSCoordinateBounds()
    
    // For fetching data
    var cityID: String = ""
    var nameOfCity: String = ""
    var amountForCity: Double = 0.0
    var monthForCity: String = ""
    var ratingOfCity: String = ""
    var addressOfCity: String = ""
    var latitudeOfCity:String = ""
    var longitudeOfCity:String = ""
    var imageOfCity: String = ""
    
    var isSubscribed:String = ""
    var countryMapiD:String = ""
    var totalAmount = 0.0
    var totalUSDAmount = 0.0
    var amount = 0
    
    private var currentVideoLink: String = ""
    
    private let imgCollectionsRTLLayout = RTLCollectionViewFlowLayout()
    
    private var progressBars: [UIView] = []
    private var progressBarContainer: UIView!
    private var currentSliderIndex: Int = 0
    private var progressAnimator: UIViewPropertyAnimator?
    private let autoScrollInterval: TimeInterval = 3.5
    private var autoScrollTimer: Timer?
    
    private var dotViews: [UIView] = []
    private var dotContainer: UIView!
    
    var isAboutCityExpanded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        self.totalAmount = amountForCity.round()
        self.registerIdentifiers()
        self.configureiUUpdates()
        
        updateCurrency()
        updateUSDCurrency()
        setupClusterManager()
        
        if L102Language.currentAppleLanguage() == "en" {
            imgPageControl.semanticContentAttribute = .forceLeftToRight
            allViewScroll.semanticContentAttribute = .forceLeftToRight
        } else {
            imgPageControl.semanticContentAttribute = .forceRightToLeft
            allViewScroll.semanticContentAttribute = .forceRightToLeft
        }
        
        if self.viewModel.arrayOfCityImages.isEmpty {
            self.imgPageControl.numberOfPages = 1
        }
        
        startSkeletons()
        
        // Initial state for about city
        lbl_AboutCity.numberOfLines = 2
        btn_ReadMore.setTitle(L102Language.currentAppleLanguage() == "ar" ? "إقرأ المزيد" : "Read More", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        startAutoScroll()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoScroll()
    }
    
    private func setupPageControl() {
        if #available(iOS 14.0, *) {
            imgPageControl.preferredIndicatorImage = nil
            
            // Active dot — wide pill
            let activeConfig = UIImage.SymbolConfiguration(pointSize: 8)
            imgPageControl.setCurrentPageIndicatorImage(nil, forPage: imgPageControl.currentPage)
            imgPageControl.currentPageIndicatorTintColor = hexStringToUIColor(hex: "#e25e16")
            imgPageControl.pageIndicatorTintColor = UIColor.gray
            
            imgPageControl.preferredCurrentPageIndicatorImage = makeRoundedRect(width: 20, height: 8, color: hexStringToUIColor(hex: "#e25e16"))
            imgPageControl.preferredIndicatorImage = makeRoundedRect(width: 8, height: 8, color: UIColor.gray)
        } else {
            imgPageControl.currentPageIndicatorTintColor = hexStringToUIColor(hex: "#e25e16")
            imgPageControl.pageIndicatorTintColor = UIColor.gray
        }
    }

    private func makeRoundedRect(width: CGFloat, height: CGFloat, color: UIColor) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            let rect = CGRect(origin: .zero, size: size)
            UIBezierPath(roundedRect: rect, cornerRadius: height / 2).fill()
        }
    }
    
    // ✅ Auto scroll to next image
    private func scrollToNextImage() {
        guard !viewModel.arrayOfCityImages.isEmpty else { return }
        let nextIndex = (currentSliderIndex + 1) % viewModel.arrayOfCityImages.count
        let indexPath = IndexPath(item: nextIndex, section: 0)
        cityImagesSlider.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self else { return }
            self.currentSliderIndex = nextIndex
            self.imgPageControl.currentPage = nextIndex
        }
    }
    
//    private func scrollTabsToStart() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            if L102Language.currentAppleLanguage() == "ar" {
//                // ✅ Scroll to rightmost (where first tab is in RTL)
//                let maxOffset = self.allViewScroll.contentSize.width - self.allViewScroll.bounds.width
//                if maxOffset > 0 {
//                    self.allViewScroll.setContentOffset(CGPoint(x: maxOffset, y: 0), animated: false)
//                }
//            } else {
//                // ✅ LTR starts at 0
//                self.allViewScroll.setContentOffset(.zero, animated: false)
//            }
//        }
//    }
    
    func setupClusterManager() {
        
        let iconGenerator = GMUDefaultClusterIconGenerator()
        
        guard let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm (
            clusterDistancePoints: 50
        ) else { return }
        
        clusterRenderer = GMUDefaultClusterRenderer (
            mapView: mapView,
            clusterIconGenerator: iconGenerator
        )
        
        clusterRenderer.delegate = self
        clusterRenderer.animationDuration = 0.3
        
        clusterManager = GMUClusterManager (
            map: mapView,
            algorithm: algorithm,
            renderer: clusterRenderer
        )
        
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    func configureiUUpdates() {
        if viewModel.cityId.isEmpty {
            viewModel.cityId = cityID
        }
        if cityID.isEmpty {
            cityID = viewModel.cityId
        }
        
        self.lbl_MainHeadline.text = nameOfCity
        self.lbl_CityNAme.text = nameOfCity
        self.ratingVw.rating = Double(ratingOfCity) ?? 0.0
        self.lbl_RatingReview.text = ratingOfCity
        self.lbl_CityAddress.text = addressOfCity
        self.mapView.borderWidth = 1
        self.mapView.borderColor = .purple
        
        selectTab(.aboutMap)
        bindDataFromVm()
        bindCityImages()
//        scrollTabsToStart() // ✅ Add this
        
        if isSubscribed == "Yes" {
            self.btn_SubscribeOt.isHidden = true
            self.btn_SubmitReviewOt.isHidden = false
        } else {
            self.btn_SubscribeOt.isHidden = false
            self.btn_SubmitReviewOt.isHidden = true
        }
    }
    
    private func startSkeletons() {
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: L102Language.currentAppleLanguage() == "en" ? .leftRight : .rightLeft)

        // Text labels
//        lbl_AboutCity.showAnimatedSkeleton()
//        lbl_Currrency.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        lbl_Language.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        lbl_Clothing.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        lbl_Timing.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        lbl_Health.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        lbl_ElectricSocket.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        lbl_Communication.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        lbl_Weather.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        lbl_PoliceCarNum.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        lbl_PolicePhoneNum.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        lbl_CityNAme.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        lbl_Amount.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        lbl_RatingReview.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        lbl_CityAddress.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)

        // Table & Collection views
        rating_TableVw.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
        images_CollectionVw.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
        tag_CollectionVw.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
        cityImagesSlider.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
    }

    private func stopSkeletons() {
//        lbl_AboutCity.hideSkeleton(reloadDataAfter: true)
//        lbl_Currrency.hideSkeleton(reloadDataAfter: true)
//        lbl_Language.hideSkeleton(reloadDataAfter: true)
//        lbl_Clothing.hideSkeleton(reloadDataAfter: true)
//        lbl_Timing.hideSkeleton(reloadDataAfter: true)
//        lbl_Health.hideSkeleton(reloadDataAfter: true)
//        lbl_ElectricSocket.hideSkeleton(reloadDataAfter: true)
//        lbl_Communication.hideSkeleton(reloadDataAfter: true)
//        lbl_Weather.hideSkeleton(reloadDataAfter: true)
//        lbl_PoliceCarNum.hideSkeleton(reloadDataAfter: true)
//        lbl_PolicePhoneNum.hideSkeleton(reloadDataAfter: true)
//        lbl_CityNAme.hideSkeleton(reloadDataAfter: true)
//        lbl_Amount.hideSkeleton(reloadDataAfter: true)
//        lbl_RatingReview.hideSkeleton(reloadDataAfter: true)
//        lbl_CityAddress.hideSkeleton(reloadDataAfter: true)

        rating_TableVw.hideSkeleton(reloadDataAfter: true)
        images_CollectionVw.hideSkeleton(reloadDataAfter: true)
        tag_CollectionVw.hideSkeleton(reloadDataAfter: true)
        cityImagesSlider.hideSkeleton(reloadDataAfter: true)
    }
    
    @IBAction func allPlaceDetailButton(_ sender: UIButton) {
        guard let selectedTab = MapDetailTab(rawValue: sender.tag) else { return }
        selectTab(selectedTab)
    }
    
    private func selectTab(_ tab: MapDetailTab) {
        let selectedColor = hexStringToUIColor(hex: "#e25e16")
        let defaultColor = UIColor.darkGray
        
        btn_AboutMap.setTitleColor(tab == .aboutMap ? selectedColor : defaultColor, for: .normal)
        btn_Place.setTitleColor(tab == .place ? selectedColor : defaultColor, for: .normal)
        btn_Review.setTitleColor(tab == .review ? selectedColor : defaultColor, for: .normal)
        btn_MoreFeature.setTitleColor(tab == .moreFeature ? selectedColor : defaultColor, for: .normal)
        
        labelLine1.backgroundColor = tab == .aboutMap ? selectedColor : .clear
        labelLine2.backgroundColor = tab == .place ? selectedColor : .clear
        labelLine3.backgroundColor = tab == .review ? selectedColor : .clear
        labelLine5.backgroundColor = tab == .moreFeature ? selectedColor : .clear
        
        aboutCity_Vw.isHidden = tab != .aboutMap
        map_Vw.isHidden = tab != .place
        review_Vw.isHidden = tab != .review
        videoPlayerVW.isHidden = tab != .moreFeature
        
        // ✅ Scroll the selected tab button into visible area
        let selectedButton: UIButton
        switch tab {
        case .aboutMap:    selectedButton = btn_AboutMap
        case .place:       selectedButton = btn_Place
        case .review:      selectedButton = btn_Review
        case .moreFeature: selectedButton = btn_MoreFeature
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let buttonFrame = selectedButton.convert(selectedButton.bounds, to: self.allViewScroll)
            self.allViewScroll.scrollRectToVisible(buttonFrame, animated: true)
        }
    }
    
    @IBAction func btn_SubmitReview(_ sender: UIButton) {
        let vC = Kstoryboard.instantiateViewController(withIdentifier: "RatingVC") as! RatingVC
        vC.viewModel.reviewType = "City"
        vC.viewModel.requestId = viewModel.arrayOfDetailCityMaps.id ?? ""
        vC.viewModel.cityId = viewModel.arrayOfDetailCityMaps.place_details?.first?.city_id ?? ""
        vC.viewModel.reloadSuccessfully = { [weak self] responseData in
            guard let self else { return }
//            let newReview = Rating_review (
//                id: responseData.id,
//                user_id: responseData.user_id,
//                city_id: responseData.city_id,
//                place_id: responseData.place_id,
//                rating: responseData.rating,
//                review: responseData.review,
//                type: responseData.type,
//                date_time: responseData.date_time,
//                user_name: "",
//                image: ""
//            )
//            self.viewModel.arrayOfReviews.insert(newReview, at: 0)
            self.rating_TableVw.reloadData()
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Subscribe(_ sender: UIButton) {
        viewModel.navigateToSubcribeViewController(from: self.navigationController, mapiD: countryMapiD, type: nameOfCity, durationVal: monthForCity, amountVal: "\(totalAmount)",amountValInUSD: "\(totalUSDAmount)")
    }
    
    @IBAction func btn_Back(_ sender: UIButton) {
        viewModel.returnBackk(from: self.navigationController)
    }
    
    @IBAction func btn_ClosePlaceDt(_ sender: UIButton) {
        self.locationAddress_Vw.isHidden = true
    }
    
    @IBAction func btn_ReadMore(_ sender: UIButton) {
        isAboutCityExpanded.toggle()
        if isAboutCityExpanded {
            lbl_AboutCity.numberOfLines = 0
            btn_ReadMore.setTitle(L102Language.currentAppleLanguage() == "ar" ? "إقرأ أقل" : "Read Less", for: .normal)
        } else {
            lbl_AboutCity.numberOfLines = 2
            btn_ReadMore.setTitle(L102Language.currentAppleLanguage() == "ar" ? "إقرأ المزيد" : "Read More", for: .normal)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btn_FavUnfav(_ sender: UIButton) {
        
    }
    
    @IBAction func btnCurrency(_ sender: Any) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CurrencyVC") as! CurrencyVC
        
        vC.modalTransitionStyle = .crossDissolve
        vC.modalPresentationStyle = .overFullScreen
        vC.selectedCurrency = { [weak self] json in
            guard let self else { return }
            CurrencyHandler.shared.selectedCurrency = json
            updateCurrency()
            updateUSDCurrency()
        }
        self.present(vC, animated: true)
    }
    
    @IBAction func actZoomMap(_ sender: UIStepper) {
        guard let camera = mapView?.camera else { return }
        let newZoom = Float(sender.value)
        let updatedCamera = GMSCameraUpdate.zoom(to: newZoom)
        mapView.animate(with: updatedCamera)
    }
    
    private func updateCurrency() {
        let json = CurrencyHandler.shared.selectedCurrency ?? JSON([:])
        
        // ✅ Try both possible key names defensively
        let currencyCode = json["currencyCode"].stringValue.isEmpty
            ? json["currency_code"].stringValue
            : json["currencyCode"].stringValue
        
        // ✅ Fallback to SAR if still empty
        let finalCode = currencyCode.isEmpty ? "SAR" : currencyCode.uppercased()
        
        print("💰 currencyCode: \(finalCode)")
        
        self.btnCurrency.setTitle(finalCode, for: .normal)
        
        CurrencyHandler.shared.fetchCurrentCurrencyRate(code: finalCode) { [weak self] rate in
            guard let self else { return }
            
            self.totalAmount = (self.amountForCity * rate).round()
            
            // ✅ Force English locale numerals — fixes ٣٩ → 39
            let englishLocale = Locale(identifier: "en_US")
            
            // ✅ Format amount with English numerals always
            let formattedAmount = self.formatAmountEnglish(
                self.totalAmount,
                currencyCode: finalCode,
                locale: englishLocale
            )
            
            // ✅ Force monthForCity to English numerals too
            let englishMonth = self.toEnglishNumerals(self.monthForCity)
            
            // ✅ Build display text — numbers always English, text follows language
            let monthText: String
            if L102Language.currentAppleLanguage() == "ar" {
                // Arabic: "39 SAR - لمدة 3 أشهر"
                monthText = "\(formattedAmount) - لمدة \(englishMonth) أشهر"
            } else {
                // English: "39 SAR - for 3 Months"
                monthText = "\(formattedAmount) - for \(englishMonth) Months"
            }
            
            print("💰 Final monthText: \(monthText)")
            
            DispatchQueue.main.async {
                self.lbl_Amount.text = monthText
                self.lbl_Amount.hideSkeleton()
            }
        }
    }
    
    private func formatAmountEnglish(_ amount: Double, currencyCode: String, locale: Locale = Locale(identifier: "en_US")) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale                  // ✅ Forces 0-9 digits
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        let formattedNumber = formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
        return "\(formattedNumber) \(currencyCode.uppercased())"
    }

    // ✅ Converts any Arabic-Eastern numerals to English Western numerals
    private func toEnglishNumerals(_ input: String) -> String {
        var result = input
        let arabicNumerals = ["٠","١","٢","٣","٤","٥","٦","٧","٨","٩"]
        let englishNumerals = ["0","1","2","3","4","5","6","7","8","9"]
        for (arabic, english) in zip(arabicNumerals, englishNumerals) {
            result = result.replacingOccurrences(of: arabic, with: english)
        }
        return result
    }
    
    private func updateUSDCurrency() {
        CurrencyHandler.shared.fetchCurrentCurrencyRate(code: "usd") { [weak self] rate in
            guard let self else { return }
            self.totalUSDAmount = (self.amountForCity * rate).round()
            print("💵 USD Amount: \(self.totalUSDAmount)")
        }
    }
    
    private func bindDataFromVm() {
        viewModel.fetchedSuccessfully = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                let obj = self.viewModel.arrayOfDetailCityMaps
                
                let lang = L102Language.currentAppleLanguage()
                
                self.lbl_MainHeadline.text = lang == "en"
                ? obj?.name
                : obj?.name_ar ?? ""
                
                self.lbl_CityNAme.text = lang == "en"
                ? obj?.name
                : obj?.name_ar ?? ""
                
                self.lbl_CityAddress.text = obj?.address ?? ""
                
                if let price = Double(obj?.city_map_price ?? "0") {
                    self.amountForCity = price
                }
                
                if let month = obj?.city_map_month {
                    self.monthForCity = month
                }
                
                self.updateCurrency()
                
                self.lbl_AboutCity.text = lang == "en" ?
                obj?.about_city
                : obj?.about_city_ar ?? ""
                
                print(self.lbl_AboutCity.text ?? "NA")
                
                self.lbl_Currrency.text = lang == "en" 
                ? obj?.currency
                : obj?.currency_ar ?? ""
                
                self.lbl_Language.text = lang == "en"
                ? obj?.offical_language
                : obj?.offical_language_ar ?? ""
                
                self.lbl_Clothing.text = lang == "en"
                ? obj?.clothing
                : obj?.clothing_ar ?? ""
                
                self.lbl_Timing.text = lang == "en"
                ? obj?.best_time_to_visit
                : obj?.best_time_to_visit_ar ?? ""
                
                self.lbl_Health.text = lang == "en"
                ? obj?.health
                : obj?.health_ar ?? ""
                
                self.lbl_ElectricSocket.text = lang == "en"
                ? obj?.electrical_socket
                : obj?.electrical_socket_ar ?? ""
                
                self.lbl_Communication.text = lang == "en"
                ? obj?.communications
                : obj?.communications_ar ?? ""
                
                self.lbl_Weather.text = lang == "en"
                ? obj?.the_waether
                : obj?.the_waether_ar ?? ""
                
                self.lbl_PoliceCarNum.text = obj?.car_police_number
                
                self.textPoliceCarNum.text = lang == "en"
                ? obj?.car_police_number_name ?? ""
                : obj?.car_police_number_name_ar ?? ""
                
                self.lbl_PolicePhoneNum.text = obj?.police_number
                
                self.textPolicePhoneNum.text = lang == "en"
                ? obj?.police_number_name ?? ""
                : obj?.police_number_name_ar ?? ""

                let videoLink = L102Language.currentAppleLanguage() == "en"
                    ? obj?.youtube_video_link ?? ""
                    : obj?.youtube_video_link_arabic ?? ""

                if !videoLink.isEmpty {
                    self.setupYouTubeThumbnail(videoLink)
                } else {
                    self.videoPlayerVW.isHidden = true
                }
                
                self.updateAnnotations()
                self.rating_TableVw.reloadData()
                self.images_CollectionVw.reloadData()
                self.tag_CollectionVw.reloadData()
                
                self.mapZoom.minimumValue = 1
                self.mapZoom.maximumValue = 20
                self.mapZoom.stepValue = 1
                self.mapZoom.value = 12
                
                self.stopSkeletons()
            }
        }
        viewModel.requestCountryMapDetails(vC: self, tagHeight: tagHeight, collectionVw: tag_CollectionVw)
    }
        
    private func bindCityImages() {
        viewModel.fetchedImagesSuccess = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                let count = self.viewModel.arrayOfCityImages.count
                self.imgPageControl.numberOfPages = count == 0 ? 1 : count
                self.imgPageControl.currentPage = 0
                self.imgPageControl.isHidden = count <= 1
                                
                self.stopSkeletons()
                self.cityImagesSlider.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.setupPageControl()
                    
                    // ✅ For RTL, scroll to last index so index 0 shows first visually
                    if L102Language.currentAppleLanguage() == "ar" && count > 1 {
                        let lastIndex = IndexPath(item: count - 1, section: 0)
                        self.cityImagesSlider.scrollToItem(at: lastIndex, at: .centeredHorizontally, animated: false)
                        self.currentSliderIndex = count - 1
                        self.imgPageControl.currentPage = 0
                    }
                    
                    self.startAutoScroll()
                }
            }
        }
        viewModel.fetchCityImages(vC: self)
    }
    
    func updateAnnotations() {
        mapView.clear()
        marklers.removeAll()
        clusterManager.clearItems()
        
        for cityMap in viewModel.arrayOfDetailCityMaps.place_details ?? [] {
            let coordinate = CLLocationCoordinate2D(
                latitude: Double(cityMap.lat ?? "") ?? 0.0,
                longitude: Double(cityMap.lon ?? "") ?? 0.0
            )
            
            let markerView: MapMarkerView = UIView.fromNib()
            markerView.subviews.forEach { view in
                view.isHidden = false
            }
            
            if (cityMap.show_only_icon ?? "0") == "1" {
                let colors = getColors(tags: cityMap.tag_details ?? [])
                markerView.pinView.sliceColors = colors
                
                // Set text based on language
                let placeName = L102Language.currentAppleLanguage() == "ar" ? cityMap.place_name_ar : cityMap.place_name
                markerView.setText(
                    text: placeName ?? "",
                    font: L102Language.currentAppleLanguage() == "ar"
                        ? UIFont(name: "Arial", size: 10)!
                        : .systemFont(ofSize: 10, weight: .semibold)
                )
                
                markerView.outerImg.tintColor = hexStringToUIColor(hex: cityMap.icon_background_color ?? "#ffffff")
                markerView.innerImg.tintColor = colors.first
                
                // Handle promotion color
                if let endDateString = cityMap.end_date, !(cityMap.promo_code_and_discount?.isEmpty ?? true) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    dateFormatter.timeZone = .current
                    if let endDate = dateFormatter.date(from: endDateString), endDate >= Date() {
                        markerView.outerImg.tintColor = UIColor.hexStringToUIColor(hex: "#F1D280")
                    } else {
                        markerView.outerImg.tintColor = .white
                    }
                } else {
                    markerView.outerImg.tintColor = .white
                }
                
                // Load icon image if available
                if let iconUrl = cityMap.icon {
                    Utility.imageWithSDWebImage(iconUrl, markerView.mapIcon) {
                        self.addMarker(for: cityMap, at: coordinate, using: markerView)
                    }
                    continue
                }
            } else if (cityMap.show_only_icon ?? "0") == "0" {
                markerView.innerImg.isHidden = true
                markerView.pinView.isHidden = true
                markerView.mapIcon.isHidden = true
                markerView.outerImg.isHidden = false
                
                if let iconUrl = cityMap.icon {
                    Utility.imageWithSDWebImage(iconUrl, markerView.outerImg) {
                        self.addMarker(for: cityMap, at: coordinate, using: markerView)
                    }
                    continue
                }
            }
            
            // Add marker without waiting for image load
            self.addMarker(for: cityMap, at: coordinate, using: markerView)
        }
        
//         Cluster all markers
        clusterManager.cluster()
        
        // Set initial camera position
        if let firstCoordinate = viewModel.arrayOfDetailCityMaps.place_details?.first {
            let camera = GMSCameraPosition (
                latitude: Double(firstCoordinate.lat ?? "") ?? 0.0,
                longitude: Double(firstCoordinate.lon ?? "") ?? 0.0,
                zoom: 8
            )
            mapView.animate(to: camera)
        }
    }
    
    private func addMarker(for cityMap: Place_details, at coordinate: CLLocationCoordinate2D, using markerView: MapMarkerView) {
        // Render for zoomed state (with text)
        markerView.lblPlaceName.alpha = 1
        markerView.txtHeight.constant = 20
        markerView.layoutIfNeeded()
        let iconZoomed = renderMarkerViewAsImage(markerView: markerView)
        
        // Render for non-zoomed state (without text)
        markerView.lblPlaceName.alpha = 0
        markerView.txtHeight.constant = 0
        markerView.layoutIfNeeded()
        let iconNotZoomed = renderMarkerViewAsImage(markerView: markerView)
        
        let annotation = AnnotationItem(coordinate: coordinate)
        annotation.position = coordinate
        annotation.city_Address = cityMap.address
        annotation.iconZoomed = iconZoomed
        annotation.iconNotZoomed = iconNotZoomed
        annotation.placeId = cityMap.id
        annotation.lat = cityMap.lat
        annotation.lon = cityMap.lon
        annotation.fav = cityMap.currentUserFavorite ?? false
        annotation.cityName = cityMap.place_name
        annotation.cityNameAr = cityMap.place_name_ar
        
        marklers.append(annotation)
        clusterManager.add(annotation)
    }
    
    func renderMarkerViewAsImage(markerView: MapMarkerView) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(markerView.bounds.size, false, UIScreen.main.scale)
        
        if let context = UIGraphicsGetCurrentContext() {
            markerView.layer.render(in: context)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func getColors(tags: [Tag_details]) -> [UIColor] {
        var colors: [UIColor] = []
        for tag in tags {
            colors.append(UIColor.hexStringToUIColor(hex: tag.color_code ?? "#000000"))
        }
        return colors
    }
}

// MARK: - UITableView DataSource & Delegate
extension AllMapsDetailVC: UITableViewDataSource, UITableViewDelegate, SkeletonTableViewDataSource {
    
    func registerIdentifiers() {
        self.rating_TableVw.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        self.images_CollectionVw.register(UINib(nibName: "MapCell", bundle: nil), forCellWithReuseIdentifier: "MapCell")
        self.tag_CollectionVw.register(UINib(nibName: "MapTagCells", bundle: nil), forCellWithReuseIdentifier: "MapTagCells")
        self.cityImagesSlider.register(UINib(nibName: "CityImagesCell", bundle: nil), forCellWithReuseIdentifier: "CityImagesCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.arrayOfReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        
        let obj = self.viewModel.arrayOfReviews[indexPath.row]
        cell.lbl_Name.text = obj.user_name ?? ""
        cell.lbl_Date.text = obj.date_time ?? ""
        cell.lbl_Message.text = obj.review ?? ""
        cell.ratingStar.rating = Double(obj.rating ?? "") ?? 0.0
        cell.ratingCount.text = obj.rating ?? ""
        
        if Router.BASE_IMAGE_URL != obj.image {
            Utility.setImageWithSDWebImage(obj.image ?? "", cell.user_Img)
        } else {
            cell.user_Img.image = R.image.blank()
        }
        
        return cell
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "ReviewCell"
    }

    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 // Placeholder skeleton row count
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension AllMapsDetailVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SkeletonCollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tag_CollectionVw {
            return viewModel.arrayOfCityTag.count
        } else if collectionView == images_CollectionVw {
            return viewModel.arrayOfPlaceImg.count
        } else {
            if !viewModel.arrayOfCityImages.isEmpty {
                return viewModel.arrayOfCityImages.count
            } else {
                return 1
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tag_CollectionVw {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapTagCells", for: indexPath) as! MapTagCells
            let obj = self.viewModel.arrayOfCityTag[indexPath.row]
            let tagName = L102Language.currentAppleLanguage() == "en" ? obj.tag_name ?? "" : obj.tag_name_ar ?? ""
            let tagCount = obj.total_tag_place_count ?? ""
            cell.indexview.layer.cornerRadius = cell.indexview.frame.height / 2
            cell.indexview.backgroundColor = UIColor.hexStringToUIColor(hex: obj.color_code ?? "")
            cell.index.text = "\(tagCount)"
            cell.lbl_place.text = "\(tagName)"
            cell.index.backgroundColor = hexStringToUIColor(hex: obj.color_code ?? "")
            cell.lbl_place.textColor = hexStringToUIColor(hex: obj.color_code ?? "")
            cell.index.textColor = .white
            return cell
        } else if collectionView == images_CollectionVw {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapCell", for: indexPath) as! MapCell
            
            let obj = self.viewModel.arrayOfPlaceImg[indexPath.row]
            cell.countryMap.isHidden = true
            cell.lbl_CountryName.isHidden = true
            if Router.BASE_IMAGE_URL != obj.image {
                Utility.setImageWithSDWebImage(obj.image ?? "", cell.CountryImage)
            } else {
                cell.CountryImage.image = R.image.blank()
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityImagesCell", for: indexPath) as! CityImagesCell
            
            if !viewModel.arrayOfCityImages.isEmpty {
                let obj = self.viewModel.arrayOfCityImages[indexPath.row]
                
                if Router.BASE_IMAGE_URL != obj.image {
                    Utility.setImageWithSDWebImage(obj.image ?? "", cell.cityImg)
                } else {
                    cell.cityImg.image = R.image.blank()
                }
                
            } else {
                if Router.BASE_IMAGE_URL != imageOfCity {
                    Utility.setImageWithSDWebImage(imageOfCity, cell.cityImg)
                } else {
                    cell.cityImg.image = R.image.blank()
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == tag_CollectionVw {
            let maxWidth = collectionView.bounds.width / 2 - 10
            let fixedHeight: CGFloat = 40
            return CGSize(width: maxWidth, height: fixedHeight)
        } else if collectionView == images_CollectionVw {
            let collectionWidth = collectionView.frame.width
            return CGSize(width: collectionWidth / 2, height: 110)
        } else {
            if !viewModel.arrayOfCityImages.isEmpty {
                let collectionHeight = collectionView.frame.height
                return CGSize(width: 195, height: collectionHeight)
            } else {
                let collectionWidth = collectionView.frame.width
                let collectionHeight = collectionView.frame.height
                return CGSize(width: collectionWidth, height: collectionHeight)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == cityImagesSlider {
            let width = !viewModel.arrayOfCityImages.isEmpty ? 195.0 : scrollView.frame.width
            let pageIndex = Int(round(scrollView.contentOffset.x / width))

            if pageIndex != currentSliderIndex,
               pageIndex >= 0,
               pageIndex < viewModel.arrayOfCityImages.count,
               scrollView.isDragging || scrollView.isDecelerating {

                currentSliderIndex = pageIndex
                imgPageControl.currentPage = pageIndex
            }
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if skeletonView == tag_CollectionVw { return "MapTagCells" }
        if skeletonView == images_CollectionVw { return "MapCell" }
        return "CityImagesCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4 // Placeholder skeleton item count
    }

}

// MARK: - GMUClusterManagerDelegate & GMUClusterRendererDelegate
extension AllMapsDetailVC: GMUClusterManagerDelegate, GMUClusterRendererDelegate {
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let cluster = marker.userData as? GMUCluster {
            let items = cluster.items.compactMap { $0 as? AnnotationItem }
            if items.count > 1 {
                marker.icon = buildClusterIcon(items: items)
            }
        } else if let item = marker.userData as? AnnotationItem {
            // For individual markers, use zoomed or non-zoomed based on map zoom
            let zoom = mapView.camera.zoom
            if zoom > 6 {
                marker.icon = item.iconZoomed
            } else {
                marker.icon = item.iconNotZoomed
            }
        }
    }
    
    private func buildClusterIcon(items: [AnnotationItem]) -> UIImage {
        guard let firstIcon = items.first?.iconNotZoomed else {
            return UIImage()
        }

        let width = firstIcon.size.width
        let height = firstIcon.size.height

        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0.0)
        defer { UIGraphicsEndImageContext() }

        if items.count > 2 {
            if let secondIcon = items[1].iconNotZoomed {
                secondIcon.draw(at: CGPoint(x: 0, y: -6))
                secondIcon.draw(at: CGPoint(x: 0, y: -3))
            }
        } else if items.count > 1 {
            if let secondIcon = items[1].iconNotZoomed {
                secondIcon.draw(at: CGPoint(x: 0, y: -3))
            }
        }

        firstIcon.draw(at: CGPoint(x: 0, y: 0))

        let combined = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        return combined
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(
            withTarget: cluster.position,
            zoom: mapView.camera.zoom + 1
        )
        mapView.animate(to: newCamera)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let cluster = marker.userData as? GMUCluster {
            // Handle cluster tap - zoom in
            mapView.animate(toLocation: cluster.position)
            mapView.animate(toZoom: mapView.camera.zoom + 1)
            return true
        }
//        else if let item = marker.userData as? AnnotationItem {
            // Handle individual marker tap
//            viewModel.navigateToGooglePlaceDetailViewController(
//                from: navigationController!,
//                cityAddress: item.city_Address ?? "",
//                cityPlaceId: item.placeId ?? "",
//                cityAddressLat: item.lat ?? "",
//                cityAddressLon: item.lon ?? "",
//                isFav: item.fav
//            )
//            return true
//        }
        return false
    }
}

// MARK: - GMSMapViewDelegate
extension AllMapsDetailVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        // Update marker icons based on zoom level
        let zoom = position.zoom
        
        // Update cluster algorithm based on zoom
        let clusterDistance: UInt
        switch zoom {
        case 0...7:
            clusterDistance = 75
        case 7...10:
            clusterDistance = 50
        case 10...15:
            clusterDistance = 25
        default:
            clusterDistance = 0
        }
        
        // Recreate cluster manager with new distance
        guard let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm(
            clusterDistancePoints: clusterDistance
        ) else { return }
        
        clusterManager = GMUClusterManager(
            map: mapView,
            algorithm: algorithm,
            renderer: clusterRenderer
        )
        
        clusterManager.setDelegate(self, mapDelegate: self)
        clusterManager.add(marklers)
        clusterManager.cluster()
    }
}

extension AllMapsDetailVC {
    // MARK: - Video Setup
    func setupYouTubeThumbnail(_ urlString: String) {
        guard let videoID = extractYouTubeID(urlString) else {
            print("Could not extract YouTube ID from: \(urlString)")
            return
        }
        
        currentVideoLink = urlString
        
        // Clear previous subviews
        videoPlayerVW.subviews.forEach { $0.removeFromSuperview() }
        
        let thumbnailURL = "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
        
        // Thumbnail ImageView
        let imageView = UIImageView(frame: videoPlayerVW.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.sd_setImage(with: URL(string: thumbnailURL), placeholderImage: UIImage(systemName: "video.fill"))
        videoPlayerVW.addSubview(imageView)
        
        // Dark overlay for better button visibility
        let overlayView = UIView(frame: videoPlayerVW.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        videoPlayerVW.addSubview(overlayView)
        
        // Play Button
        let playButton = UIButton(type: .custom)
        playButton.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        playButton.center = CGPoint(x: videoPlayerVW.bounds.midX, y: videoPlayerVW.bounds.midY)
        playButton.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin,
                                       .flexibleLeftMargin, .flexibleRightMargin]
        
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular)
        let playImage = UIImage(systemName: "play.circle.fill", withConfiguration: config)
        playButton.setImage(playImage, for: .normal)
        playButton.tintColor = .white
        playButton.addTarget(self, action: #selector(openYouTubeTapped(_:)), for: .touchUpInside)
        videoPlayerVW.addSubview(playButton)
    }
    
    // MARK: - Button Action (unchanged)
    @objc func openYouTubeTapped(_ sender: UIButton) {
        openYouTubeVideo(currentVideoLink)  // Same call
    }
    
    // MARK: - ✅ ONLY THIS FUNCTION CHANGED
    func openYouTubeVideo(_ urlString: String) {
        guard !urlString.isEmpty,
              let videoID = extractYouTubeID(urlString) else { return }
        
        // Open SwiftUI YouTubePlayerView inside app
        let swiftUIView = YouTubePlayerView(videoID: videoID, originalURL: urlString, showCloseButton: false)
        let hostingVC = UIHostingController(rootView: swiftUIView)
        
        addChild(hostingVC)
        hostingVC.view.frame = videoPlayerVW.bounds
        hostingVC.view.backgroundColor = .clear
        hostingVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Clear previous subviews (thumbnail, play button, etc.)
        videoPlayerVW.subviews.forEach { $0.removeFromSuperview() }
        
        videoPlayerVW.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
    }
    
    // MARK: - Extract YouTube ID (unchanged)
    func extractYouTubeID(_ urlString: String) -> String? {
        
        // Handle: https://www.youtube.com/watch?v=VIDEO_ID
        if let components = URLComponents(string: urlString),
           components.host?.contains("youtube.com") == true,
           let videoID = components.queryItems?.first(where: { $0.name == "v" })?.value,
           !videoID.isEmpty {
            return videoID
        }
        
        // Handle: https://youtu.be/kW4ujahlJqU?si=3bmLwB40pRuiJZjS
        // ✅ Must strip EVERYTHING after "?" — si= is a sharing token, NOT video ID
        if urlString.contains("youtu.be/") {
            if let range = urlString.range(of: "youtu.be/") {
                let afterBase = String(urlString[range.upperBound...])
                // Strip query params like ?si=xxx
                let videoID = afterBase.components(separatedBy: "?").first ?? afterBase
                if !videoID.isEmpty {
                    print("✅ Extracted YouTube ID: \(videoID)")
                    return videoID
                }
            }
        }
        
        // Handle: https://www.youtube.com/shorts/VIDEO_ID
        if urlString.contains("/shorts/"),
           let videoID = urlString.components(separatedBy: "/shorts/").last?
            .components(separatedBy: "?").first,
           !videoID.isEmpty {
            return videoID
        }
        
        print("❌ Could not extract YouTube ID from: \(urlString)")
        return nil
    }
}

extension AllMapsDetailVC {
    
    private func startAutoScroll() {
        guard viewModel.arrayOfCityImages.count > 1 else { return }
        autoScrollTimer?.invalidate()
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { [weak self] _ in
            self?.scrollToNextImage()
        }
    }
    
    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
}
