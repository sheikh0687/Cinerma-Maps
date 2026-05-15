//
//  SubscriptionMapVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 25/10/24.
//

import UIKit
import GoogleMaps
import SwiftUI
import GoogleMapsUtils
import CoreLocation

class SubscriptionMapVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var lblCityHeadline: UILabel!
    
    @IBOutlet weak var viewList: UIView!
    @IBOutlet weak var GMMapView: GMSMapView!
    
    @IBOutlet weak var btn_MapOt: UIButton!
    @IBOutlet weak var btn_ListOt: UIButton!
    @IBOutlet weak var tag_Vw: UIView!
    @IBOutlet weak var btn_TagOt: UIButton!
    
    @IBOutlet weak var btn_get_loc: UIButton!
    
    var clusterManager: GMUClusterManager!
    private var isProgressShowing = false
    var isDataAlreadyLoaded = false
    private var selectedTagId: String? // Drawer Selecting
    
    let language = L102Language.currentAppleLanguage()
    let viewModel = SubscriptionMapViewModel()
    var marklers:[AnnotationItem] = []
    var locationManager: CLLocationManager!
    var cityId: String?
    var totalMarkersToLoad = 0
    var isDBLoaded = false
    var areMarkersLoaded = false
    var loadedMarkers = 0
    var clusterRenderer: GMUDefaultClusterRenderer!
    var toastlbl: UILabel?
    
    private var mapTransformApplied = false
    private var mapFirstIdleDone = false
    
    private var loadingOverlay: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GMMapView.settings.myLocationButton = false
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        addCustomLongPressToMap()
        
        let iconGenerator = GMUDefaultClusterIconGenerator()
        
        guard let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm (
            clusterDistancePoints: 75
        ) else { return }
        
        clusterRenderer = GMUDefaultClusterRenderer (
            mapView: GMMapView,
            clusterIconGenerator: iconGenerator
        )
        
        clusterRenderer.delegate = self
        clusterRenderer.animationDuration = 0.3
        
        clusterManager = GMUClusterManager (
            map: GMMapView,
            algorithm: algorithm,
            renderer: clusterRenderer
        )
        
        clusterManager.setDelegate(self, mapDelegate: self)
        
        clusterManager.setMapDelegate(self)
        
        self.tabBarController?.tabBar.isHidden = true
        
        btn_MapOt.setTitleColor(.white, for: .normal)
        btn_ListOt.setTitleColor(.black, for: .normal)
        btn_MapOt.backgroundColor = UIColor.orange
        btn_ListOt.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        
        self.GMMapView.isHidden = true
        self.btn_TagOt.isHidden = true
        self.btn_get_loc.isHidden = true

        self.lblCityHeadline.text = viewModel.cityName
        
        applyMinimalistMapStyle()
        
        GMMapView.delegate = self

        setHostView()
        
        showLoadingOverlay()
        
        bindViewModelData()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        // Apply only once, after GMSMapView has fully built its internal subview tree
//        guard !mapTransformApplied, L102Language.isRTL else { return }
//        mapTransformApplied = true
//        applyRTLMapTransform()
//    }
//
//    private func applyRTLMapTransform() {
//        guard L102Language.isRTL else { return }
//        
//        let mirror = CGAffineTransform(scaleX: -1, y: 1)
//        
//        // Flip the entire map surface
//        GMMapView.transform = mirror
//        
//        // Counter-flip every internal subview so tiles/labels stay correct
//        counterFlipSubviews(GMMapView, mirror: mirror)
//    }
//    
//    private func counterFlipSubviews(_ view: UIView, mirror: CGAffineTransform) {
//        for subview in view.subviews {
//            subview.transform = mirror
//            counterFlipSubviews(subview, mirror: mirror)
//        }
//    }

