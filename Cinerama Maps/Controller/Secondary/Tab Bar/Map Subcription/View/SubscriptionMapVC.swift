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

//class SubscriptionMapVC: UIViewController, GMUClusterManagerDelegate {
class SubscriptionMapVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var lblCityHeadline: UILabel!
    
    @IBOutlet weak var viewList: UIView!
    @IBOutlet weak var GMMapView: GMSMapView!
    var clusterManager: GMUClusterManager!
    
    @IBOutlet weak var btn_MapOt: UIButton!
    @IBOutlet weak var btn_ListOt: UIButton!
    @IBOutlet weak var listTable_Vw: UITableView!
    @IBOutlet weak var tag_Vw: UIView!
    @IBOutlet weak var tag_CollectionVw: UICollectionView!
    @IBOutlet weak var btn_TagOt: UIButton!
    @IBOutlet weak var lbl_NoDataFound: UILabel!
    
    @IBOutlet weak var btn_get_loc: UIButton!
    
    private var isProgressShowing = false
    var isDataAlreadyLoaded = false
    private var selectedTagId: String? // Drawer Selecting
    let language = k.userDefault.value(forKey: k.session.language ?? "ar") as? String
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GMMapView.settings.myLocationButton = false
        //        GMMapView.isMyLocationEnabled = true
        //        setupCustomLocationButton()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        addCustomLongPressToMap()
        let iconGenerator = GMUDefaultClusterIconGenerator()
        
        guard let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm(
            clusterDistancePoints: 75
        ) else { return }
        
        clusterRenderer = GMUDefaultClusterRenderer(
            mapView: GMMapView,
            clusterIconGenerator: iconGenerator
        )
        
        clusterRenderer.delegate = self
        clusterRenderer.animationDuration = 0.3
        
        clusterManager = GMUClusterManager(
            map: GMMapView,
            algorithm: algorithm,
            renderer: clusterRenderer
        )
        
        clusterManager.setDelegate(self, mapDelegate: self)
        
        
        clusterManager.setMapDelegate(self)
        
        
        self.listTable_Vw.register(UINib(nibName: "SubscriptionListCell", bundle: nil), forCellReuseIdentifier: "SubscriptionListCell")
        self.tag_CollectionVw.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
        self.tabBarController?.tabBar.isHidden = true
        btn_MapOt.setTitleColor(.white, for: .normal)
        btn_ListOt.setTitleColor(.black, for: .normal)
        btn_MapOt.backgroundColor = UIColor.orange
        btn_ListOt.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        bindViewModelData()
        self.GMMapView.isHidden = false
        self.listTable_Vw.isHidden = true
        self.lbl_NoDataFound.isHidden = true
        self.lblCityHeadline.text = viewModel.cityName
        applyMinimalistMapStyle()
        GMMapView.delegate = self
        if viewModel.arrayTagDetails.isEmpty {
            self.btn_TagOt.isHidden = true
        } else {
            self.btn_TagOt.isHidden = false
        }
        setHostView()
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
        guard let newAlgorithm = GMUNonHierarchicalDistanceBasedAlgorithm(
            clusterDistancePoints: clusterDistance
        ) else { return }
        
        clusterManager = GMUClusterManager(
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
            self.listTable_Vw.isHidden = true
            self.btn_get_loc.isHidden = false
            viewList.isHidden = true
            self.lbl_NoDataFound.isHidden = true
            updateAnnotations()
        } else {
            btn_MapOt.setTitleColor(.black, for: .normal)
            btn_ListOt.setTitleColor(.white, for: .normal)
            btn_MapOt.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
            btn_ListOt.backgroundColor = UIColor.orange
            self.GMMapView.isHidden = true
            viewList.isHidden = false
            self.btn_get_loc.isHidden = true
            if viewModel.arrayOfPlaceDetails.count == 0 {
                self.lbl_NoDataFound.isHidden = false
            } else {
                self.lbl_NoDataFound.isHidden = true
            }
        }
    }
    
    func setHostView() {
        let VC = GooglePlaceVM()
        let swiftUIView = MapView(viewModel: viewModel, onNavigate: { [weak self] index in
            guard let self = self else { return }
            viewModel.openType = .filter
            let nextSwiftUIView = DetailView(
                index: index,           // ✅ using the tapped index
                viewModel: viewModel,
                VM: VC
            )
            
            let hostingVC = UIHostingController(rootView: nextSwiftUIView)
            self.navigationController?.pushViewController(hostingVC, animated: true)
        })
        //
        //        let swiftUIView = MapView(viewModel: viewModel)
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
        // NEW: Show progress bar once at the start of data loading
        if !isProgressShowing {
            self.showProgressBar()
            isProgressShowing = true
        }
        
        viewModel.fetchDataFromDB(cityId: cityId ?? "")
        viewModel.fetchedFromDbSuccessfully = { [weak self] in
            self?.isDataAlreadyLoaded = true
            self?.isDBLoaded = true
            self?.listTable_Vw.reloadData()
            self?.tag_CollectionVw.reloadData()
            self?.btn_TagOt.isHidden = false
            self?.updateAnnotations()
            if let first = self?.viewModel.arrayOfPlaceDetails.first,
               let lat = Double(first.lat ?? ""),
               let lon = Double(first.lon ?? "") {
                let camera = GMSCameraPosition(latitude: lat, longitude: lon, zoom: 8)
                self?.GMMapView.setMinZoom(1, maxZoom: 20)
                self?.GMMapView.animate(to: camera)
            }
            
        }
    }
    
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
    
    func updateAnnotations(zoomLevel: Float = 10) {
        GMMapView.clear()
        marklers.removeAll()
        clusterManager.clearItems()
        
        var filteredPlaces: [Place_details] = viewModel.arrayOfPlaceDetails
        var coordinates: [CLLocationCoordinate2D] = []
        totalMarkersToLoad = filteredPlaces.count
        loadedMarkers = 0
        
        if filteredPlaces.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.hideProgressBar()
            }
            return
        }
        
        // Apply filters (unchanged)
        if selectedTagId == "favorites" {
            filteredPlaces = filteredPlaces.filter { $0.currentUserFavorite == true }
        } else if let selectedTagId = selectedTagId {
            filteredPlaces = filteredPlaces.filter { place in
                place.tag_details?.contains { $0.id == selectedTagId } ?? false
            }
        }
        
        // Use DispatchGroup to synchronize all marker loading
        let loadingGroup = DispatchGroup()
        
        for cityMap in filteredPlaces {
            let lat = Double(cityMap.lat ?? "") ?? 0.0
            let lon = Double(cityMap.lon ?? "") ?? 0.0
            let currentCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            coordinates.append(currentCoordinate)
            
            // Create marker view
            let markerView: MapMarkerView = UIView.fromNib()
            markerView.subviews.forEach { $0.isHidden = false }
            
            // Configure marker view (your existing configuration code)
            if (cityMap.show_only_icon ?? "0") == "1" {
                let colors = getColors(tags: cityMap.tag_details ?? [])
                markerView.pinView.sliceColors = colors
                markerView.setText(
                    text: (L102Language.currentAppleLanguage() == "ar" ? cityMap.place_name_ar : cityMap.place_name) ?? "Pakistan Zindabad",
                    font: L102Language.currentAppleLanguage() == "ar"
                    ? UIFont(name: "Arial", size: 10)!
                    : .systemFont(ofSize: 10, weight: .semibold)
                )
                markerView.outerImg.tintColor = hexStringToUIColor(hex: cityMap.icon_background_color ?? "#ffffff")
                markerView.innerImg.tintColor = colors.first ?? hexStringToUIColor(hex: "#BAE9EF")
                
                // Promotion color override
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
        
        // When all loading is done, cluster with the current zoom level
        loadingGroup.notify(queue: .main) {
            self.clusterManager.cluster() // This automatically uses current zoom
            self.areMarkersLoaded = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.checkIfLoadingComplete()
            }
        }
        
        // Camera adjustment
        if !coordinates.isEmpty {
            var bounds = GMSCoordinateBounds()
            for place in viewModel.arrayOfPlaceDetails {
                if let lat = Double(place.lat ?? ""), let lon = Double(place.lon ?? "") {
                    bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: lat, longitude: lon))
                }
            }
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
            GMMapView.animate(with: update)
        } else {
            let currentCamera = GMMapView.camera
            if currentCamera.zoom > 5 {
                GMMapView.animate(toZoom: 5)
            }
        }
    }
    func checkIfLoadingComplete() {
        if isDBLoaded && areMarkersLoaded {
            self.hideProgressBar()
            isProgressShowing = false
        }
    }
    
    private func addMarker(for cityMap: Place_details, at coordinate: CLLocationCoordinate2D, using markerView: MapMarkerView) {
        //            let renderedImage = renderMarkerViewAsImage(markerView: markerView)
        //            markerView.lblPlaceName.transform = .identity
        markerView.lblPlaceName.alpha = 1
        markerView.txtHeight.constant = 20
        markerView.layoutIfNeeded()
        
        let annotation = AnnotationItem(coordinate: coordinate)
        annotation.position = coordinate
        annotation.city_Address = cityMap.address
        //            annotation.icon = renderedImage
        annotation.iconZoomed = renderMarkerViewAsImage(markerView: markerView)
        markerView.lblPlaceName.alpha = 0
        markerView.txtHeight.constant = 0
        markerView.layoutIfNeeded()
        annotation.iconNotZoomed = renderMarkerViewAsImage(markerView: markerView)
        //            markerView.outerImg.image = UIImage(named: "circle-2")
        //            markerView.innerPinTop.constant = 4
        //            markerView.pinTop.constant = 4
        //            annotation.imgFor2 = renderMarkerViewAsImage(markerView: markerView)
        //            markerView.outerImg.image = UIImage(named: "circle-3")
        //            markerView.innerPinTop.constant = 5
        //            markerView.pinTop.constant = 5
        //            annotation.imgFor3 = renderMarkerViewAsImage(markerView: markerView)
        annotation.placeId = cityMap.id
        annotation.lat = cityMap.lat
        annotation.lon = cityMap.lon
        annotation.fav = cityMap.currentUserFavorite ?? false
        annotation.cityName = cityMap.place_name
        annotation.cityNameAr = cityMap.place_name_ar
        
        self.marklers.append(annotation)
        clusterManager.add(annotation)
    }
    
    //    private func addMarker(for cityMap: Place_details, at coordinate: CLLocationCoordinate2D, using markerView: MapMarkerView) {
    //        let renderedImage = renderMarkerViewAsImage(markerView: markerView)
    //        markerView.lblPlaceName.transform = .identity
    //        markerView.lblPlaceName.alpha = 1
    //        markerView.txtHeight.constant = 20
    //        markerView.frame = CGRect(x: 0, y: 0, width: 80, height: 63)
    //        markerView.layoutIfNeeded()
    //        let annotation = CustomPointAnnotation()
    //        annotation.position = coordinate
    //        annotation.city_Address = cityMap.address
    //        annotation.icon = renderedImage
    //        annotation.iconZoomed = renderMarkerViewAsImage(markerView: markerView)
    //        annotation.iconNotZoomed = renderedImage
    //        annotation.placeId = cityMap.id
    //        annotation.lat = cityMap.lat
    //        annotation.lon = cityMap.lon
    //        annotation.fav = cityMap.currentUserFavorite
    //        annotation.cityName = cityMap.place_name
    //        annotation.cityNameAr = cityMap.place_name_ar
    //
    //        self.marklers.append(annotation)
    //
    ////        DispatchQueue.main.async {
    ////            annotation.map = self.GMMapView
    ////        }
    //        let clusterItem = CustomClusterItem(marker: annotation)
    //        clusterManager.add(clusterItem)
    //
    //    }
    
    func renderMarkerViewAsImage(markerView: MapMarkerView) -> UIImage? {
        
        
        UIGraphicsBeginImageContextWithOptions(markerView.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            markerView.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func clearTagFilter() {
        selectedTagId = nil
        updateAnnotations()
    }
    
    func getColors(tags: [Tag_details]) -> [UIColor]{
        var colors:[UIColor] = []
        for tag in tags{
            colors.append(UIColor.hexStringToUIColor(hex: tag.color_code ?? "#000000"))
        }
        return colors
    }
    
}

extension SubscriptionMapVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.arrayOfPlaceDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionListCell", for: indexPath) as! SubscriptionListCell
        let obj = self.viewModel.arrayOfPlaceDetails[indexPath.row]
        
        if L102Language.currentAppleLanguage() == "en" {
            cell.lbl_Name.text = obj.place_name ?? ""
        } else {
            cell.lbl_Name.text = obj.place_name_ar ?? ""
        }
        
        cell.lbl_Distance.text = "\(R.string.localizable.awayFromYou()) \(obj.distance ?? "") \(R.string.localizable.km())"
        cell.lbl_Address.text = obj.address ?? ""
        cell.lbl_LikeCount.text = obj.total_fav_place ?? ""
        cell.lbl_DislikeCount.text = obj.total_unfav_place ?? ""
        
        if obj.fav_status == "Like" {
            cell.btn_LikeCount.tintColor = #colorLiteral(red: 0.2039215686, green: 0.6588235294, blue: 0.3254901961, alpha: 1)
        } else if obj.fav_status == "Unlike" {
            cell.btn_DislikeCount.tintColor = .red
        } else {
            cell.btn_LikeCount.tintColor = .darkGray
            cell.btn_DislikeCount.tintColor = .darkGray
        }
        
        cell.arrayOfTag = obj.tag_details ?? []
        cell.tags_Collection.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openPlaceDetail(placeDetail: self.viewModel.arrayOfPlaceDetails[indexPath.row])
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

extension SubscriptionMapVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.arrayTagDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        let obj = self.viewModel.arrayTagDetails[indexPath.row]
        cell.lbl_TagName.text = obj.tag_name ?? ""
        cell.lbl_TagName.backgroundColor = hexStringToUIColor(hex: obj.color_code ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 127, height: collectionView.frame.height)
    }
}

