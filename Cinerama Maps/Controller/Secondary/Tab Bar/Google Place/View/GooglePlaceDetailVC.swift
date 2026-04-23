//
//  GooglePlaceDetailVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 06/11/24.
//

import UIKit
import WebKit

class GooglePlaceDetailVC: UIViewController {
    
    @IBOutlet weak var placeImg_Collection: UICollectionView!
    @IBOutlet weak var page_Controller: UIPageControl!
    
    @IBOutlet weak var tag_Collection: UICollectionView!
    @IBOutlet weak var favImg: UIImageView!
    @IBOutlet weak var timeSchedule_Collection: UICollectionView!
    @IBOutlet weak var rating_TableVw: UITableView!
    
    @IBOutlet weak var lbl_PlaceName: UILabel!
    @IBOutlet weak var lbl_OpenCloseStatus: UILabel!
    @IBOutlet weak var lbl_Km: UILabel!
    @IBOutlet weak var wv_PlaceDescription: WKWebView!
  
    @IBOutlet weak var lbl_PhoneNum: UILabel!
    @IBOutlet weak var lbl_WebsiteLink: UILabel!
    
    @IBOutlet weak var btn_LikeOt: UIButton!
    @IBOutlet weak var btn_DislikeOt: UIButton!
    
    @IBOutlet weak var lbl_WorthVisit: UILabel!
    @IBOutlet weak var lbl_WorthNotVisit: UILabel!
    @IBOutlet weak var lbl_PromoCode: UILabel!
    
    var viewModel: GooglePlaceVM
    
//    var mapType:String = ""
//    var nameOfMap:String = ""
    var cityiD:String = ""
    var placeId:String = ""
    var serviceiD:String = ""
    
    var vedioUrl:String = ""
    
    var arrayOfBothImages: [String] = []
    
