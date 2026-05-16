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
    case moreFeature
}

class AllMapsDetailVC: UIViewController {
    
    @IBOutlet weak var lbl_MainHeadline: UILabel!
    
    @IBOutlet var labelLine1: UILabel!
    @IBOutlet var labelLine2: UILabel!
    @IBOutlet var labelLine3: UILabel!
    @IBOutlet var labelLine4: UILabel!
    @IBOutlet var labelLine5: UILabel!
    @IBOutlet weak var btnCurrency: UIButton!
    
    @IBOutlet weak var btn_AboutMap: UIButton!
    @IBOutlet weak var btn_Place: UIButton!
    @IBOutlet weak var btn_Review: UIButton!
    @IBOutlet weak var btn_Images: UIButton!
    @IBOutlet weak var btn_MoreFeature: UIButton!
    
    @IBOutlet weak var aboutCity_Vw: UIView!
    @IBOutlet weak var map_Vw: UIView!
    @IBOutlet weak var review_Vw: UIView!
    @IBOutlet weak var images_Vw: UIView!
    @IBOutlet weak var allViewScroll: UIScrollView!
    
    @IBOutlet weak var cityImagesSlider: UICollectionView!
    @IBOutlet weak var btn_FavUnfavOt: UIButton!
    @IBOutlet weak var lbl_CityNAme: UILabel!
    @IBOutlet weak var lbl_Amount: UILabel!
    @IBOutlet weak var ratingVw: CosmosView!
    @IBOutlet weak var lbl_RatingReview: UILabel!
    @IBOutlet weak var lbl_CityAddress: UILabel!
    
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
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var locationAddress_Vw: UIView!
    @IBOutlet weak var lbl_PlaceName: UILabel!
    @IBOutlet weak var lbl_PlaceAddress: UILabel!
    @IBOutlet weak var tag_CollectionVw: UICollectionView!
    @IBOutlet weak var tagHeight: NSLayoutConstraint!
    
    @IBOutlet weak var rating_TableVw: UITableView!
    @IBOutlet weak var btn_SubmitReviewOt: UIButton!
    
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
    
    var cityID: String = ""
    var nameOfCity: String = ""
    var amountForCity: Double = 0.0
    var monthForCity: String = ""
    var ratingOfCity: String = ""
    var addressOfCity: String = ""
    var latitudeOfCity: String = ""
    var longitudeOfCity: String = ""
    var imageOfCity: String = ""
    
    var isSubscribed: String = ""
    var countryMapiD: String = ""
    var totalAmount = 0.0
    var totalUSDAmount = 0.0
    var amount = 0
    
    private var currentVideoLink: String = ""
    private let imgCollectionsRTLLayout = RTLCollectionViewFlowLayout()
    private var currentSliderIndex: Int = 0
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
        
        if self.viewModel.arrayOfCityImages.isEmpty {
            self.imgPageControl.numberOfPages = 1
            self.cityImagesSlider.stopSkeletonAnimation()
        }
        
        cityImagesSlider.isSkeletonable = true
        
        if L102Language.currentAppleLanguage() == "ar" {
            imgCollectionsRTLLayout.scrollDirection = .horizontal
            cityImagesSlider.collectionViewLayout = imgCollectionsRTLLayout
            cityImagesSlider.semanticContentAttribute = .forceLeftToRight
        }
        
        if L102Language.currentAppleLanguage() == "en" {
            imgPageControl.semanticContentAttribute = .forceLeftToRight
        } else {
            imgPageControl.semanticContentAttribute = .forceRightToLeft
        }
        