//extension SubscriptionMapVC: GMSMapViewDelegate {


//    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        let zoom = position.zoom
//        if !isMapUpdating && !marklers.isEmpty {
//            isMapUpdating = true
//            marklers.forEach { (marker) in
//                if zoom > 16 {
//                    marker.icon = marker.iconZoomed
//                } else {
//                    marker.icon = marker.iconNotZoomed
//                }
//            }
//            isMapUpdating = false
//        }
//    }


//    func animateMarker(_ markerView: MapMarkerView) {
//        // Start above the final position
//        markerView.lblPlaceName.transform = CGAffineTransform(translationX: 0, y: -10)
//        markerView.lblPlaceName.alpha = 0
//        markerView.txtHeight.constant = 0
//
//        // Simple animation
//        UIView.animate(withDuration: 0.3) {
//            markerView.lblPlaceName.transform = .identity
//            markerView.lblPlaceName.alpha = 1
//            markerView.txtHeight.constant = 20
//
//
//        }completion: { _ in
//            markerView.frame = CGRect(x: 0, y: 0, width: 80, height: 63)
//            markerView.layoutIfNeeded()
//
//        }
//
//    }
//
//
//}

extension SubscriptionMapVC: GMUClusterManagerDelegate, GMUClusterRendererDelegate {
    //    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
    //        guard
    //            let items = ([object] as? [AnnotationItem])
    //                ?? (object as? GMUStaticCluster)?.items as? [AnnotationItem],
    //            let firstItem = items.first
    //        else { return nil }
    //
    //        let marker = GMSMarker()
    //
    //        if items.count > 2 {
    //            marker.icon = firstItem.imgFor3
    //        } else if items.count > 1{
    //            marker.icon = firstItem.imgFor2
    //        }else{
    //            marker.icon = firstItem.imgFor2
    //        }
    //        marker.position = firstItem.position
    //        marker.userData = firstItem
    //        return marker
    //    }
    