//    private func applyRTLMapTransform() {
//        guard L102Language.isRTL else { return }
//        
//        let mirror = CGAffineTransform(scaleX: -1, y: 1)
//        GMMapView.transform = mirror
//        
//        // Counter-flip all subviews
//        fixSubviews(of: GMMapView, mirror: mirror)
//        
//        // ✅ Force counter-flip the Google logo specifically after everything else
//        restoreGoogleAttributionViews(in: GMMapView)
//    }
//    
//    private func restoreGoogleAttributionViews(in view: UIView) {
//        for subview in view.subviews {
//            if isGoogleAttributionView(subview) {
//                // Remove any transform applied by fixSubviews, restore to identity
//                subview.transform = .identity
//            } else {
//                restoreGoogleAttributionViews(in: subview)
//            }
//        }
//    }
//    
//    private func fixSubviews(of view: UIView, mirror: CGAffineTransform) {
//        
//        for subview in view.subviews {
//            
//            if isGoogleAttributionView(subview) {
//                // 🚫 Never touch Google logo / legal attribution
//                continue
//            }
//            
//            // Counter flip
//            subview.transform = mirror
//            
//            // 🔁 Go deeper (Google logo lives deep inside)
//            fixSubviews(of: subview, mirror: mirror)
//        }
//    }
//    
//    private func isGoogleAttributionView(_ view: UIView) -> Bool {
//        let className = String(describing: type(of: view)).lowercased()
//        
//        if className.contains("attribution") ||
//           className.contains("legal") ||
//           className.contains("gmss") ||
//           className.contains("gms") {
//            return true
//        }
//        
//        // ✅ Catch UIImageView that holds the Google logo (small, bottom area)
//        if view is UIImageView {
//            let size = view.bounds.size
//            if size.width > 0 && size.width < 100 && size.height < 40 {
//                if view.frame.origin.y > GMMapView.frame.height * 0.7 {
//                    return true
//                }
//            }
//        }
//        
//        // Existing size/position fallback
//        let size = view.bounds.size
//        if size.width < 120 && size.height < 40 {
//            if view.frame.origin.y > GMMapView.frame.height - 80 {
//                return true
//            }
//        }
//        
//        return false
//    }
    
    private func showLoadingOverlay() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.systemBackground
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // ── Card container ──────────────────────────────────────────
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 24
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.10
        card.layer.shadowOffset = CGSize(width: 0, height: 8)
        card.layer.shadowRadius = 20
        card.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(card)

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: overlay.centerYAnchor, constant: -30),
            card.widthAnchor.constraint(equalToConstant: 200),
            card.heightAnchor.constraint(equalToConstant: 160)
        ])

        // ── Pulse ring behind pin ────────────────────────────────────
        let pulseRing = UIView()
        pulseRing.backgroundColor = UIColor.orange.withAlphaComponent(0.15)
        pulseRing.layer.cornerRadius = 40
        pulseRing.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(pulseRing)

        NSLayoutConstraint.activate([
            pulseRing.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            pulseRing.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: -14),
            pulseRing.widthAnchor.constraint(equalToConstant: 80),
            pulseRing.heightAnchor.constraint(equalToConstant: 80)
        ])

        // ── Map pin icon ─────────────────────────────────────────────
        let pinImageView = UIImageView()
        let pinConfig = UIImage.SymbolConfiguration(pointSize: 38, weight: .medium)
        pinImageView.image = UIImage(systemName: "mappin.circle.fill", withConfiguration: pinConfig)
        pinImageView.tintColor = .orange
        pinImageView.contentMode = .scaleAspectFit
        pinImageView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(pinImageView)

        NSLayoutConstraint.activate([
            pinImageView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            pinImageView.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: -14),
            pinImageView.widthAnchor.constraint(equalToConstant: 52),
            pinImageView.heightAnchor.constraint(equalToConstant: 52)
        ])

        // ── Loading label ────────────────────────────────────────────
        let titleLabel = UILabel()
        titleLabel.text = L102Language.currentAppleLanguage() == "en" ? "Loading Map" : "جاري تحميل الخريطة"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor.label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: pinImageView.bottomAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor)
        ])

        view.addSubview(overlay)
        loadingOverlay = overlay

        // ── Pulse animation ──────────────────────────────────────────
        UIView.animate (
            withDuration: 1.0,
            delay: 0,
            options: [.repeat, .autoreverse, .curveEaseInOut],
            animations: {
                pulseRing.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                pulseRing.alpha = 0.3
            }
        )

        // ── Pin bounce animation ─────────────────────────────────────
        UIView.animate (
            withDuration: 0.6,
            delay: 0.1,
            options: [.repeat, .autoreverse, .curveEaseInOut],
            animations: {
                pinImageView.transform = CGAffineTransform(translationX: 0, y: -6)
            }
        )
    }

    private func revealMapWithFade() {
        GMMapView.isHidden = false
        btn_get_loc.isHidden = false
        btn_TagOt.isHidden = false

        UIView.animate(withDuration: 0.35, animations: {
            self.loadingOverlay?.alpha = 0
        }) { _ in
            self.loadingOverlay?.removeFromSuperview()
            self.loadingOverlay = nil
            // ✅ Restore animation for subsequent user interactions
            self.clusterRenderer.animationDuration = 0.3
        }
    }
    
    private func updateClusterAlgorithm(for zoom: Float) {
        
        let clusterDistance: UInt
        
        switch zoom {
        case 0...8:
            clusterDistance = 100
        case 8...12:
            clusterDistance = 75
        case 12...15:
            clusterDistance = 40
        case 15...18:
            clusterDistance = 20
        default:
            clusterDistance = 0
        }
        
        // 🔥 Create new algorithm only
        guard let newAlgorithm = GMUNonHierarchicalDistanceBasedAlgorithm (
            clusterDistancePoints: clusterDistance
        ) else { return }
        
        clusterManager = GMUClusterManager (
            map: GMMapView,
            algorithm: newAlgorithm,
            renderer: clusterRenderer
        )
        
        clusterManager.setDelegate(self, mapDelegate: self)
        
        // 🔥 Re-add existing items
        clusterManager.add(marklers)
        
        // 🔥 Re-cluster (this keeps animation smooth)
        clusterManager.cluster()
    }
    
    @IBAction func Did_loc_tap(_ sender: UIButton) {
        guard let location = locationManager.location else {
            locationManager.requestLocation()
            return
        }
        GMMapView.isMyLocationEnabled = true
        let camera = GMSCameraPosition.camera(
            withLatitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: 15
        )
        GMMapView.animate(to: camera)
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        let swiftUIView = SearchMapView(viewModel: viewModel)
            .environment(\.layoutDirection, (language == "ar") ? .rightToLeft : .leftToRight)
        let hostingController = UIHostingController(rootView: swiftUIView)
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    @IBAction func btn_MapAndList(_ sender: UIButton) {
        if sender.tag == 0 {
            btn_MapOt.setTitleColor(.white, for: .normal)
            btn_ListOt.setTitleColor(.black, for: .normal)
            btn_MapOt.backgroundColor = UIColor.orange
            btn_ListOt.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
            self.GMMapView.isHidden = false
            self.btn_get_loc.isHidden = false
            viewList.isHidden = true
//            updateAnnotations()
        } else {
            btn_MapOt.setTitleColor(.black, for: .normal)
            btn_ListOt.setTitleColor(.white, for: .normal)
            btn_MapOt.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
            btn_ListOt.backgroundColor = UIColor.orange
            self.GMMapView.isHidden = true
            viewList.isHidden = false
            self.btn_get_loc.isHidden = true
        }
    }
    
    func setHostView() {
        let VC = GooglePlaceVM()
        let swiftUIView = MapView(viewModel: viewModel, onNavigate: { [weak self] index in
            guard let self = self else { return }
            
            viewModel.openType = .filter
            
            let nextSwiftUIView = DetailView (
                index: index,           // ✅ using the tapped index
                viewModel: viewModel,
                VM: VC
            )
            
            let hostingVC = UIHostingController(rootView: nextSwiftUIView)
            self.navigationController?.pushViewController(hostingVC, animated: true)
        })
        .environment(\.layoutDirection, language == "ar" ? .rightToLeft : .leftToRight)
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // Add as a child view controller
        addChild(hostingController)
        viewList.addSubview(hostingController.view)
        
        // Set the frame or constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: viewList.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: viewList.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: viewList.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: viewList.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    @IBAction func btn_Back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_OpenTag(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SideDrawerVC") as? SideDrawerVC {
            vc.navController = navigationController
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.tags = viewModel.arrayTagDetails
            vc.favoriteTags = viewModel.arrayOfPlaceDetails.filter({$0.currentUserFavorite == true})
            vc.openPlaceDetail = openPlaceDetail(placeDetail:)
            
            vc.onTagSelected = { [weak self] tagId in
                self?.selectedTagId = tagId == "favorites" ? "favorites" : tagId
                self?.updateAnnotations()
            }
            // ends
            present(vc, animated: false)
        }
    }
    
    @IBAction func btn_TagClose(_ sender: UIButton) {
        self.tag_Vw.isHidden = true
    }
    
    func bindViewModelData() {
        viewModel.fetchDataFromDB(cityId: cityId ?? "")
        
        viewModel.fetchedFromDbSuccessfully = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isDataAlreadyLoaded = true
                self.isDBLoaded = true
                // Load all markers — reveal map only when done
                self.updateAnnotations(fitCameraAfterLoad: true, onReady: {
                    self.revealMapWithFade()
                })
            }
        }
    }
    
