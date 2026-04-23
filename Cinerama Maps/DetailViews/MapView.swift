import SwiftUI

struct MapView: View {
    //    MARK: PROPERTIES
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SubscriptionMapViewModel
    
    var onNavigate: ((Int) -> Void)?
    
    @State  var selectedfilter : String = "Popular"
    @State var Searching = false
    @State var isfav = false
    @State var Selected = 1
    
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var selectedIndex: Int? = nil
    
    //    MARK: DECLARED
    let language = k.userDefault.value(forKey: k.session.language) as? String
    var filters = ["Popular", "Name", "Oldest", "Distance"]
    
    var body: some View {
        
        VStack {
            if let data = viewModel.arrayTagDetails as? [Tag_details] {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        Button(action: {
                            viewModel.didSelectTag(nil)
                            viewModel.showingFavorites = false
                        }, label: {
                            Text(R.string.localizable.all())
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.main))
                            
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .fixedSize(horizontal: true, vertical: false)
                                .font(.custom("Avenir-Medium", size: 12))
                        })
                        
                        Button(action: {
                            viewModel.didSelectTag(nil)
                            viewModel.showingFavorites = true
                        }, label: {
                            HStack{
                                
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text(R.string.localizable.favorites())
                                    .foregroundColor(Color.white)
                                    .padding(.vertical, 4)
                            }.padding(.horizontal, 10)
                            
                            
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.main))
                            
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .fixedSize(horizontal: true, vertical: false)
                                .font(.custom("Avenir-Medium", size: 12))
                        })
                        
                        ForEach(data, id: \.id) { tag in
                            Button {
                                viewModel.showingFavorites = false
                                viewModel.didSelectTag(tag.tag_name)
                            } label: {
                                
                                Text(language == "ar" ?  tag.tag_name_ar ?? "" : tag.tag_name ?? "" )
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 4)
                                    .background (
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(colorFromHex(tag.color_code ?? ""))
                                    )
                                    .overlay (
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .font(.custom("Avenir-Medium", size: 12))
                            }}
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 8)
            }
            
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
                                .frame(width: 18, height: 18)}
                            
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedfilter)
                            .font(.custom("Avenir-Medium", size: 12))
                            .foregroundColor(.orange)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.orange)
                    }}
            }
            .padding(.horizontal, 16)
            
            if viewModel.newFilter.isEmpty {
                VStack { VStack(alignment: .leading) {
                    if viewModel.isLoadingMore {
                        ProgressView(R.string.localizable.loading())
                    } else {
                        Text("No Places match this Filter")
                    }
                }
                    Spacer()
                }
            } else {
                    ScrollView {
                        VStack {
                            VStack(spacing: 8) {
                                let placedetail = viewModel.newFilter
                                VStack {
                                    ForEach(Array(placedetail.enumerated()), id: \.element.id) { index, tag in
                                        let placeimage = viewModel.getImageFor(placeID: tag.id ?? "")
                                        Locdetail (
                                            ratingCount: Int(tag.rating ?? "") ?? 0,
                                            placeIcon: tag.icon ?? "",
                                            image: placeimage?.image ?? "CityImage",
                                            Name: language == "ar" ? tag.place_name_ar ?? R.string.localizable.kaleOutletCenter() : tag.place_name ?? R.string.localizable.kaleOutletCenter(),
                                            location: tag.address ?? R.string.localizable.placeAddress(),
                                            Totallikes: tag.total_fav_place ?? "200 k",
                                            Totaldislikes: tag.total_unfav_place ?? "40 k",
                                            Distance: tag.distance ?? "200 k",
                                            Description: language == "ar" ? tag.description_ar ?? "" : tag.description ?? "",
                                            tagsdetail: tag.tag_details!,
                                            onFavTap: {
                                                viewModel.Fav(id: tag.id, index: index) { isRemoving, message in
                                                    guard placedetail.indices.contains(index) else { return }
                                                    viewModel.newFilter[index].currentUserFavorite = !isRemoving
                                                    
                                                    // 👇 Show toast here (in View)
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
                                                    
                                                    // Update total_unfav_place
                                                    if let unfavCountStr = current.total_fav_place,
                                                       let unfavCount = Int(unfavCountStr) {
                                                        viewModel.newFilter[index].total_fav_place = String(unfavCount + 1)
                                                    }
                                                    
                                                    // Update total_fav_place (decrement)
                                                    if let favCountStr = current.total_unfav_place,
                                                       let favCount = Int(favCountStr), favCount > 0 {
                                                        viewModel.newFilter[index].total_unfav_place = String(favCount - 1)
                                                    }
                                                    
                                                    // Update fav_status
                                                    viewModel.newFilter[index].fav_status = "Like"
                                                }
                                            },
                                            Unlike: {
                                                viewModel.unlikeButton(id: tag.id, index: index) { didChangeToUnlike in
                                                    guard didChangeToUnlike else { return }
                                                    guard viewModel.newFilter.indices.contains(index) else { return }
                                                    
                                                    let current = viewModel.newFilter[index]
                                                    
                                                    // Update total_unfav_place
                                                    if let unfavCountStr = current.total_unfav_place,
                                                       let unfavCount = Int(unfavCountStr) {
                                                        viewModel.newFilter[index].total_unfav_place = String(unfavCount + 1)
                                                    }
                                                    
                                                    // Update total_fav_place (decrement)
                                                    if let favCountStr = current.total_fav_place,
                                                       let favCount = Int(favCountStr), favCount > 0 {
                                                        viewModel.newFilter[index].total_fav_place = String(favCount - 1)
                                                    }
                                                    viewModel.newFilter[index].fav_status = "UnLike"
                                                }
                                            })
                                        .onTapGesture(perform: {
                                            onNavigate?(index)
                                        })
                                        .onAppear {
                                            viewModel.loadMoreIfNeeded(currentItem: tag)
                                        }
                                    }
                                }
                            }
                        }
                    }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toast(isPresented: $showToast, message: toastMessage)
            }
        }
        
    }
    
}