    //    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
    //        if let cluster = marker.userData as? GMUCluster {
    //
    //            if cluster.items.count > 2, let firstItem = cluster.items.first as? AnnotationItem {
    //                marker.icon = firstItem.imgFor3
    //            } else if cluster.items.count > 1, let firstItem = cluster.items.first as? AnnotationItem {
    //                marker.icon = firstItem.imgFor2
    //            }else if cluster.items.count == 1, let firstItem = cluster.items.first as? AnnotationItem {
    //                marker.icon = firstItem.iconNotZoomed
    //            }
    //        } else if let item = marker.userData as? AnnotationItem {
    //            marker.icon = item.iconNotZoomed
    //        }
    //    }
    
    
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
    }
    
    //    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    //
    //        let zoom = position.zoom
    //        let newDistance: UInt
    //
    //        switch zoom {
    //        case 0...8:
    //            newDistance = 120
    //        case 8...12:
    //            newDistance = 80
    //        case 12...15:
    //            newDistance = 40
    //        case 15...18:
    //            newDistance = 20
    //        default:
    //            newDistance = 10
    //        }
    //
    //        clusterAlgorithm.clusterDistancePoints = newDistance
    //        clusterManager.cluster()
    //    }
    
    private func addCustomLongPressToMap() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        longPress.delegate = self
        GMMapView.addGestureRecognizer(longPress)
    }
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: GMMapView)
        let coordinate = GMMapView.projection.coordinate(for: point)
        
        switch gesture.state {
        case .began:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            
            for item in marklers {
                let markerPoint = GMMapView.projection.point(for: item.position)
                let dx = point.x - markerPoint.x
                let dy = point.y - markerPoint.y
                let distance = sqrt(dx * dx + dy * dy)
                
                if distance < 50 {
                    showToast(message: "      \((L102Language.currentAppleLanguage() == "ar" ? item.cityNameAr : item.cityName) ?? "Unknown Place") ", font: .systemFont(ofSize: 12))
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
    
    //`    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
    //        let pressedPoint = mapView.projection.point(for: coordinate)
    //
    //        for item in marklers {
    //            let markerPoint = mapView.projection.point(for: item.position)
    //
    //            let dx = pressedPoint.x - markerPoint.x
    //            let dy = pressedPoint.y - markerPoint.y
    //            let screenDistance = sqrt(dx*dx + dy*dy)
    //
    //            if screenDistance < 50 {
    //                let generator = UIImpactFeedbackGenerator(style: .medium)
    //                    generator.impactOccurred()
    //                self.showToast(
    //                message: "   \(item.cityName ?? "Unknown Place")   ",
    //                font: .systemFont(ofSize: 12.0))
    //                return
    //            }
    //        }
    //
    //    }`
    
}

extension SubscriptionMapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        //        let myIcon = UIImage(named: "ic_pin2")
        //        let imageView = UIImageView(image: myIcon)
        //        imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        //        imageView.contentMode = .scaleAspectFit
        //        let userMarker = GMSMarker()
        //        userMarker.position = location.coordinate
        //        userMarker.iconView = imageView
        //        userMarker.map = GMMapView
        
        let camera = GMSCameraPosition.camera(
            withLatitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: 15
        )
        GMMapView.animate(to: camera)
        
        locationManager.stopUpdatingLocation()
        //        locationManager.delegate = nil // Optional: fully disable further updates
        
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
