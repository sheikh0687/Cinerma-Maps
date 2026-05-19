//
//  DetailView.swift
//  Cinerama Maps
//
//  Created by Muhammad  on 22/08/24.
//

import SwiftUI
import Foundation
import MapKit
import Combine

struct Places: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct DetailView: View {
    
    var index = 0
    var viewModel: SubscriptionMapViewModel
    
    @ObservedObject var VM : GooglePlaceVM
    
    @State private var currentPage: Int = 0
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 10, on: .main, in: .common)
    @State private var cancellable: Cancellable?
    @State private var attributedText: NSAttributedString = NSAttributedString(string: "")
    @State var fav_status: String?
    @Environment(\.dismiss) private var dismiss
    @State private var rating: Int = 0
    @State var like = false
    @State var dislike = false
    @State private var firstimg = 0
    @State var isLoadingMore: Bool = false
    @State private var isDescriptionLoading: Bool = true
    
    let language = L102Language.currentAppleLanguage()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                if let detail = viewModel.openType == .direct
                    ? viewModel.arrayOfPlaceDetails[index]
                    : viewModel.newFilter[index] as? Place_details {
                    VStack {
                        
                        // MARK: - Hero Image Zone
                        ZStack(alignment: .top) {
                            
                            if let matchedImages = (viewModel.arrayImageDetail as? [Places_images])?
                                .filter({ $0.place_id == detail.id }), !matchedImages.isEmpty {
                                
                                // MARK: Loaded images TabView
                                TabView(selection: $currentPage) {
                                    ForEach(Array(matchedImages.enumerated()), id: \.element.id) { index, tag in
                                        GeometryReader { geometry in
                                            AsyncImage(url: URL(string: tag.image ?? "")) { phase in
                                                if let image = phase.image {
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                } else if phase.error != nil {
                                                    Image("BackPlaceholder")
                                                        .resizable()
                                                        .scaledToFill()
                                                }
                                            }
                                            .frame(width: geometry.size.width, height: 420)
                                            .clipped()
                                            .cornerRadius(26, corners: [.bottomLeft, .bottomRight])
                                            .shadow(radius: 5)
                                        }
                                        .frame(height: 420)
                                        .tag(index)
                                    }
                                }
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                                .onAppear { setupTimer() }
                                .onDisappear { cancellable?.cancel() }
                                .frame(height: 420)
                                // Page dots overlay
                                .overlay(
                                    VStack {
                                        Spacer()
                                        HStack(spacing: 8) {
                                            ForEach(0..<matchedImages.count, id: \.self) { index in
                                                Capsule()
                                                    .fill(currentPage == index ? Color.orange : Color.gray.opacity(0.5))
                                                    .frame(width: currentPage == index ? 30 : 8, height: 8)
                                                    .animation(.easeInOut, value: currentPage)
                                            }
                                        }
                                        .padding(.bottom, 30)
                                    }
                                )
                                // FIX 1: Back + fav buttons as overlay on loaded images
                                .overlay(
                                    HStack {
                                        Button { dismiss() } label: {
                                            Image(systemName: "chevron.backward")
                                                .padding()
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.4))
                                                .clipShape(Circle())
                                        }
                                        Spacer()
                                        let isfav = detail.currentUserFavorite
                                        Button {
                                            viewModel.Fav(id: detail.id, index: index) { isRemoving, _ in
                                                viewModel.arrayOfPlaceDetails[index].currentUserFavorite = !isRemoving
                                                if let mapIndex = viewModel.newFilter.firstIndex(where: { $0.id == detail.id }) {
                                                    viewModel.newFilter[mapIndex].currentUserFavorite = !isRemoving
                                                }
                                            }
                                        } label: {
                                            Image(isfav == true ? "ic_heart.fill " : "ic_heart")
                                                .padding()
                                                .foregroundColor(isfav == true ? .orange : .white)
                                                .background(Color.black.opacity(0.4))
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 50),
                                    alignment: .top
                                )
                                
                            } else {
                                
                                // MARK: Shimmer placeholder while images load
                                ZStack(alignment: .top) {
                                    RoundedRectangle(cornerRadius: 0)
                                        .fill(Color.gray.opacity(0.25))
                                        .frame(height: 420)
                                        .shimmer()
                                        .cornerRadius(26, corners: [.bottomLeft, .bottomRight])
                                    
                                    // FIX 1: Back + fav buttons visible during shimmer too
                                    HStack {
                                        Button { dismiss() } label: {
                                            Image(systemName: "chevron.backward")
                                                .padding()
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.4))
                                                .clipShape(Circle())
                                        }
                                        Spacer()
                                        Button {
                                            viewModel.Fav(id: detail.id, index: index) { isRemoving, _ in
                                                viewModel.arrayOfPlaceDetails[index].currentUserFavorite = !isRemoving
                                            }
                                        } label: {
                                            Image(detail.currentUserFavorite == true ? "ic_heart.fill " : "ic_heart")
                                                .padding()
                                                .foregroundColor(detail.currentUserFavorite == true ? .orange : .white)
                                                .background(Color.black.opacity(0.4))
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 50)
                                }
                            }
                            
                            // Place icon badge — always visible
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    ZStack {
                                        Circle().fill(Color.main)
                                        UIKitIconLoader(url: detail.icon ?? "")
                                            .scaledToFit()
                                            .padding(12)
                                    }
                                    .frame(width: 48, height: 48)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                                    .padding([.bottom, .trailing], 10)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 400)
                        
                        // MARK: - Content Below Image
                        VStack(alignment: .leading, spacing: 20) {
                            
                            VStack(alignment: .leading, spacing: 16) {
                                
                                // MARK: Place name
                                if isDescriptionLoading {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.gray.opacity(0.25))
                                        .frame(height: 22)
                                        .shimmer()
                                } else {
                                    Text(language == "ar" ? detail.place_name_ar! : detail.place_name!)
                                        .font(.custom("Avenir-Medium", size: 18))
                                        .bold()
                                }
                                
                                // MARK: FIX 3 — Like/dislike + rating shimmer
                                if isDescriptionLoading {
                                    HStack {
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.gray.opacity(0.25))
                                            .frame(width: 150, height: 36)
                                            .shimmer()
                                        Spacer()
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.gray.opacity(0.25))
                                            .frame(width: 80, height: 36)
                                            .shimmer()
                                    }
                                } else {
                                    HStack(alignment: .center) {
                                        HStack(spacing: 8) {
                                            Button {
                                                viewModel.likeButton(id: detail.id, index: index)
                                            } label: {
                                                Image(systemName: detail.fav_status == "Like" ? "hand.thumbsup.fill" : "hand.thumbsup")
                                                    .foregroundColor(detail.fav_status == "Like" ? Color.orange : .black)
                                            }
                                            Text(detail.total_fav_place ?? "200K")
                                                .font(.custom("Avenir-Medium", size: 14))
                                            Divider()
                                                .frame(height: 20)
                                                .padding(.horizontal, 4)
                                            Button {
                                                viewModel.unlikeButton(id: detail.id, index: index)
                                            } label: {
                                                Image(systemName: detail.fav_status == "UnLike" ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                                    .foregroundColor(detail.fav_status == "UnLike" ? Color.orange : .black)
                                            }
                                            Text(detail.total_unfav_place ?? "200K")
                                                .font(.custom("Avenir-Medium", size: 14))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.gray, lineWidth: 1))
                                        .clipShape(RoundedRectangle(cornerRadius: 25))
                                        
                                        Spacer()
                                        
                                        let rating = detail.rating ?? ""
                                        var Avgrating = (rating as NSString).doubleValue
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            HStack(spacing: 4) {
                                                ForEach(1...3, id: \.self) { index in
                                                    Image(systemName: "star.square.fill")
                                                        .resizable()
                                                        .frame(width: 20, height: 20)
                                                        .foregroundColor(Double(index) <= Avgrating ? .main : .gray)
                                                        .onTapGesture { Avgrating = Double(index) }
                                                }
                                            }
                                            Text(R.string.localizable.recommendation())
                                                .foregroundColor(.gray)
                                                .font(.custom("Avenir-Medium", size: 14))
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            // MARK: Description
                            VStack(alignment: .leading, spacing: 12) {
                                Text(R.string.localizable.description())
                                    .font(.custom("Avenir-Medium", size: 14))
                                    .foregroundColor(Color.gray)
                                
                                if isDescriptionLoading {
                                    VStack(spacing: 8) {
                                        ForEach(0..<5, id: \.self) { _ in
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.gray.opacity(0.25))
                                                .frame(height: 13)
                                                .shimmer()
                                        }
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.gray.opacity(0.25))
                                            .frame(width: 180, height: 13)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .shimmer()
                                    }
                                    .frame(height: 120)
                                } else {
//                                    ScrollView(.vertical, showsIndicators: true) {
//                                    }
//                                    .frame(height: 120)
                                    Text(attributedText.string)
                                        .font(.custom("Avenir-Medium", size: 14))
                                        .multilineTextAlignment(.leading)
//                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            // MARK: Tag pills
                            if isDescriptionLoading {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(0..<4, id: \.self) { _ in
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.gray.opacity(0.25))
                                                .frame(width: 70, height: 26)
                                                .shimmer()
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .padding(.vertical, 8)
                            } else if let tagdetail = viewModel.arrayOfPlaceDetails[index].tag_details as? [Tag_details] {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(tagdetail, id: \.id) { tag in
                                            Text(language == "ar" ? tag.tag_name_ar ?? "" : tag.tag_name ?? "")
                                                .foregroundColor(Color.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 4)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(colorFromHex(tag.color_code ?? ""))
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(Color.gray, lineWidth: 1)
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .fixedSize(horizontal: true, vertical: false)
                                                .font(.custom("Avenir-Medium", size: 12))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .padding(.vertical, 8)
                            }
                            
                            // MARK: Info rows
                            if isDescriptionLoading {
                                VStack(spacing: 0) {
                                    ForEach(0..<4, id: \.self) { _ in
                                        Divider()
                                        HStack(spacing: 10) {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.gray.opacity(0.25))
                                                .frame(width: 30, height: 14)
                                                .shimmer()
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.gray.opacity(0.25))
                                                .frame(width: 90, height: 14)
                                                .shimmer()
                                            Spacer()
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.gray.opacity(0.25))
                                                .frame(width: 70, height: 14)
                                                .shimmer()
                                        }
                                        .padding(.vertical, 10)
                                    }
                                    Divider()
                                }
                                .padding(.horizontal, 16)
                            } else {
                                VStack(alignment: .leading, spacing: 12) {
                                    Divider()
                                    if detail.suggested_time == "∞" || detail.suggested_time == "" {
                                        InfoRow(icon: "ic_clock", label: R.string.localizable.suggestedTime(), value: "∞")
                                    } else {
                                        InfoRow(
                                            icon: "ic_clock",
                                            label: R.string.localizable.suggestedTime(),
                                            value: L102Language.currentAppleLanguage() == "en"
                                                ? "\(detail.suggested_time ?? "")h"
                                                : "\(detail.suggested_time ?? "")س"
                                        )
                                    }
                                    
                                    if L102Language.currentAppleLanguage() == "en" {
                                        if detail.video_link_en != "" {
                                            Divider()
                                            InfoRow(
                                                icon: "ic_video",
                                                label: R.string.localizable.video(),
                                                value: R.string.localizable.watchVideo(),
                                                videoURL: detail.video_link_en ?? "",
                                                link: true
                                            )
                                        }
                                    } else {
                                        if detail.video_link_ar != "" {
                                            Divider()
                                            InfoRow(
                                                icon: "ic_video",
                                                label: R.string.localizable.video(),
                                                value: R.string.localizable.watchVideo(),
                                                videoURL: detail.video_link_ar,
                                                link: true
                                            )
                                        }
                                    }
                                    
                                    Divider()
                                    InfoRow(
                                        icon: "ic_discount",
                                        label: R.string.localizable.discount(),
                                        extraValue: "\(detail.promo_code_percentage ?? "AKL/20%")",
                                        percentLabel: "\(detail.promo_code_and_discount ?? "20%")"
                                    )
                                    
                                    Divider()
                                    InfoRow(
                                        icon: "ic_notification",
                                        label: R.string.localizable.advice(),
                                        value: L102Language.currentAppleLanguage() == "en"
                                            ? detail.advice ?? ""
                                            : detail.advice_arabic ?? "",
                                        extraValue: L102Language.currentAppleLanguage() == "en"
                                            ? "Read More"
                                            : "اقرأ المزيد",
                                        isAdvice: true
                                    )
                                    Divider()
                                }
                                .padding(.horizontal, 16)
                            }
                            
                            // MARK: FIX 2 — Location with shimmer
                            VStack(alignment: .leading, spacing: 16) {
                                Text(R.string.localizable.location())
                                    .font(.custom("Avenir-Heavy", size: 16))
                                    .bold()
                                
                                if isDescriptionLoading {
                                    HStack(spacing: 12) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.25))
                                            .frame(width: 110, height: 92)
                                            .shimmer()
                                        VStack(alignment: .leading, spacing: 10) {
                                            ForEach(0..<3, id: \.self) { _ in
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.gray.opacity(0.25))
                                                    .frame(height: 13)
                                                    .shimmer()
                                            }
                                        }
                                    }
                                    .padding(4)
                                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                                } else {
                                    let mylatitude = detail.lat ?? ""
                                    let mylongitude = detail.lon ?? ""
                                    let lat = (mylatitude as NSString).doubleValue
                                    let lon = (mylongitude as NSString).doubleValue
                                    
                                    HStack(spacing: 12) {
                                        CustomMapView(
                                            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                            name: detail.place_name
                                        )
                                        .frame(width: 110, height: 92)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack(spacing: 6) {
                                                Image("ic_routing")
                                                Text("\(detail.distance ?? "200 M") \(R.string.localizable.km())")
                                                    .font(.system(size: 14))
                                                    .lineLimit(1)
                                            }
                                            HStack(spacing: 6) {
                                                Image("ic_location")
                                                Text(detail.address ?? "Place Address")
                                                    .font(.custom("Avenir-Medium", size: 12))
                                                    .lineLimit(1)
                                            }
                                            HStack {
                                                Spacer()
                                                Image("ic_map_i")
                                                    .resizable()
                                                    .frame(width: 24, height: 24)
                                            }
                                        }
                                        .padding(6)
                                    }
                                    .padding(4)
                                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.4)))
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        openMap(strWebUrl: detail.google_map_link ?? "")
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                        .padding(.top, 16)
                    }
                }
            }
            .onAppear {
                Task {
                    let currentDetail = viewModel.openType == .direct
                        ? (viewModel.arrayOfPlaceDetails.indices.contains(index) ? viewModel.arrayOfPlaceDetails[index] : nil)
                        : (viewModel.newFilter.indices.contains(index) ? viewModel.newFilter[index] : nil)
                    
                    guard let detail = currentDetail else {
                        await MainActor.run {
                            isDescriptionLoading = false
                        }
                        return
                    }
                    
                    let descriptionText = language == "ar"
                        ? detail.description_ar ?? ""
                        : detail.description ?? ""
                    
                    // ⭐️ Convert HTML once
                    let converted = descriptionText.htmlAttributedString3
                    
                    await MainActor.run {
                        attributedText = converted ?? NSAttributedString(string: "")
                        isDescriptionLoading = false
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    private func setupTimer() {
        cancellable = timer.autoconnect().sink { _ in
            if let matchedImages = (viewModel.arrayImageDetail as? [Places_images])?
                .filter({ $0.place_id == viewModel.arrayOfPlaceDetails[index].id }),
               matchedImages.count > 1 {
                withAnimation {
                    currentPage = (currentPage + 1) % matchedImages.count
                }
            }
        }
    }
}

// MARK: - CustomMapView
struct CustomMapView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    let name: String?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.mapType = .satellite
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        )
        mapView.setRegion(region, animated: false)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = name
        mapView.addAnnotation(annotation)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject {
        var parent: CustomMapView
        init(_ parent: CustomMapView) { self.parent = parent }
    }
}

// MARK: - Helpers
func openMap(strWebUrl: String) {
    if let webUrl = URL(string: strWebUrl) {
        UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
    }
}

func colorFromHex(_ hex: String) -> Color {
    var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if cString.hasPrefix("#") { cString.remove(at: cString.startIndex) }
    guard cString.count == 6, let rgbValue = UInt32(cString, radix: 16) else { return .gray }
    let red   = Double((rgbValue & 0xFF0000) >> 16) / 255.0
    let green = Double((rgbValue & 0x00FF00) >> 8)  / 255.0
    let blue  = Double( rgbValue & 0x0000FF)         / 255.0
    return Color(red: red, green: green, blue: blue)
}

extension UIApplication {
    func rootVC() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    }
}