//    func bindViewModelData() {
////        if !isProgressShowing {
////            self.showProgressBar()
////            isProgressShowing = true
////        }
//        
//        viewModel.fetchDataFromDB(cityId: cityId ?? "")
//        viewModel.fetchedFromDbSuccessfully = { [weak self] in
//            guard let self else { return }
//            DispatchQueue.main.async {
//                self.isDataAlreadyLoaded = true
//                self.isDBLoaded = true
//                self.btn_TagOt.isHidden = false
//                // ✅ Step 1: Instantly move camera to city location first
//                let camera = GMSCameraPosition(
//                    latitude: self.viewModel.cityLat,
//                    longitude: self.viewModel.cityLon,
//                    zoom: 8
//                )
//                self.GMMapView.setMinZoom(1, maxZoom: 20)
//                self.GMMapView.camera = camera  // ✅ Use direct set, not animate — so it's instant
//
//                // ✅ Step 2: Load markers, and fit camera only after they're ready
//                self.updateAnnotations(fitCameraAfterLoad: true)
//            }
//        }
//    }

    func applyMinimalistMapStyle() {
        let minimalistStyle = """
            [
              {"featureType":"poi","elementType":"labels.icon","stylers":[{"visibility":"off"}]},
              {"featureType":"poi","elementType":"labels.text","stylers":[{"visibility":"off"}]},
              {"featureType":"poi","elementType":"geometry","stylers":[{"visibility":"off"}]},
              {"featureType":"transit","elementType":"all","stylers":[{"visibility":"off"}]},
              {"featureType":"road","elementType":"labels.icon","stylers":[{"visibility":"off"}]},
              {"featureType":"road","elementType":"labels.text","stylers":[{"visibility":"simplified"}]}
            ]
            """
        do {
            GMMapView.mapStyle = try GMSMapStyle(jsonString: minimalistStyle)
            print("Map style applied from string")
        } catch {
            print("Error applying map style from string: \(error)")
        }
    }
    
    func updateAnnotations(zoomLevel: Float = 10, fitCameraAfterLoad: Bool = true, onReady: (() -> Void)? = nil) {
        GMMapView.clear()
        marklers.removeAll()
        clusterManager.clearItems()
        
        var filteredPlaces: [Place_details] = viewModel.arrayOfPlaceDetails
        
        totalMarkersToLoad = filteredPlaces.count
        loadedMarkers = 0
        
        if filteredPlaces.isEmpty {
            onReady?()
            return
        }
        
        // Apply filters
        if selectedTagId == "favorites" {
            filteredPlaces = filteredPlaces.filter { $0.currentUserFavorite == true }
        } else if let selectedTagId = selectedTagId {
            filteredPlaces = filteredPlaces.filter { place in
                place.tag_details?.contains { $0.id == selectedTagId } ?? false
            }
        }
        
        var coordinates: [CLLocationCoordinate2D] = []
        let loadingGroup = DispatchGroup()
        
        for cityMap in filteredPlaces {
            let lat = Double(cityMap.lat ?? "") ?? 0.0
            let lon = Double(cityMap.lon ?? "") ?? 0.0
            let currentCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            coordinates.append(currentCoordinate)
            
            let markerView: MapMarkerView = UIView.fromNib()
            markerView.subviews.forEach { $0.isHidden = false }
            
            if (cityMap.show_only_icon ?? "0") == "1" {
                let colors = getColors(tags: cityMap.tag_details ?? [])
                markerView.pinView.sliceColors = colors
                markerView.setText (
                    text: (L102Language.currentAppleLanguage() == "ar" ? cityMap.place_name_ar : cityMap.place_name) ?? "",
                    font: L102Language.currentAppleLanguage() == "ar"
                    ? UIFont(name: "Arial", size: 10)!
                    : .systemFont(ofSize: 10, weight: .semibold)
                )
                
                if let endDateString = cityMap.end_date, !(cityMap.promo_code_and_discount?.isEmpty ?? true) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    if let endDate = dateFormatter.date(from: endDateString), endDate >= Date() {
                        markerView.outerImg.tintColor = UIColor.hexStringToUIColor(hex: "#F1D280")
                    } else {
                        markerView.outerImg.tintColor = .white
                    }
                } else {
                    markerView.outerImg.tintColor = .white
                }
                
                markerView.innerImg.tintColor = colors.first ?? hexStringToUIColor(hex: "#BAE9EF")
                
                loadingGroup.enter()
                
                if let iconUrl = cityMap.icon {
                    Utility.imageWithSDWebImage(iconUrl, markerView.mapIcon) {
                        self.addMarker(for: cityMap, at: currentCoordinate, using: markerView)
                        self.loadedMarkers += 1
                        loadingGroup.leave()
                    }
                } else {
                    self.addMarker(for: cityMap, at: currentCoordinate, using: markerView)
                    self.loadedMarkers += 1
                    loadingGroup.leave()
                }
            } else {
                loadingGroup.enter()
                markerView.shadowImg.isHidden = true
                markerView.innerImg.isHidden = true
                markerView.pinView.isHidden = true
                markerView.mapIcon.isHidden = true
                markerView.outerImg.isHidden = false
                
                if let iconUrl = cityMap.icon {
                    Utility.imageWithSDWebImage(iconUrl, markerView.outerImg) {
                        self.addMarker(for: cityMap, at: currentCoordinate, using: markerView)
                        self.loadedMarkers += 1
                        loadingGroup.leave()
                    }
                } else {
                    self.addMarker(for: cityMap, at: currentCoordinate, using: markerView)
                    self.loadedMarkers += 1
                    loadingGroup.leave()
                }
            }
        }
        
        loadingGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }

            // ✅ Step 1: Set camera silently while map is still hidden
            if fitCameraAfterLoad, !coordinates.isEmpty {
                var bounds = GMSCoordinateBounds()
                for coord in coordinates {
                    bounds = bounds.includingCoordinate(coord)
                }
                self.GMMapView.setMinZoom(1, maxZoom: 20)
                // ✅ moveCamera (not animate) — instant, no flash, map still hidden
                self.GMMapView.moveCamera(GMSCameraUpdate.fit(bounds, withPadding: 50))
            }

            // ✅ Step 2: Cluster markers while map is still hidden
            self.clusterRenderer.animationDuration = 0
            self.clusterManager.cluster()
            self.areMarkersLoaded = true
            self.checkIfLoadingComplete()

            // ✅ Step 3: Wait one runloop cycle for GMSMapView to finish
            // internal render pass before revealing — this eliminates the blink
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                guard let self else { return }
                onReady?()
            }
        }
    }
    
    func checkIfLoadingComplete() {
        if isDBLoaded && areMarkersLoaded {
            isProgressShowing = false
        }
    }
    
    private func addMarker(for cityMap: Place_details, at coordinate: CLLocationCoordinate2D, using markerView: MapMarkerView) {
        let colors = getColors(tags: cityMap.tag_details ?? [])
        let onlyIcon = (cityMap.show_only_icon ?? "0") == "1"
        let name = (L102Language.currentAppleLanguage() == "ar" ? cityMap.place_name_ar : cityMap.place_name) ?? ""
        let fav = cityMap.currentUserFavorite ?? false
        
        // Use a persistent cache to avoid re-rendering markers that haven't changed
        let keyNotZoomed = MarkerImageCache.shared.generateKey(placeId: cityMap.icon ?? "", isZoomed: false, fav: fav, colors: colors, onlyIcon: onlyIcon, name: nil)
        let keyZoomed = MarkerImageCache.shared.generateKey(placeId: cityMap.icon ?? "", isZoomed: true, fav: fav, colors: colors, onlyIcon: onlyIcon, name: name)
        
        let annotation = AnnotationItem(coordinate: coordinate)
        annotation.position = coordinate
        annotation.city_Address = cityMap.address
        annotation.placeId = cityMap.id
        annotation.lat = cityMap.lat
        annotation.lon = cityMap.lon
        annotation.fav = fav
        annotation.cityName = cityMap.place_name
        annotation.cityNameAr = cityMap.place_name_ar
        
        // Render or get from cache for Zoomed state (with text)
        if let cachedZoomed = MarkerImageCache.shared.getImage(for: keyZoomed) {
            annotation.iconZoomed = cachedZoomed
        } else {
            markerView.lblPlaceName.alpha = 1
            markerView.txtHeight.constant = 20
            markerView.layoutIfNeeded()
            if let image = renderMarkerViewAsImage(markerView: markerView) {
                annotation.iconZoomed = image
                MarkerImageCache.shared.setImage(image, for: keyZoomed)
            }
        }
        
        // Render or get from cache for Non-Zoomed state (without text)
        // This is highly reusable across markers with same icons/colors
        if let cachedNotZoomed = MarkerImageCache.shared.getImage(for: keyNotZoomed) {
            annotation.iconNotZoomed = cachedNotZoomed
        } else {
            markerView.lblPlaceName.alpha = 0
            markerView.txtHeight.constant = 0
            markerView.layoutIfNeeded()
            if let image = renderMarkerViewAsImage(markerView: markerView) {
                annotation.iconNotZoomed = image
                MarkerImageCache.shared.setImage(image, for: keyNotZoomed)
            }
        }
        
        self.marklers.append(annotation)
        clusterManager.add(annotation)
    }
    
    func renderMarkerViewAsImage(markerView: MapMarkerView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: markerView.bounds.size)
        return renderer.image { context in
            markerView.layer.render(in: context.cgContext)
        }
    }
    