        lbl_AboutCity.numberOfLines = 5
        btn_ReadMore.setTitle(L102Language.currentAppleLanguage() == "ar" ? "إقرأ المزيد" : "Read More", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
        
    func setupClusterManager() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        
        guard let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm(
            clusterDistancePoints: 50
        ) else { return }
        
        clusterRenderer = GMUDefaultClusterRenderer(
            mapView: mapView,
            clusterIconGenerator: iconGenerator
        )
        
        clusterRenderer.delegate = self
        clusterRenderer.animationDuration = 0.3
        
        clusterManager = GMUClusterManager(
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
        
        if isSubscribed == "Yes" {
            self.btn_SubscribeOt.isHidden = true
            self.btn_SubmitReviewOt.isHidden = false
        } else {
            self.btn_SubscribeOt.isHidden = false
            self.btn_SubmitReviewOt.isHidden = true
        }
        
        [btn_AboutMap, btn_Place, btn_Review, btn_MoreFeature].forEach {
            $0?.titleLabel?.font = UIFont (
                name: "Avenir-Black",
                size: L102Language.isRTL ? 14 : 12
            )
        }
    }
    
//    private func startSkeletons() {
//        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(
//            withDirection: L102Language.currentAppleLanguage() == "en" ? .leftRight : .rightLeft
//        )
//        rating_TableVw.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        images_CollectionVw.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        tag_CollectionVw.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//        cityImagesSlider.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .clouds), animation: animation)
//    }
//
//    private func stopSkeletons() {
//        rating_TableVw.hideSkeleton(reloadDataAfter: true)
//        images_CollectionVw.hideSkeleton(reloadDataAfter: true)
//        tag_CollectionVw.hideSkeleton(reloadDataAfter: true)
//        cityImagesSlider.hideSkeleton(reloadDataAfter: true)
//    }
    
    @IBAction func allPlaceDetailButton(_ sender: UIButton) {
        guard let selectedTab = MapDetailTab(rawValue: sender.tag) else { return }
        selectTab(selectedTab)
    }
    
    private func selectTab(_ tab: MapDetailTab) {
        let selectedColor = hexStringToUIColor(hex: "#e25e16")
        let defaultColor = UIColor.black
        
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
    }
    
    @IBAction func btn_SubmitReview(_ sender: UIButton) {
        let vC = Kstoryboard.instantiateViewController(withIdentifier: "RatingVC") as! RatingVC
        vC.viewModel.reviewType = "City"
        vC.viewModel.requestId = viewModel.arrayOfDetailCityMaps.id ?? ""
        vC.viewModel.cityId = viewModel.arrayOfDetailCityMaps.place_details?.first?.city_id ?? ""
        vC.viewModel.reloadSuccessfully = { [weak self] responseData in
            guard let self else { return }
            self.rating_TableVw.reloadData()
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Subscribe(_ sender: UIButton) {
        viewModel.navigateToSubcribeViewController(
            from: self.navigationController,
            mapiD: countryMapiD,
            type: nameOfCity,
            durationVal: monthForCity,
            amountVal: "\(totalAmount)",
            amountValInUSD: "\(totalUSDAmount)"
        )
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
            lbl_AboutCity.numberOfLines = 5
            btn_ReadMore.setTitle(L102Language.currentAppleLanguage() == "ar" ? "إقرأ المزيد" : "Read More", for: .normal)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btn_FavUnfav(_ sender: UIButton) {}
    
    @IBAction func btnCurrency(_ sender: Any) {
        let vC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CurrencyVC") as! CurrencyVC
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
        
        let currencyCode = json["currencyCode"].stringValue.isEmpty
            ? json["currency_code"].stringValue
            : json["currencyCode"].stringValue
        
        let finalCode = currencyCode.isEmpty ? "SAR" : currencyCode.uppercased()
        
        self.btnCurrency.setTitle(finalCode, for: .normal)
        
        CurrencyHandler.shared.fetchCurrentCurrencyRate(code: finalCode) { [weak self] rate in
            guard let self else { return }
            
            self.totalAmount = (self.amountForCity * rate).round()
            
            let englishLocale = Locale(identifier: "en_US")
            let formattedAmount = self.formatAmountEnglish(self.totalAmount, currencyCode: finalCode, locale: englishLocale)
            let englishMonth = self.toEnglishNumerals(self.monthForCity)
            
            let monthText: String
            if L102Language.currentAppleLanguage() == "ar" {
                monthText = "\(formattedAmount) - لمدة \(englishMonth) أشهر"
            } else {
                monthText = "\(formattedAmount) - for \(englishMonth) Months"
            }
            
            DispatchQueue.main.async {
                self.lbl_Amount.text = monthText
                self.lbl_Amount.hideSkeleton()
            }
        }
    }
    
    private func formatAmountEnglish(_ amount: Double, currencyCode: String, locale: Locale = Locale(identifier: "en_US")) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        let formattedNumber = formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
        return "\(formattedNumber) \(currencyCode.uppercased())"
    }

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
        }
    }
    
    private func bindDataFromVm() {
        viewModel.fetchedSuccessfully = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                let obj = self.viewModel.arrayOfDetailCityMaps
                let lang = L102Language.currentAppleLanguage()
                
                self.lbl_MainHeadline.text = lang == "en" ? obj?.name : obj?.name_ar ?? ""
                self.lbl_CityNAme.text = lang == "en" ? obj?.name : obj?.name_ar ?? ""
                self.lbl_CityAddress.text = obj?.address ?? ""
                
                if let price = Double(obj?.city_map_price ?? "0") {
                    self.amountForCity = price
                }
                if let month = obj?.city_map_month {
                    self.monthForCity = month
                }
                
                self.updateCurrency()
                
                self.lbl_AboutCity.text = lang == "en" ? obj?.about_city : obj?.about_city_ar ?? ""
                self.lbl_Currrency.text = lang == "en" ? obj?.currency : obj?.currency_ar ?? ""
                self.lbl_Language.text = lang == "en" ? obj?.offical_language : obj?.offical_language_ar ?? ""
                self.lbl_Clothing.text = lang == "en" ? obj?.clothing : obj?.clothing_ar ?? ""
                self.lbl_Timing.text = lang == "en" ? obj?.best_time_to_visit : obj?.best_time_to_visit_ar ?? ""
                self.lbl_Health.text = lang == "en" ? obj?.health : obj?.health_ar ?? ""
                self.lbl_ElectricSocket.text = lang == "en" ? obj?.electrical_socket : obj?.electrical_socket_ar ?? ""
                self.lbl_Communication.text = lang == "en" ? obj?.communications : obj?.communications_ar ?? ""
                self.lbl_Weather.text = lang == "en" ? obj?.the_waether : obj?.the_waether_ar ?? ""
                self.lbl_PoliceCarNum.text = obj?.car_police_number
                self.textPoliceCarNum.text = lang == "en" ? obj?.car_police_number_name ?? "" : obj?.car_police_number_name_ar ?? ""
                self.lbl_PolicePhoneNum.text = obj?.police_number
                self.textPolicePhoneNum.text = lang == "en" ? obj?.police_number_name ?? "" : obj?.police_number_name_ar ?? ""

                let videoLink = lang == "en" ? obj?.youtube_video_link ?? "" : obj?.youtube_video_link_arabic ?? ""
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
                
//                self.stopSkeletons()
            }
        }
        viewModel.requestCountryMapDetails(vC: self, tagHeight: tagHeight, collectionVw: tag_CollectionVw)
    }
        
    private func bindCityImages() {
        
        cityImagesSlider.showAnimatedSkeleton()
        
        viewModel.fetchCityImages(vC: self)
        viewModel.fetchedImagesSuccess = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                let count = self.viewModel.arrayOfCityImages.count
                self.imgPageControl.numberOfPages = count == 0 ? 1 : count
                self.imgPageControl.currentPage = 0
                self.imgPageControl.isHidden = count <= 1
                
                if L102Language.currentAppleLanguage() == "ar" {
                    self.imgCollectionsRTLLayout.scrollDirection = .horizontal
                    self.cityImagesSlider.collectionViewLayout = self.imgCollectionsRTLLayout
                    self.cityImagesSlider.semanticContentAttribute = .forceLeftToRight
                }
                
                self.cityImagesSlider.stopSkeletonAnimation()
                self.cityImagesSlider.hideSkeleton(reloadDataAfter: false)
                
                self.cityImagesSlider.reloadData()
                
                self.cityImagesSlider.clipsToBounds = false
                self.cityImagesSlider.superview?.clipsToBounds = false  // ✅ Allow peek to overflow parent too
                
                if let layout = self.cityImagesSlider.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.minimumLineSpacing = 8
                    layout.minimumInteritemSpacing = 0
                    layout.scrollDirection = .horizontal
                    layout.itemSize = CGSize(width: 195, height: self.cityImagesSlider.frame.height)
                    self.cityImagesSlider.collectionViewLayout.invalidateLayout()
                }
                
                // Show ~30pt peek of 3rd image
                self.cityImagesSlider.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
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
            markerView.subviews.forEach { $0.isHidden = false }
            
            if (cityMap.show_only_icon ?? "0") == "1" {
                let colors = getColors(tags: cityMap.tag_details ?? [])
                markerView.pinView.sliceColors = colors
                
                let placeName = L102Language.currentAppleLanguage() == "ar" ? cityMap.place_name_ar : cityMap.place_name
                markerView.setText(
                    text: placeName ?? "",
                    font: L102Language.currentAppleLanguage() == "ar"
                        ? UIFont(name: "Arial", size: 10)!
                        : .systemFont(ofSize: 10, weight: .semibold)
                )
                
                markerView.outerImg.tintColor = hexStringToUIColor(hex: cityMap.icon_background_color ?? "#ffffff")
                markerView.innerImg.tintColor = colors.first
                
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
            
            self.addMarker(for: cityMap, at: coordinate, using: markerView)
        }
        
        clusterManager.cluster()
        
        if let firstCoordinate = viewModel.arrayOfDetailCityMaps.place_details?.first {
            let camera = GMSCameraPosition(
                latitude: Double(firstCoordinate.lat ?? "") ?? 0.0,
                longitude: Double(firstCoordinate.lon ?? "") ?? 0.0,
                zoom: 8
            )
            mapView.animate(to: camera)
        }
    }
    
    private func addMarker(for cityMap: Place_details, at coordinate: CLLocationCoordinate2D, using markerView: MapMarkerView) {
        markerView.lblPlaceName.alpha = 1
        markerView.txtHeight.constant = 20
        markerView.layoutIfNeeded()
        let iconZoomed = renderMarkerViewAsImage(markerView: markerView)
        
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
        return tags.map { UIColor.hexStringToUIColor(hex: $0.color_code ?? "#000000") }
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
        return 3
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
            return viewModel.arrayOfCityImages.isEmpty ? 1 : viewModel.arrayOfCityImages.count
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
            return CGSize(width: collectionView.bounds.width / 2 - 10, height: 40)
        } else if collectionView == images_CollectionVw {
            return CGSize(width: collectionView.frame.width / 2, height: 110)
        } else {
            if !viewModel.arrayOfCityImages.isEmpty {
                return CGSize(width: 195, height: collectionView.frame.height)
            } else {
                return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == cityImagesSlider else { return }
        guard !viewModel.arrayOfCityImages.isEmpty else { return }
        let itemWidth: CGFloat = 195 + 8
        let pageIndex = Int(round(scrollView.contentOffset.x / itemWidth))
        guard pageIndex >= 0, pageIndex < viewModel.arrayOfCityImages.count else { return }
        imgPageControl.currentPage = pageIndex
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if skeletonView == tag_CollectionVw { return "MapTagCells" }
        if skeletonView == images_CollectionVw { return "MapCell" }
        return "CityImagesCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
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
            marker.icon = mapView.camera.zoom > 6 ? item.iconZoomed : item.iconNotZoomed
        }
    }
    
    private func buildClusterIcon(items: [AnnotationItem]) -> UIImage {
        guard let firstIcon = items.first?.iconNotZoomed else { return UIImage() }
        
        let size = CGSize(width: firstIcon.size.width, height: firstIcon.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        if items.count > 2, let secondIcon = items[1].iconNotZoomed {
            secondIcon.draw(at: CGPoint(x: 0, y: -6))
            secondIcon.draw(at: CGPoint(x: 0, y: -3))
        } else if items.count > 1, let secondIcon = items[1].iconNotZoomed {
            secondIcon.draw(at: CGPoint(x: 0, y: -3))
        }
        
        firstIcon.draw(at: CGPoint(x: 0, y: 0))
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom + 1)
        mapView.animate(to: newCamera)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let cluster = marker.userData as? GMUCluster {
            mapView.animate(toLocation: cluster.position)
            mapView.animate(toZoom: mapView.camera.zoom + 1)
            return true
        }
        return false
    }
}

