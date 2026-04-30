//
//  SearchMapView.swift
//  Cinerama Maps
//
//  Created by TeamX on 31/05/2025.
//

import SwiftUI

struct SearchMapView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SubscriptionMapViewModel
    let language = k.userDefault.value(forKey: k.session.language) as? String

    @State private var like = false
    @State private var dislike = false
    @State var selectedfilter: String = "Popular"
    var filters = ["Popular", R.string.localizable.name(), "Oldest", "Distance"]
    @State var Searching = false
    @State var showSuggestions = false
    @State var text = ""
    @State var Selected = 1
    @State private var selectedTag: String? = nil
    @State private var suggestions: [String] = []
    @State private var selectedIndex: Int? = nil
    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        NavigationView {
            VStack {

                // MARK: - Search Bar
                HStack(alignment: .top) {
                    Button {
                        if !text.isEmpty {
                            viewModel.updateSearchText("")
                            text = ""
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "chevron.backward")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.gray.opacity(0.4))
                            .clipShape(Circle())
                    }

                    VStack {
                        HStack {
                            TextField(R.string.localizable.searchHere(), text: $text, onEditingChanged: { editing in
                                showSuggestions = editing
                                updateSuggestions()
                            })
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color(.systemGray6))
                            .onChange(of: text) { _, newValue in
                                updateSuggestions()
                                viewModel.updateSearchText(newValue)
                            }

                            Spacer()

                            Button {
                                viewModel.updateSearchText(text)
                            } label: {
                                Image("search-normal")
                                    .padding(8)
                                    .foregroundColor(.white)
                                    .background(Color.orange)
                                    .clipShape(Circle())
                            }
                        }

                        if showSuggestions {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(suggestions, id: \.self) { suggestion in
                                        Button(action: {
                                            text = suggestion
                                            viewModel.updateSearchText(suggestion)
                                            showSuggestions = false
                                        }) {
                                            Text(suggestion)
                                                .padding(10)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
                            }
                            .frame(height: suggestions.count > 3 ? 130.0 : CGFloat(suggestions.count) * 50.0)
                        }
                    }
                    .padding(4)
                    .background(Color(.systemGray6))
                    .frame(maxWidth: .infinity)
                    .cornerRadius(25)
                }
                .padding(.horizontal)
                .padding(.top, 50)
                .padding(.bottom, 20)

                // MARK: - Tag Filter Pills
                if viewModel.isLoading {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(0..<5, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.gray.opacity(0.25))
                                    .frame(width: 70, height: 28)
                                    .shimmer()
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 8)

                } else if let data = viewModel.arrayTagDetails as? [Tag_details] {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {

                            Button(action: {
                                viewModel.showingFavorites = false
                                viewModel.didSelectTag(nil)
                            }, label: {
                                Text(R.string.localizable.all())
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 4)
                                    .background(RoundedRectangle(cornerRadius: 15).fill(.main))
                                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 1))
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .fixedSize(horizontal: true, vertical: false)
                                    .font(.custom("Avenir-Medium", size: 12))
                            })

                            Button(action: {
                                viewModel.didSelectTag(nil)
                                viewModel.showingFavorites = true
                            }, label: {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                    Text(R.string.localizable.favorites())
                                        .foregroundColor(Color.white)
                                        .padding(.vertical, 4)
                                }
                                .padding(.horizontal, 10)
                                .background(RoundedRectangle(cornerRadius: 15).fill(.main))
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 1))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .fixedSize(horizontal: true, vertical: false)
                                .font(.custom("Avenir-Medium", size: 12))
                            })

                            ForEach(data, id: \.id) { tag in
                                Button {
                                    viewModel.showingFavorites = false
                                    viewModel.didSelectTag(tag.tag_name)
                                } label: {
                                    Text(language == "ar" ? tag.tag_name_ar ?? "" : tag.tag_name ?? "")
                                        .foregroundColor(Color.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 4)
                                        .background(RoundedRectangle(cornerRadius: 15).fill(colorFromHex(tag.color_code ?? "")))
                                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 1))
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .font(.custom("Avenir-Medium", size: 12))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 8)
                }

                // MARK: - Sort By
                HStack {
                    Spacer()
                    Text(R.string.localizable.sortBy())
                        .font(.custom("Avenir-Medium", size: 12))

                    Menu {
                        ForEach(filters, id: \.self) { option in
                            Button {
                                selectedfilter = option
                            } label: {
                                Text(option)
                                    .font(.custom("Avenir-Medium", size: 12))
                                Circle()
                                    .strokeBorder(Color.gray, lineWidth: 2)
                                if selectedfilter == option {
                                    Image("ic_selected")
                                        .foregroundColor(.main)
                                        .frame(width: 18, height: 18)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedfilter)
                                .font(.custom("Avenir-Medium", size: 12))
                                .foregroundColor(.orange)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal, 16)

                // MARK: - Place List
                ScrollView {
                    VStack {
                        VStack(spacing: 8) {

                            if viewModel.isLoading {
                                ForEach(0..<5, id: \.self) { _ in
                                    SkeletonLocdetailCard()
                                }
                            } else {
                                let placedetail = viewModel.newFilter.prefix(viewModel.itemsToShow)
                                ForEach(Array(placedetail.enumerated()), id: \.element.id) { index, tag in
                                    let matchedImages = viewModel.arrayImageDetail.filter { $0.place_id == tag.id }
                                    let placeimage = matchedImages.first

                                    Locdetail(
                                        ratingCount: Int(tag.rating ?? "") ?? 0,
                                        placeIcon: tag.icon ?? "",
                                        image: placeimage?.image ?? "CityImage",
                                        Name: language == "ar"
                                            ? tag.place_name_ar ?? R.string.localizable.kaleOutletCenter()
                                            : tag.place_name ?? "Kale outlet center",
                                        location: tag.address ?? R.string.localizable.placeAddress(),
                                        Totallikes: tag.total_fav_place ?? "200 k",
                                        Totaldislikes: tag.total_unfav_place ?? "40 k",
                                        Distance: tag.distance ?? "200 k",
                                        Description: language == "ar"
                                            ? tag.description_ar ?? ""
                                            : tag.description ?? "",
                                        tagsdetail: tag.tag_details!,
                                        onFavTap: {
                                            viewModel.Fav(id: tag.id, index: index) { isRemoving, message in
                                                guard placedetail.indices.contains(index) else { return }
                                                viewModel.newFilter[index].currentUserFavorite = !isRemoving
                                                toastMessage = message
                                                showToast = true
                                                viewModel.toggleFavoriteLocally(placeId: tag.id ?? "", isRemoving: isRemoving)
                                            }
                                        },
                                        isfav: tag.currentUserFavorite ?? false,
                                        favStatus: tag.fav_status ?? "",
                                        like: {
                                            viewModel.likeButton(id: tag.id, index: index) { didChangeToUnlike in
                                                guard didChangeToUnlike else { return }
                                                guard viewModel.newFilter.indices.contains(index) else { return }
                                                let current = viewModel.newFilter[index]
                                                if let str = current.total_fav_place, let count = Int(str) {
                                                    viewModel.newFilter[index].total_fav_place = String(count + 1)
                                                }
                                                if let str = current.total_unfav_place, let count = Int(str), count > 0 {
                                                    viewModel.newFilter[index].total_unfav_place = String(count - 1)
                                                }
                                                viewModel.newFilter[index].fav_status = "Like"
                                            }
                                        },
                                        Unlike: {
                                            viewModel.unlikeButton(id: tag.id, index: index) { didChangeToUnlike in
                                                guard didChangeToUnlike else { return }
                                                guard viewModel.newFilter.indices.contains(index) else { return }
                                                let current = viewModel.newFilter[index]
                                                if let str = current.total_unfav_place, let count = Int(str) {
                                                    viewModel.newFilter[index].total_unfav_place = String(count + 1)
                                                }
                                                if let str = current.total_fav_place, let count = Int(str), count > 0 {
                                                    viewModel.newFilter[index].total_fav_place = String(count - 1)
                                                }
                                                viewModel.newFilter[index].fav_status = "UnLike"
                                            }
                                        }
                                    )
                                    .onTapGesture {
                                        viewModel.openType = .filter
                                        selectedIndex = index
                                    }

                                    NavigationLink(
                                        destination: DetailView(index: index, viewModel: viewModel, VM: GooglePlaceVM()),
                                        tag: index,
                                        selection: $selectedIndex
                                    ) {}
                                    .hidden()
                                }

                                if viewModel.isLoadingMore {
                                    ProgressView(R.string.localizable.loading())
                                        .padding()
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }

            }
            .edgesIgnoringSafeArea(.top)
            .toast(isPresented: $showToast, message: toastMessage)
        }
    }

    func updateSuggestions() {
        let allPlaces = viewModel.newFilter.map { $0.place_name ?? "" }
        suggestions = allPlaces.filter { $0.localizedCaseInsensitiveContains(text) }
        showSuggestions = !suggestions.isEmpty && !text.isEmpty && suggestions != [text]
    }
}
