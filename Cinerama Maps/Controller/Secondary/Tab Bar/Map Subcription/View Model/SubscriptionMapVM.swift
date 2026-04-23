//
//  SubscriptionMapViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 04/11/24.
//

import Foundation
import SwiftUI
import Combine
import CoreData

enum OpenType {
    case direct, filter
}

class SubscriptionMapViewModel: ObservableObject {
    
    var arrayOfPlaceDetails: [Place_details] = []
    @Published var arrayOfPlaceDetails1: [Place_details] = []
    @Published var newFilter: [Place_details] = []
    @Published var arrayImageDetail: [Places_images] = []
    @Published var arrayTagDetails: [Tag_details] = []
    @Published var selectedTag: String? = nil
    @Published var searchText: String = ""
    @Published var showingFavorites: Bool = false
    
    var openType = OpenType.direct
    var message: String? = nil
    var SubVc: SubscriptionMapVC?
    var fetchedSuccessfully:(() -> Void)?
    var fetchedFromDbSuccessfully:(() -> Void)?
    var noDataInDB: (() -> Void)?
    var cityId:String = ""
    var cityName:String = ""
    let language = k.userDefault.value(forKey: k.session.language) as? String
    private var cancellables = Set<AnyCancellable>()
    var isFiltering = false
    var itemsToShow: Int = 10
    let itemsPerPage: Int = 10
    var isLoadingMore: Bool = false
    