// MARK: - GMSMapViewDelegate
extension AllMapsDetailVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let zoom = position.zoom
        
        let clusterDistance: UInt
        switch zoom {
        case 0...7:   clusterDistance = 75
        case 7...10:  clusterDistance = 50
        case 10...15: clusterDistance = 25
        default:      clusterDistance = 0
        }
        
        guard let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm(
            clusterDistancePoints: clusterDistance
        ) else { return }
        
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: clusterRenderer)
        clusterManager.setDelegate(self, mapDelegate: self)
        clusterManager.add(marklers)
        clusterManager.cluster()
    }
}

// MARK: - Video Setup
extension AllMapsDetailVC {
    
    func setupYouTubeThumbnail(_ urlString: String) {
        guard let videoID = extractYouTubeID(urlString) else { return }
        currentVideoLink = urlString
        videoPlayerVW.subviews.forEach { $0.removeFromSuperview() }
        
        let thumbnailURL = "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
        
        let imageView = UIImageView(frame: videoPlayerVW.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.sd_setImage(with: URL(string: thumbnailURL), placeholderImage: UIImage(systemName: "video.fill"))
        videoPlayerVW.addSubview(imageView)
        
        let overlayView = UIView(frame: videoPlayerVW.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        videoPlayerVW.addSubview(overlayView)
        
        let playButton = UIButton(type: .custom)
        playButton.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        playButton.center = CGPoint(x: videoPlayerVW.bounds.midX, y: videoPlayerVW.bounds.midY)
        playButton.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular)
        playButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
        playButton.tintColor = .white
        playButton.addTarget(self, action: #selector(openYouTubeTapped(_:)), for: .touchUpInside)
        videoPlayerVW.addSubview(playButton)
    }
    
    @objc func openYouTubeTapped(_ sender: UIButton) {
        openYouTubeVideo(currentVideoLink)
    }
    
    func openYouTubeVideo(_ urlString: String) {
        guard !urlString.isEmpty, let videoID = extractYouTubeID(urlString) else { return }
        
        let swiftUIView = YouTubePlayerView(videoID: videoID, originalURL: urlString, showCloseButton: false)
        let hostingVC = UIHostingController(rootView: swiftUIView)
        
        addChild(hostingVC)
        hostingVC.view.frame = videoPlayerVW.bounds
        hostingVC.view.backgroundColor = .clear
        hostingVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        videoPlayerVW.subviews.forEach { $0.removeFromSuperview() }
        videoPlayerVW.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
    }
    
    func extractYouTubeID(_ urlString: String) -> String? {
        if let components = URLComponents(string: urlString),
           components.host?.contains("youtube.com") == true,
           let videoID = components.queryItems?.first(where: { $0.name == "v" })?.value,
           !videoID.isEmpty {
            return videoID
        }
        
        if urlString.contains("youtu.be/"),
           let range = urlString.range(of: "youtu.be/") {
            let afterBase = String(urlString[range.upperBound...])
            let videoID = afterBase.components(separatedBy: "?").first ?? afterBase
            if !videoID.isEmpty { return videoID }
        }
        
        if urlString.contains("/shorts/"),
           let videoID = urlString.components(separatedBy: "/shorts/").last?
            .components(separatedBy: "?").first,
           !videoID.isEmpty {
            return videoID
        }
        
        return nil
    }
}
