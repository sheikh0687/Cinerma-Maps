
import SwiftUI
import WebKit

//struct WebView: UIViewRepresentable {
//    let htmlString: String
//
//    func makeUIView(context: Context) -> WKWebView {
//        return WKWebView()
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>body { font-family: 'Avenir-Book'; font-size: 14px; color: black; }</style></header>"
//        uiView.loadHTMLString(headerString + htmlString, baseURL: nil)
//    }
//}

enum InfoRowType {
    case suggestedTime(String)
    case video(String) // URL or action identifier
    case discount(String, String)
    case advice(String, String) // (text, link URL)
}

struct InfoRow: View {
    
    @Environment(\.openURL) private var openURL
    @State private var isExpanded: Bool = false
    
    var icon: String
    var label: String
    var value: String?
    var extraValue: String? = nil
    var percentLabel: String? = nil
    var videoURL: String? = nil
    var link: Bool = false
    var isAdvice: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            HStack {
                Image(icon)
                    .frame(width: 30)
                    .foregroundColor(.orange)
                
                Text(label)
                    .foregroundColor(.gray)
                    .frame(alignment: .leading).font(.custom("Avenir-Medium", size: 12))
            }

            if isAdvice, let value = value {
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .foregroundColor(.black)
                        .font(.custom("Avenir-Medium",
                                      size: value == "∞" ? 28 : 14))
                        .lineLimit(isExpanded ? nil : 2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if value != "" {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isExpanded.toggle()
                            }
                        } label: {
                            if L102Language.currentAppleLanguage() == "en" {
                                Text(isExpanded
                                     ? "Read Less"
                                     : (extraValue ?? "Read More"))
                                    .font(.custom("Avenir-Medium", size: 13))
                                    .foregroundColor(.blue)
                                    .underline()
                            } else {
                                Text(isExpanded
                                     ? "اقرأ أقل"
                                     : (extraValue ?? "اقرأ المزيد"))
                                    .font(.custom("Avenir-Medium", size: 13))
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                        }
                    }
                }
            } else if label == R.string.localizable.advice(), let value = value, let extra = extraValue {
                (
                    Text(value)
                        .foregroundColor(.black)
                    + Text(" ") +
                    Text(extra)
                        .foregroundColor(.blue)
                )
                .font(.custom("Avenir-Medium", size: 14))
                .fixedSize(horizontal: false, vertical: true)
            } else {
                if percentLabel != "" {
                    if let extra = percentLabel {
                        Text(extra)
                            .lineLimit(1)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .background(Color.orange.opacity(0.2))
                            .overlay (
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.orange, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .frame(maxWidth: .infinity)
                    } else {
                        Spacer()
                    }
                }
                
                HStack {
                    if link, let urlString = videoURL, let url = URL(string: urlString) {
                        Button {
                            openURL(url)
                        } label: {
                            Text(value ?? "")
                                .foregroundColor(.blue)
                                .underline()
                                // ✅ Added size increase for ∞
                                .font(.custom("Avenir-Medium", size: value == "∞" ? 28 : 14))
                        }
                    } else {
                        // ✅ Added size increase for ∞
                        Text(value ?? "")
                            .font(.custom("Avenir-Medium", size: value == "∞" ? 28 : 14))
                    }
                    
                    if extraValue != "" {
                        if let extra = extraValue {
                            Text("\(extra)%")
                                .foregroundColor(.orange)
                                .padding(.horizontal, 20)
                                .background(Color.orange.opacity(0.2))
                                .overlay (
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.orange, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .font(.custom("Avenir-Medium", size: 14))
    }
}

struct Nearestloc: View {
    var Place: String
    var Title: String
    var Description: String
    var Location: String
    var Distance: String
    var body: some View {
        
        Divider()
        HStack(spacing: 12) {
            Image(Place)
                .resizable()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(Title)
                    .fontWeight(.bold)
                
                Text(Description)
                    .font(.custom("Avenir-Book", size: 12))
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Image("ic_location")
                        .imageScale(.small)
                        .foregroundColor(.orange)
                    Text(Location)
                        .font(.custom("Avenir-Book", size: 12))
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 6) {
                    Image("ic_routing")
                        .imageScale(.small)
                        .foregroundColor(.orange)
                    Text(Distance)
                        .font(.custom("Avenir-Book", size: 12))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct MostVist: View {
    var Place: String
    var Title: String
    var Description: String
    var Location: String
    var Distance: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(Place)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()
                .cornerRadius(10, corners: [.bottomRight, .bottomLeft])
                .cornerRadius(25, corners: [.topLeft, .topRight])
            VStack(alignment: .leading, spacing: 8){
                Text(Title)
                    .font(.custom("Avenir-Roman", size: 16))
                    .lineLimit(1)
                
                Text(Description)
                    .font(.custom("Avenir-Medium", size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image("ic_location")
                        .imageScale(.small)
                        .foregroundColor(.orange)
                    Text(Location)
                        .font(.custom("Avenir-Medium", size: 12))
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 4) {
                    Image("ic_routing")
                        .imageScale(.small)
                        .foregroundColor(.orange)
                    Text(Distance)
                        .font(.custom("Avenir-Medium", size: 12))
                        .foregroundColor(.gray)
                }
            }.padding(.horizontal,6)}
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.gray, lineWidth: 0.2))
        .frame(width: 220)
        .shadow(radius: 0.1)
        .padding(.horizontal)
        .background(Color.white)
        
    }
}

struct reviews: View {
    var Person: String
    var Name: String
    var Description: String
    
    var body: some View {
        
        Divider()
        VStack {
            HStack(spacing: 12) {
                Image(Person)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(Name)
                        .font(.custom("Avenir-Roman", size: 14))
                    
                    Text("1 day ago")
                        .font(.custom("Avenir-Medium", size: 12))
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack(spacing: 6){
                    Image(systemName: "heart.fill").foregroundColor(.orange)
                    Text("27")
                    
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                
            }
            HStack(spacing: 6) {
                Text(Description)
                    .font(.custom("Avenir-Medium", size: 12)).lineLimit(2)
                .foregroundColor(.gray)}}
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct Locdetail: View {
    
    @State private var attributedText: NSAttributedString = NSAttributedString(string: "")
    
    var ratingCount: Int
    var placeIcon: String
    var image: String
    var Name: String
    var location: String
    var Totallikes: String
    var Totaldislikes: String
    var Distance: String?
    var Description: String
    var tagsdetail: [Tag_details]
    var onFavTap: (() -> Void)?
    var Filters = ["All", "Coffee", "Coffee", "Coffee", "Coffee", "Coffee", "Coffee", "Coffee"]
    var isfav: Bool
    var favStatus: String?
    var like: (() -> Void)?    // <-- Add this
    var Unlike: (() -> Void)?    // <-- Add this
    
    var body: some View {
        LazyVStack(spacing: 0) {
            
            Color.gray.opacity(0.3)
                .frame(height: 180)
                .overlay (
                    ZStack(alignment: .topTrailing) {
                        AsyncImage(url: URL(string: image)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                            } else if phase.error != nil {
                                // Error state - show placeholder
                                Image("BackPlaceholder")
                                    .resizable()
                                    .scaledToFill()
                            }}
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .clipped()
                        
                        Button {
                            onFavTap!()
                        } label: {
                            Image(systemName:isfav ? "heart.fill":"heart")
                                .foregroundColor(isfav ? .orange : .white)
                                .padding(10)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .padding([.top, .trailing], 10)
                                .padding(.horizontal)
                        }
                    
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                
                                ZStack {
                                    Circle()
                                        .fill(Color.main)
                                    
                                    UIKitIconLoader(url: placeIcon)
                                        .scaledToFit()
                                        .padding(12)
                                }
                                .frame(width: 48, height: 48)   // ⭐ important
                                .clipShape(Circle())            // ⭐ THIS fixes the overflow
                                .shadow(radius: 3)
                                .padding([.bottom, .trailing], 10)
                            }
                        }
                        .padding(.horizontal)
                    }
                )
            
            VStack(alignment: .leading, spacing: 12) {
                Text(Name)
                    .font(.custom("Avenir-Roman", size: 16))
                    .padding(.top, 8)
                
                HStack {
                    HStack(spacing: 4) {
                        Button {
                            like?()
                        } label: {
                            Image(systemName:favStatus == "Like" ? "hand.thumbsup.fill": "hand.thumbsup")
                            .foregroundColor(favStatus == "Like" ? Color.orange : .black)}
                        Text(Totallikes)
                        Divider()
                            .frame(height: 16)
                        Button {
                            Unlike?()
                        } label: {
                            Image(systemName:favStatus == "UnLike" ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                            .foregroundColor(favStatus == "UnLike" ? Color.orange : .black)}
                        Text(Totaldislikes)
                    }
                    .font(.custom("Avenir-Medium", size: 14))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Image(systemName: "star.square.fill")
                                .foregroundColor(index < ratingCount ? .main : .gray)
                        }
                    }
                }
                
                HStack {
                    Image("ic_location")
                    Text(location).font(.custom("Avenir-Roman", size: 12))
                    Spacer()
                    Image("ic_routing")
                    Text( "\(R.string.localizable.awayFromYou()) \(Distance ?? "") \(R.string.localizable.km())")
                }
                .font(.caption)
                .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    //                        HTMLText(Description).font(.custom("Cairo-SemiBold", size: 12))
                    Text(attributedText.string).font(.custom("Avenir-Roman", size: 14))
                        .font(.caption)
                    //                            .foregroundColor(.gray)
                        .lineLimit(2)
                }
                .padding(.top, 4)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tagsdetail, id: \.id) { tag in
                            Text(L102Language.currentAppleLanguage() == "en" ? tag.tag_name ?? "" : tag.tag_name_ar ?? "")
                                .font(.custom("Avenir-Roman", size: 12))
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(colorFromHex(tag.color_code ?? ""))
                                )
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 4)
        .padding(.vertical, 4)
        .padding(.horizontal, 16)
        .onAppear {
            Task {
                let converted = convertHTMLToAttributedString(html: Description)
                await MainActor.run {
                    attributedText = converted
                }
            }
        }
    }
    
    func convertHTMLToAttributedString(html: String) -> NSAttributedString {
        guard let data = html.data(using: .utf8) else {
            return NSAttributedString(string: html)
        }
        
        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            return attributedString
        } catch {
            print("❌ Error converting HTML to attributed string:", error)
            return NSAttributedString(string: html)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