    init() {
        Publishers.CombineLatest4($arrayOfPlaceDetails1, $selectedTag, $searchText, $showingFavorites)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main) // Optional: avoids rapid filtering
            .flatMap { places, tag, searchText,showingFavorites -> AnyPublisher<[Place_details], Never> in
                return Future<[Place_details], Never> { promise in
                    DispatchQueue.global(qos: .userInitiated).async {
                        var filtered = places
                        
                        if showingFavorites {
                            filtered = filtered.filter { $0.currentUserFavorite == true }
                        }
                        if let tag = tag, !tag.isEmpty {
                            filtered = filtered.filter { $0.tag?.contains(tag) ?? false }
                        }
                        
                        if !searchText.isEmpty {
                            filtered = filtered.filter { place in
                                    let name = place.place_name ?? ""
                                    let nameAr = place.place_name_ar ?? ""
                                    
                                    return name.lowercased().hasPrefix(searchText.lowercased()) ||
                                           nameAr.lowercased().hasPrefix(searchText.lowercased())
                                }
                            
                            filtered = filtered.filter {
                                $0.place_name?.localizedCaseInsensitiveContains(searchText) ?? false ||
                                $0.place_name_ar?.localizedCaseInsensitiveContains(searchText) ?? false
                            }
                        }
                        
                        promise(.success(filtered))
                    }
                }
                .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.newFilter, on: self)
            .store(in: &cancellables)
    }
    
    func toggleFavoriteLocally(placeId: String, isRemoving: Bool) {
        if let index = arrayOfPlaceDetails1.firstIndex(where: { $0.id == placeId }) {
            arrayOfPlaceDetails1[index].currentUserFavorite = !isRemoving
        }
        if let index = newFilter.firstIndex(where: { $0.id == placeId }) {
            newFilter[index].currentUserFavorite = !isRemoving
        }
        if showingFavorites && isRemoving {
            newFilter.removeAll { $0.id == placeId }
        }
    }

    func getAllFavoritePlaces() {
        let favorites = arrayOfPlaceDetails1.filter { $0.currentUserFavorite == true }

        newFilter = favorites
    }

    func deleteImagesDataBy(context: NSManagedObjectContext, ids: [String]) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = PlaceImage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
            print("Deleted images with ids: \(ids)")
        } catch {
            print("Failed to batch delete images: \(error)")
        }
    }
    
    func deleteTagsDetailDataBy(context: NSManagedObjectContext,cityId: String){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TagDetail.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "city_id == %@", cityId)

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to batch delete: \(error)")
        }
    }
    
    func deleteTagsDataBy(context: NSManagedObjectContext,cityId: String){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TagDetail.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "city_id == %@", cityId)

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to batch delete: \(error)")
        }
    }
        
    func deletePlaceDataBy(context: NSManagedObjectContext,cityId: String){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = PlaceDetail.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "city_id == %@", cityId)

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to batch delete: \(error)")
        }
    }
    
    func convertHTMLToAttributedString(html: String) -> NSAttributedString {
        guard let data = html.data(using: .utf8) else {
            return NSAttributedString(string: html)
        }
        return (try? NSAttributedString (
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
      ) ?? NSAttributedString(string: html)
    }
    
    func getImageFor(placeID: String) -> Places_images? {
        arrayImageDetail.first(where: { $0.place_id == placeID })
    }
    
    func Fav(id: String?, index: Int, completion: ((Bool, String) -> Void)?) {
        guard let id = id else { return }

        let vc = UIApplication.shared.rootVC()
        Api.shared.requestToAddToFavorite(vc, placeId: id, progress: true) { [weak self] response in
            guard let self else { return }

            DispatchQueue.main.async {
                guard response.status == "1" else {
                    completion?(false, "Failed to update favorite")
                    return
                }

                let isRemoving = (response.result == "Removed From Favorites")

                Task {
                    await MainActor.run {
                        if let index = self.arrayOfPlaceDetails.firstIndex(where: { $0.id == id }) {
                            self.arrayOfPlaceDetails[index].currentUserFavorite = !isRemoving
                        }
                    }

                    // ✅ Send back message (not shown here)
                    completion?(isRemoving, isRemoving ? "Removed from favorites" : "Added to favorites")
                }
            }
        }
    }
    
    func likeButton(id: String?, index: Int, completion: ((Bool) -> Void)? = nil) {
        guard let id = id else { return }
        guard arrayOfPlaceDetails.indices.contains(index),
              arrayOfPlaceDetails[index].fav_status != "Like" else {
            completion?(false)
            return
        }
        
        requestToFavUnfavPlace(placeId: id, status: "Like")
        fetchedSuccessfully = { [weak self] in
            guard let self else { return }
            guard self.arrayOfPlaceDetails.indices.contains(index) else { return }
            if let index = self.arrayOfPlaceDetails.firstIndex(where: { $0.id == id }) {
                DispatchQueue.main.async {
                    let place = self.arrayOfPlaceDetails[index]
                    
                    // Only decrement unfav if it was previously unliked
                    if place.fav_status == "UnLike",
                       let unfavCount = Int(place.total_unfav_place ?? "0"), unfavCount > 0 {
                        self.arrayOfPlaceDetails[index].total_unfav_place = String(unfavCount - 1)
                    }
                    
                    // Increment fav count only on actual state change
                    if let favCount = Int(place.total_fav_place ?? "0") {
                        self.arrayOfPlaceDetails[index].total_fav_place = String(favCount + 1)
                    }
                    
                    self.arrayOfPlaceDetails[index].fav_status = "Like"
                    completion?(true)
                }
            }
        }
    }
    
    func unlikeButton(id: String?, index: Int, completion: ((Bool) -> Void)? = nil) {
        guard let id = id else { return }
        guard arrayOfPlaceDetails.indices.contains(index),
              arrayOfPlaceDetails[index].fav_status != "UnLike" else {
            completion?(false)
            return
        }
        
        requestToFavUnfavPlace(placeId: id, status: "UnLike")
        fetchedSuccessfully = { [weak self] in
            guard let self else { return }
            guard self.arrayOfPlaceDetails.indices.contains(index) else { return }
            if let index = self.arrayOfPlaceDetails.firstIndex(where: { $0.id == id }) {
                DispatchQueue.main.async {
                    let place = self.arrayOfPlaceDetails[index]
                    
                    // Only decrement fav if it was previously liked
                    if place.fav_status == "Like",
                       let favCount = Int(place.total_fav_place ?? "0"), favCount > 0 {
                        self.arrayOfPlaceDetails[index].total_fav_place = String(favCount - 1)
                    }
                    
                    // Increment unfav count only on actual state change
                    if let unfavCount = Int(place.total_unfav_place ?? "0") {
                        self.arrayOfPlaceDetails[index].total_unfav_place = String(unfavCount + 1)
                    }
                    
                    self.arrayOfPlaceDetails[index].fav_status = "UnLike"
                    completion?(true)
                }
            }
        }
    }
    
    func updateSearchText(_ text: String) {
        searchText = text
    }
    
    func didSelectTag(_ tagName: String?) {
        if selectedTag == tagName {
            selectedTag = nil
        } else {
            selectedTag = tagName
        }
    }
    
    func loadMoreIfNeeded(currentItem: Place_details?) {
        guard let currentItem = currentItem else { return }
        
        let currentItems = newFilter.prefix(itemsToShow)
        if currentItems.last?.id == currentItem.id && itemsToShow < newFilter.count {
            isLoadingMore = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.itemsToShow += self.itemsPerPage
                self.isLoadingMore = false
            }
        }
    }
    
    func fetchDataFromDB(cityId:String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let context = PersistenceController.shared.container.viewContext
            
            let fetchRequestForImages: NSFetchRequest<PlaceImage> = PlaceImage.fetchRequest()

            let placeImagesFromDB = try? context.fetch(fetchRequestForImages)
            var placeImage : [Places_images] = []

            for placeImageFromDB in placeImagesFromDB ?? [] {
                var image = Places_images()
                image.id = placeImageFromDB.id
                image.date_time = placeImageFromDB.date_time
                image.place_id = placeImageFromDB.place_id
                image.image = placeImageFromDB.image
                placeImage.append(image)
            }
            
                DispatchQueue.main.sync {
                    self.arrayImageDetail = placeImage

                }

            let fetchRequestForTags: NSFetchRequest<TagDetail> = TagDetail.fetchRequest()
            fetchRequestForTags.predicate = NSPredicate(format: "city_id == %@", cityId)
            let tagsFromDB = try? context.fetch(fetchRequestForTags)
            var tags: [Tag_details] = []
            
            
            for tagFromDB in tagsFromDB ?? [] {
                var tag = Tag_details()
                tag.id = tagFromDB.id
                tag.country_id = tagFromDB.country_id
                tag.city_id = tagFromDB.city_id
                tag.tag_name = tagFromDB.tag_name
                tag.tag_name_ar = tagFromDB.tag_name_ar
                tag.color_code = tagFromDB.color_code
                tag.date_time = tagFromDB.date_time
                tag.icon = tagFromDB.icon
                tag.total_tag_place_count = tagFromDB.total_tag_place_count
                tags.append(tag)
            }
            
            DispatchQueue.main.sync { [weak self, tags] in
                self?.arrayTagDetails = tags
            }
            
            let fetchRequest: NSFetchRequest<PlaceDetail> = PlaceDetail.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "city_id == %@", cityId)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            let placesDetailFromDB = try? context.fetch(fetchRequest)
            if placesDetailFromDB?.isEmpty ?? true {
                DispatchQueue.main.async { [weak self] in
                    self?.noDataInDB?()
                }
                return
            }
            if let dbPlaces = placesDetailFromDB, !dbPlaces.isEmpty {
                    var placesDetail: [Place_details] = []
                    
                    for placeFromDB in placesDetailFromDB ?? [] {
                        var place = Place_details()
                        place.user_id = placeFromDB.user_id
                        place.placeid = placeFromDB.placeid
                        place.country_id = placeFromDB.country_id
                        place.city_id = placeFromDB.city_id
                        place.tag_id = placeFromDB.tag_id
                        place.place_name = placeFromDB.place_name
                        place.place_name_ar = placeFromDB.place_name_ar
                        place.description = placeFromDB.description
                        place.description_ar = placeFromDB.description_ar
                        place.distance = placeFromDB.distance
                        place.tag = placeFromDB.tag
                        place.tag_ar = placeFromDB.tag_ar
                        place.address = placeFromDB.address
                        place.lat = placeFromDB.lat
                        place.lon = placeFromDB.lon
                        place.icon = placeFromDB.icon
                        place.icon_background_color = placeFromDB.icon_background_color
                        place.show_only_icon = placeFromDB.show_only_icon
                        place.promo_code_and_discount = placeFromDB.promo_code_and_discount
                        place.end_date = placeFromDB.end_date
                        place.mobile = placeFromDB.mobile
                        place.email = placeFromDB.email
                        place.site_url = placeFromDB.site_url
                        place.video_link_en = placeFromDB.video_link_en
                        place.video_link_ar = placeFromDB.video_link_ar
                        place.google_map_link = placeFromDB.google_map_link
                        place.date_time = placeFromDB.date_time
                        place.fav_status = placeFromDB.fav_status
                        place.total_fav_place = placeFromDB.total_fav_place
                        place.total_unfav_place = placeFromDB.total_unfav_place
                        place.favoriteCount = Int(placeFromDB.favoriteCount)
                        place.currentUserFavorite = placeFromDB.currentUserFavorite
                        place.country_name = placeFromDB.country_name
                        place.country_name_ar = placeFromDB.country_name_ar
                        place.city_name = placeFromDB.city_name
                        place.city_name_ar = placeFromDB.city_name_ar
                        place.avg_rating = placeFromDB.avg_rating
                        place.plan_purchase_status = placeFromDB.plan_purchase_status
                        var tagsDetail:[Tag_details] = []
                        if let tagsDetailFromDB = placeFromDB.tags_detail as? Set<TagDetail>{
                            for tagDetailFromDB in tagsDetailFromDB {
                                var tagDetail = Tag_details()
                                tagDetail.id = tagDetailFromDB.id
                                tagDetail.tag_name = tagDetailFromDB.tag_name
                                tagDetail.tag_name_ar = tagDetailFromDB.tag_name_ar
                                tagDetail.city_id = tagDetailFromDB.city_id
                                tagDetail.country_id = tagDetailFromDB.country_id
                                tagDetail.date_time = tagDetailFromDB.date_time
                                tagDetail.icon = tagDetailFromDB.icon
                                tagDetail.total_tag_place_count = tagDetailFromDB.total_tag_place_count
                                tagDetail.color_code = tagDetailFromDB.color_code
                                tagsDetail.append(tagDetail)
                            }
                        }
                        place.tag_details = tagsDetail
                        placesDetail.append(place)
                        
                    }
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return}
                        //                    self.arrayImageDetail = placeImage
                        self.arrayOfPlaceDetails = placesDetail
                        self.arrayOfPlaceDetails1 = placesDetail
                        self.fetchedFromDbSuccessfully?()
                    }
                
            }
        }
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.requestCountryMapDetails(vC: UIApplication.shared.topmostViewController() ?? UIViewController())
        }
    }
    
    func requestCountryMapDetails(vC: UIViewController)
    {
        let user_id = UserDefaults.standard.value(forKey: "user_id")
        var param: [String : AnyObject] = [:]
        param["city_id"] = cityId as AnyObject
        param["user_id"] = user_id as AnyObject?
        
        print(param)
        
        Api.shared.requestCityPlaceDt(vC, param, progress: false) { responseData in
            print(responseData)
            DispatchQueue.global(qos: .utility).async {
                self.cityName = L102Language.currentAppleLanguage() == "en" ? responseData.name ?? "" : responseData.name_ar ?? ""
                
                self.saveAllCoreData (
                    images: responseData.places_images,
                    tags: responseData.tags,
                    places: responseData.place_details
                ) {
                    self.arrayImageDetail = responseData.places_images ?? []
                    self.arrayTagDetails = responseData.tags ?? []
                    self.arrayOfPlaceDetails = responseData.place_details ?? []
                    self.arrayOfPlaceDetails1 = responseData.place_details ?? []
                    
                    self.fetchedFromDbSuccessfully?()
                }
            }
        }
    }
    
    func requestToFavUnfavPlace(placeId:String, status: String)
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        paramDict["place_id"] = placeId as AnyObject
        paramDict["status"] = status as AnyObject
        
        print(paramDict)
        
        Api.shared.requestToSelectFavUnFavPlace(nil, paramDict) { [self] responseData in
            if responseData.status == "1" {
                self.fetchedSuccessfully?()
                message = responseData.message
            } else {
                print("Api message: \(responseData.message ?? "")")
                message = responseData.message
            }
            
        }
    }
    
    func navigateToGooglePlaceDetailViewController(from navigationController: UINavigationController,cityAddress: String, cityPlaceId: String, cityAddressLat: String, cityAddressLon: String, isFav: Bool) {
        let VC = GooglePlaceVM()
        VC.place_Id = cityPlaceId
        VC.val_Address = cityAddress
        VC.lat = cityAddressLat
        VC.lon = cityAddressLon
        VC.isFav = isFav
        openType = .direct
        VC.sendDataBack = {[weak self] isfav,placeId in
            guard let self else { return }
            print(isfav)
            print(placeId)
            if let index = self.arrayOfPlaceDetails.firstIndex(where: { $0.placeid == placeId }) {
                self.arrayOfPlaceDetails[index].currentUserFavorite = isfav
            }}
        guard let index = self.arrayOfPlaceDetails.firstIndex(where: { $0.id == cityPlaceId }) else { return  }
        let detailView = DetailView(index: index, viewModel: self,VM: VC)
            .environment(\.layoutDirection, language == "ar" ? .rightToLeft : .leftToRight)
        let hostingController = UIHostingController(rootView: detailView)
        navigationController.pushViewController(hostingController, animated: true)
    }
}