//    func clearTagFilter() {
//        selectedTagId = nil
//        updateAnnotations()
//    }
    
    func getColors(tags: [Tag_details]) -> [UIColor] {
        var colors:[UIColor] = []
        for tag in tags{
            colors.append(UIColor.hexStringToUIColor(hex: tag.color_code ?? "#000000"))
        }
        return colors
    }
    
    func openPlaceDetail(placeDetail: Place_details) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GooglePlaceDetailVC") as! GooglePlaceDetailVC
        let obj = placeDetail
        vC.viewModel.place_Id = obj.id ?? ""
        vC.viewModel.val_Address = obj.address ?? ""
        vC.viewModel.lat = obj.lat ?? ""
        vC.viewModel.lon = obj.lon ?? ""
        vC.viewModel.isFav = obj.currentUserFavorite ?? false
        vC.viewModel.sendDataBack = {[weak self] isfav,placeId in
            guard let self else { return }
            print(isfav)
            print(placeId)
            if let index = viewModel.arrayOfPlaceDetails.firstIndex(where: { $0.placeid == placeId }) {
                viewModel.arrayOfPlaceDetails[index].currentUserFavorite = isfav
            }
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
}

extension SubscriptionMapVC: GMUClusterManagerDelegate, GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let cluster = marker.userData as? GMUCluster {
            let items = cluster.items.compactMap { $0 as? AnnotationItem }
            if items.count > 1 {
                marker.icon = buildClusterIcon(items: items)
            }
        } else if let item = marker.userData as? AnnotationItem {
            marker.icon = item.iconZoomed
        }
    }
    
    private func buildClusterIcon(items: [AnnotationItem]) -> UIImage {
        guard let firstIcon = items.first?.iconNotZoomed else {
            return UIImage()
        }
        
        let width = firstIcon.size.width
        let height = firstIcon.size.height
        
        // Start graphics context
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
        
        // Always draw the first icon on top
        firstIcon.draw(at: CGPoint(x: 0, y: 0))
        
        let combined = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        return combined
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.animate(toLocation: marker.position)
        let item: AnnotationItem?
        if let cluster = marker.userData as? GMUCluster {
            mapView.animate(toZoom: mapView.camera.zoom + 1)
            item = cluster.items.first as? AnnotationItem
        } else {
            item = marker.userData as? AnnotationItem
        }
        if let custom = item {
            let fav = viewModel.arrayOfPlaceDetails.first { $0.placeid == custom.placeId }?.currentUserFavorite ?? false
            viewModel.navigateToGooglePlaceDetailViewController(
                from: navigationController!,
                cityAddress: custom.city_Address ?? "",
                cityPlaceId: custom.placeId ?? "",
                cityAddressLat: custom.lat ?? "",
                cityAddressLon: custom.lon ?? "",
                isFav: fav
            )
            return true
        }
        return false
    }
    
}