    init(viewModel: GooglePlaceVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        // Provide a default ViewModel to avoid crash
        self.viewModel = GooglePlaceVM()   //Replace with proper default if needed
        super.init(coder: coder)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tag_Collection.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
        self.timeSchedule_Collection.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
        self.rating_TableVw.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        bindDataToVC()
        favImg.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(favoriteButtonTapped))
        favImg.addGestureRecognizer(tapGesture)
    }
    
    
    private func bindDataToVC() {
        viewModel.fetchPlaceId(vC: self)
        viewModel.generatedSuccessfull = { [self] generatedPlaceId in
            viewModel.fetchGooglePlaceDetail(vC: self, placeId: generatedPlaceId, tagCollection: tag_Collection, weekCollection: timeSchedule_Collection, ratingTable: rating_TableVw)
            
            viewModel.fetchedDetailSuccessfull = { [self] in
                DispatchQueue.main.async { [self] in
                    // Update UI with place details
                    let obj = self.viewModel.arrayPlaceDetail
                    favImg.image = obj?.currentUserFavorite ?? false ? UIImage(systemName:"heart.fill" ) : UIImage(systemName:"heart" )
                    self.favImg.tintColor = obj?.currentUserFavorite ?? false ? .red : .lightGray
                    
                    let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>body { font-family: 'Avenir-Book'; font-size: 16px; color: black; }</style></header>"

                    if L102Language.currentAppleLanguage() == "en" {
                        self.lbl_PlaceName.text = obj?.place_name
                        let html = obj?.description ?? ""
                        self.wv_PlaceDescription.loadHTMLString(headerString + html, baseURL: nil)
                    } else {
                        self.lbl_PlaceName.text = obj?.place_name_ar
                        let html = obj?.description_ar ?? ""
                        self.wv_PlaceDescription.loadHTMLString(headerString + html, baseURL: nil)
                    }
                    
                    self.lbl_PromoCode.text = "\(R.string.localizable.promoCode()) \(obj?.promo_code_and_discount ?? "")\n (\("R.string.localizable.start()") - \(obj?.start_date ?? ""), \("R.string.localizable.end()") - \(obj?.end_date ?? "")"
                    lbl_Km.text = "\(R.string.localizable.awayFromYou()) \(obj?.distance ?? "") \(R.string.localizable.km())"
                    self.cityiD = obj?.city_id ?? ""
                    self.placeId = obj?.placeid ?? ""
                    self.serviceiD = obj?.id ?? ""
                    self.vedioUrl = obj?.video_link_en ?? ""
                    
                    self.lbl_WorthVisit.text = "\(obj?.total_fav_place ?? "") \(R.string.localizable.worthAVisit())"
                    self.lbl_WorthNotVisit.text = "\(obj?.total_unfav_place ?? "") \(R.string.localizable.notWorthVisit())"
                    
                    if obj?.fav_status == "Like" {
                        self.btn_LikeOt.tintColor = #colorLiteral(red: 0.2039215686, green: 0.6588235294, blue: 0.3254901961, alpha: 1)
                    } else if obj?.fav_status == "Unlike" {
                        self.btn_DislikeOt.tintColor = .red
                    } else {
                        self.btn_LikeOt.tintColor = .darkGray
                        self.btn_DislikeOt.tintColor = .darkGray
                    }
                    
                    lbl_PhoneNum.text = viewModel.phoneNum
                    lbl_WebsiteLink.text = viewModel.websiteLink
                    
                    if viewModel.arrayWeekDays.count > 0 {
                        self.lbl_OpenCloseStatus.text = R.string.localizable.open()
                        self.lbl_OpenCloseStatus.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
                    } else {
                        self.lbl_OpenCloseStatus.text = R.string.localizable.closed()
                        self.lbl_OpenCloseStatus.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                    }
                    
                    // Reload collections
                    tag_Collection.reloadData()
                    timeSchedule_Collection.reloadData()
                    rating_TableVw.reloadData()
                    
                    // Fetch and update photos
                    DispatchQueue.main.async { [self] in
                        viewModel.fetchPlacesPhotos(vC: self, placeId: obj?.placeid ?? "")
                        self.viewModel.fetchedPhotosSuccessfull = { [self] in
                            self.arrayOfBothImages.append(contentsOf: viewModel.arrayPlaceImages.compactMap {$0.image})
                            self.arrayOfBothImages.append(contentsOf: viewModel.arrayGooglePhotos.compactMap {$0.p_photo})
                            self.page_Controller.numberOfPages = arrayOfBothImages.count
                            self.placeImg_Collection.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    
    private func updateFavoriteUI() {
            self.favImg.image = viewModel.arrayPlaceDetail?.currentUserFavorite == true ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        self.favImg.tintColor = viewModel.arrayPlaceDetail?.currentUserFavorite == true ? .red : .lightGray
    }
    
    @objc private func favoriteButtonTapped() {
            
        Api.shared.requestToAddToFavorite(self, placeId: self.viewModel.arrayPlaceDetail?.id ?? "") { [weak self] response in
                guard let self = self else { return }
                print(response)
                if response.status == "1" {
                    if response.result == "Removed From Favorites" {
                        viewModel.arrayPlaceDetail?.currentUserFavorite = false
                    }else {
                        viewModel.arrayPlaceDetail?.currentUserFavorite = true
                    }
                    updateFavoriteUI()
                } else {
                    self.alert(alertmessage: response.message ?? "Failed to update favorite")
                   
                }
            }
        }
    
    @IBAction func btn_Back(_ sender: UIButton) {
        if let currentUserFavorite = viewModel.arrayPlaceDetail?.currentUserFavorite,
           let placeId = viewModel.arrayPlaceDetail?.placeid {
            viewModel.sendDataBack?(currentUserFavorite, placeId)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btn_VideoLink(_ sender: UIButton) {
        if vedioUrl.isEmpty {
            self.alert(alertmessage: "No link Available")
        } else {
            Utility.openAnyUrl(Url: self.vedioUrl)
        }
    }
    
    @IBAction func btn_Visit(_ sender: UIButton) {
        viewModel.requestToFavUnfavPlace(vC: self, status: "Like")
        viewModel.fetchedDetailSuccessfull = { [weak self] in
            guard let self else { return }
            self.bindDataToVC()
        }
    }
    
    @IBAction func btn_NotVisit(_ sender: UIButton) {
        viewModel.requestToFavUnfavPlace(vC: self, status: "Unlike")
        viewModel.fetchedDetailSuccessfull = { [self] in
            self.bindDataToVC()
        }
    }
    
    @IBAction func btn_AddTripSchedule(_ sender: UIButton) {
        viewModel.navigateToPlaceTableViewController(from: self.navigationController, cityiD: cityiD)
    }
    
    @IBAction func btn_ServiceEvaluation(_ sender: UIButton) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RatingVC") as! RatingVC
        vC.viewModel.serviceId = self.serviceiD
        navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_OpenGoogleMap(_ sender: UIButton) {
        
    }
}

extension GooglePlaceDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.arrayRatingReview.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        
        let obj = self.viewModel.arrayRatingReview[indexPath.row]
        cell.lbl_Name.text = obj.user_name ?? ""
        cell.lbl_Date.text = obj.date_time ?? ""
        cell.ratingStar.rating = Double(obj.rating ?? "") ?? 0.0
        cell.ratingCount.text = obj.rating ?? ""
        cell.lbl_Message.text = obj.review ?? ""
        
        if Router.BASE_IMAGE_URL != obj.image {
            Utility.setImageWithSDWebImage(obj.image ?? "", cell.user_Img)
        } else {
            cell.user_Img.image = R.image.blank()
        }
        
        return cell
    }
}

extension GooglePlaceDetailVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == placeImg_Collection {
            self.arrayOfBothImages.count
        } else if collectionView == tag_Collection {
            viewModel.arrayPlaceTags.count
        } else {
            viewModel.arrayWeekDays.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == placeImg_Collection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ServiceDetailImageCell
            
            let obj = arrayOfBothImages[indexPath.row]
            
            Utility.setImageWithSDWebImage(obj, cell.place_Img)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
            if collectionView == tag_Collection {
                let obj = viewModel.arrayPlaceTags[indexPath.row]
                if L102Language.currentAppleLanguage() == "en" {
                    cell.lbl_TagName.text = obj.tag_name ?? ""
                } else {
                    cell.lbl_TagName.text = obj.tag_name_ar ?? ""
                }
                cell.lbl_TagName.backgroundColor = hexStringToUIColor(hex: obj.color_code ?? "")
            } else {
                let obj = viewModel.arrayWeekDays[indexPath.row]
                cell.lbl_TagName.text = obj
                cell.lbl_TagName.textColor = .black
                cell.lbl_TagName.font = UIFont(name: "Avenir", size: 12)
                cell.lbl_TagName.cornerRadius = 10
                cell.lbl_TagName.borderWidth = 0.5
                cell.lbl_TagName.borderColor = .separator
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == placeImg_Collection {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        } else if collectionView == tag_Collection {
            return CGSize(width: 127, height: collectionView.frame.height)
        } else {
            return CGSize(width: collectionView.frame.width / 2 - 6, height: 36)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == placeImg_Collection {
            return 0
        } else if collectionView == tag_Collection {
            return 10
        } else {
            return 6
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        page_Controller.currentPage = Int(pageIndex)
    }
}