extension SubscriptionMapViewModel {
    
    func saveAllCoreData (
        images: [Places_images]?,
        tags: [Tag_details]?,
        places: [Place_details]?,
        completion: (() -> Void)? = nil
    ) {
        let container = PersistenceController.shared.container
        container.performBackgroundTask { context in
            
            // 1. Delete old place images by IDs
            if let images = images, !images.isEmpty {
                let imageIds = images.compactMap { $0.id }
                self.deleteImagesDataBy(context: context, ids: imageIds)
            }
            
            // 2. Delete old tags by cityId (assuming cityId is available)
            if let tags = tags, !tags.isEmpty {
                self.deleteTagsDataBy(context: context, cityId: self.cityId)
            }
            
            // 3. Delete old places and related tag details
            if let places = places, !places.isEmpty {
                self.deletePlaceDataBy(context: context, cityId: self.cityId)
                self.deleteTagsDetailDataBy(context: context, cityId: self.cityId)
            }
            
            // 4. Save place images
            if let images = images {
                for image in images {
                    let placesImage = PlaceImage(context: context)
                    placesImage.id = image.id
                    placesImage.date_time = image.date_time
                    placesImage.image = image.image
                    placesImage.place_id = image.place_id
                }
            }
            
            // 5. Save tags
            if let tags = tags {
                for tag in tags {
                    let fetchRequest: NSFetchRequest<TagDetail> = TagDetail.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", tag.id ?? "")
                    fetchRequest.fetchLimit = 1
                    
                    let dbTag: TagDetail
                    if let existingTag = try? context.fetch(fetchRequest).first {
                        dbTag = existingTag
                    } else {
                        dbTag = TagDetail(context: context)
                    }
                    
                    dbTag.id = tag.id
                    dbTag.tag_name = tag.tag_name
                    dbTag.tag_name_ar = tag.tag_name_ar
                    dbTag.color_code = tag.color_code
                    dbTag.date_time = tag.date_time
                    dbTag.icon = tag.icon
                    dbTag.city_id = tag.city_id
                    dbTag.country_id = tag.country_id
                    dbTag.total_tag_place_count = tag.total_tag_place_count
                }
            }
            
            // 6. Save places and their tags
            if let places = places {
                for place in places {
                    let fetchRequest: NSFetchRequest<PlaceDetail> = PlaceDetail.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", place.id ?? "")
                    fetchRequest.fetchLimit = 1
                    
                    let detail: PlaceDetail
                    if let existingPlace = try? context.fetch(fetchRequest).first {
                        detail = existingPlace
                    } else {
                        detail = PlaceDetail(context: context)
                    }
                    
                    detail.id = place.id
                    detail.user_id = place.user_id
                    detail.placeid = place.placeid
                    detail.country_id = place.country_id
                    detail.city_id = place.city_id
                    detail.tag_id = place.tag_id
                    detail.place_name = place.place_name
                    detail.place_name_ar = place.place_name_ar
                    detail.descriptio = place.description
                    detail.description_ar = place.description_ar
                    detail.distance = place.distance
                    detail.tag = place.tag
                    detail.tag_ar = place.tag_ar
                    detail.address = place.address
                    detail.lat = place.lat
                    detail.lon = place.lon
                    detail.icon = place.icon
                    detail.icon_background_color = place.icon_background_color
                    detail.show_only_icon = place.show_only_icon
                    detail.promo_code_and_discount = place.promo_code_and_discount
                    detail.end_date = place.end_date
                    detail.mobile = place.mobile
                    detail.email = place.email
                    detail.site_url = place.site_url
                    detail.video_link_en = place.video_link_en
                    detail.video_link_ar = place.video_link_ar
                    detail.google_map_link = place.google_map_link
                    detail.date_time = place.date_time
                    detail.fav_status = place.fav_status
                    detail.total_fav_place = place.total_fav_place
                    detail.total_unfav_place = place.total_unfav_place
                    detail.favoriteCount = Int64(place.favoriteCount ?? 0)
                    detail.currentUserFavorite = place.currentUserFavorite ?? false
                    detail.country_name = place.country_name
                    detail.country_name_ar = place.country_name_ar
                    detail.city_name = place.city_name
                    detail.city_name_ar = place.city_name_ar
                    detail.avg_rating = place.avg_rating
                    detail.plan_purchase_status = place.plan_purchase_status
                    if let tags = place.tag_details {
                        for tag in tags {
                            let tagFetch: NSFetchRequest<TagDetail> = TagDetail.fetchRequest()
                            tagFetch.predicate = NSPredicate(format: "id == %@", tag.id ?? "")
                            tagFetch.fetchLimit = 1
                            
        //                    let tagEntity = TagDetail(context: context)
        //                    if let existingTag = try? context.fetch(tagFetch).first {
        //                        tagEntity = existingTag
        //                    } else {
                            let tagEntity = TagDetail(context: context)
                            tagEntity.id = tag.id
        //                    }
                            tagEntity.tag_name = tag.tag_name
                            tagEntity.tag_name_ar = tag.tag_name_ar
                            tagEntity.city_id = tag.city_id
                            tagEntity.country_id = tag.country_id
                            tagEntity.date_time = tag.date_time
                            tagEntity.icon = tag.icon
                            tagEntity.total_tag_place_count = tag.total_tag_place_count
                            tagEntity.color_code = tag.color_code
                            tagEntity.place = detail
        //                    if let imageUrlString = tag.icon,
        //                       let url = URL(string: imageUrlString) {
        //
        //                        DispatchQueue.global(qos: .background).async {
        //                            if let imageData = try? Data(contentsOf: url) {
        //                                let base64String = imageData.base64EncodedString()
        //                                tagEntity.icon = base64String
        //                                try? context.save()
        //                            } else {
        //                                DispatchQueue.main.async {
        //                                    tagEntity.icon = imageUrlString
        //                                    try? context.save()
        //                                }
        //                            }}
        //                        }
        //
                        }
                    }
//                    if let placeTags = place.tag_details {
//                        for tag in placeTags {
//                            let tagFetch: NSFetchRequest<TagDetail> = TagDetail.fetchRequest()
//                            tagFetch.predicate = NSPredicate(format: "id == %@", tag.id ?? "")
//                            tagFetch.fetchLimit = 1
//                            
//                            let tagEntity: TagDetail
//                            if let existingTag = try? context.fetch(tagFetch).first {
//                                tagEntity = existingTag
//                            } else {
//                                tagEntity = TagDetail(context: context)
//                            }
//                            
//                            tagEntity.id = tag.id
//                            tagEntity.tag_name = tag.tag_name
//                            tagEntity.tag_name_ar = tag.tag_name_ar
//                            tagEntity.city_id = tag.city_id
//                            tagEntity.country_id = tag.country_id
//                            tagEntity.date_time = tag.date_time
//                            tagEntity.icon = tag.icon
//                            tagEntity.total_tag_place_count = tag.total_tag_place_count
//                            tagEntity.color_code = tag.color_code
//                            tagEntity.place = detail
//                        }
//                    }
                }
            }
            
            // 7. Save context
            do {
                try context.save()
                print("Saved all Core Data entities successfully")
                DispatchQueue.main.async {
                    completion?()
                }
            } catch {
                print("Failed to save all data: \(error)")
            }
        }
    }

}