extension SubscriptionMapVC: GMSMapViewDelegate {
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        locationManager.startUpdatingLocation()
        GMMapView.isMyLocationEnabled = true
        return true
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        updateClusterAlgorithm(for: position.zoom)
        
//        if !mapFirstIdleDone && L102Language.isRTL {
//            mapFirstIdleDone = true
//            applyRTLMapTransform()
//        }
        
//        // ✅ Always re-check on idle — Google logo may have been added late
//        if L102Language.isRTL {
//            restoreGoogleAttributionViews(in: GMMapView)
//        }
    }
    
    private func addCustomLongPressToMap() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        longPress.delegate = self
        GMMapView.addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: GMMapView)
        _ = GMMapView.projection.coordinate(for: point)
        
        switch gesture.state {
        case .began:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            
            for item in marklers {
                let markerPoint = GMMapView.projection.point(for: item.position)
                let dx = point.x - markerPoint.x
                let dy = point.y - markerPoint.y
                let distance = sqrt(dx * dx + dy * dy)
                
                if distance < 50 {
                    showToast(message: "      \((L102Language.isRTL ? item.cityNameAr : item.cityName) ?? "Unknown Place") ", font: .systemFont(ofSize: 12))
                    return
                }
            }
            
        case .ended, .cancelled, .failed:
            hideToast()
            
        default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension SubscriptionMapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let camera = GMSCameraPosition.camera(
            withLatitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: 15
        )
        GMMapView.animate(to: camera)
        
        locationManager.stopUpdatingLocation()
    }
}

extension SubscriptionMapVC {
    func showToast(message: String, font: UIFont) {
        hideToast()
        
        let toast = UILabel()
        toast.backgroundColor = UIColor.main
        toast.textColor = .white
        toast.font = font
        toast.textAlignment = .center
        toast.text = message
        toast.layer.cornerRadius = 10
        toast.clipsToBounds = true
        toast.numberOfLines = 0
        toast.alpha = 1.0
        
        let maxSize = CGSize(width: view.frame.width - 40, height: .greatestFiniteMagnitude)
        var expectedSize = toast.sizeThatFits(maxSize)
        expectedSize.width += 20
        expectedSize.height += 10
        
        let topPadding = view.safeAreaInsets.top
        toast.frame = CGRect(
            x: (view.frame.width - expectedSize.width) / 2,
            y: topPadding + 180,
            width: expectedSize.width,
            height: expectedSize.height
        )
        
        view.addSubview(toast)
        toastlbl = toast
    }
    
    func hideToast() {
        guard let toast = toastlbl else { return }
        UIView.animate(withDuration: 0.2, animations: {
            toast.alpha = 0
        }) { _ in
            toast.removeFromSuperview()
            self.toastlbl = nil
        }
    }
}
