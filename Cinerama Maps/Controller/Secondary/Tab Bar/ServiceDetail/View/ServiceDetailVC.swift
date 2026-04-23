//
//  ServiceDetailVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 23/08/24.
//

import UIKit
import WebKit

class ServiceDetailImageCell: UICollectionViewCell {
    
    @IBOutlet weak var place_Img: UIImageView!
    override func awakeFromNib() {
            super.awakeFromNib()
        }
}

class ServiceDetailVC: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate {

    // MARK: - OUTLETS
    @IBOutlet weak var review_TableVw: UITableView!
    @IBOutlet weak var review_TableHeight: NSLayoutConstraint!
    @IBOutlet weak var servicePlace_ImgCollection: UICollectionView!
    @IBOutlet weak var lbl_ServiceName: UILabel!
    @IBOutlet weak var wv_Container: UIView!   // ⭐️ Replace lbl_ServiceDes with a plain UIView in storyboard
    @IBOutlet weak var lbl_ContactNum: UILabel!
    @IBOutlet weak var lbl_Address: UILabel!
    @IBOutlet weak var wv_ContainerHeight: NSLayoutConstraint!

    // MARK: - VARIABLES
    let viewModel = ServiceDetailViewModel()
    let servicePlaceRTL = RTLCollectionViewFlowLayout()

    // ⭐️ Isolated process pool (fix WEBP crash 100%)
    private let processPool = WKProcessPool()
    private var webView: WKWebView!

    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.review_TableVw.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        setupWebView()
        setupBackGesture()
        setUpBinding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // ⭐️ Stop loading when leaving screen
        webView.stopLoading()
    }

    deinit {
        // ⭐️ Destroy WebView properly (fix WebKit crash)
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        webView.stopLoading()
        webView.removeFromSuperview()
        webView = nil
        print("WKWebView Deallocated ✅")
    }

    // MARK: - ACTIONS
    @IBAction func btn_Back(_ sender: UIButton) {
        if webView.canGoBack {
            webView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func btn_ServiceReview(_ sender: UIButton) {
        viewModel.navigateToRatingReviewViewController(from: navigationController)
    }
}

extension ServiceDetailVC {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // ⭐️ Get actual HTML content height and resize container
        webView.evaluateJavaScript("document.body.scrollHeight") { [weak self] result, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let height = result as? CGFloat, height > 0 {
                    self.wv_ContainerHeight.constant = height
                    UIView.animate(withDuration: 0.2) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
}

// MARK: - WebView Setup
extension ServiceDetailVC {

    private func setupWebView() {
        webView?.removeFromSuperview()
        webView = nil

        let config = WKWebViewConfiguration()
        config.processPool = processPool           // ⭐️ CRASH FIX
        config.websiteDataStore = .nonPersistent() // ⭐️ CRASH FIX

        let prefs = WKPreferences()
        prefs.javaScriptEnabled = true
        config.preferences = prefs

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.isScrollEnabled = false // ⭐️ Let parent scroll view handle scrolling
        webView.backgroundColor = .clear
        webView.isOpaque = false

        wv_Container.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: wv_Container.topAnchor),
            webView.bottomAnchor.constraint(equalTo: wv_Container.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: wv_Container.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: wv_Container.trailingAnchor)
        ])
    }
}

// MARK: - Load HTML
extension ServiceDetailVC {

    private func loadHTML(_ html: String) {
        let styledHTML = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
        <style>
            body {
                font-family: -apple-system;
                font-size: 16px;
                color: black;
                padding: 0px;
                margin: 0px;
                direction: \(L102Language.currentAppleLanguage() == "ar" ? "rtl" : "ltr");
                text-align: \(L102Language.currentAppleLanguage() == "ar" ? "right" : "left");
            }
            img { max-width: 100%; height: auto; }
            iframe { max-width: 100%; }
            a { color: #007AFF; }
        </style>
        </head>
        <body>
        \(html)
        </body>
        </html>
        """
        webView.loadHTMLString(styledHTML, baseURL: URL(string: "https://cineramamaps.com"))
    }
}

// MARK: - Binding
extension ServiceDetailVC {

    private func setUpBinding() {
        viewModel.fetchServiceDetail(vC: self, tableHeight: review_TableHeight)
        viewModel.fetchedSuccessfully = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let obj = self.viewModel.arrayServiceDetail
                self.lbl_ServiceName.text = L102Language.currentAppleLanguage() == "en"
                    ? obj?.company_name
                    : obj?.company_name_ar
                
                // ⭐️ Load description HTML into WebView instead of UILabel
                let html = L102Language.currentAppleLanguage() == "ar"
                    ? (obj?.description_ar ?? "")
                    : (obj?.description_ar ?? "") // swap to description_en key if available
                self.loadHTML(html)

                self.lbl_ContactNum.text = obj?.mobile
                self.lbl_Address.text = obj?.address

                if L102Language.currentAppleLanguage() == "ar" {
                    self.servicePlaceRTL.scrollDirection = .horizontal
                    self.servicePlace_ImgCollection.collectionViewLayout = self.servicePlaceRTL
                    self.servicePlace_ImgCollection.semanticContentAttribute = .forceLeftToRight
                }
                self.servicePlace_ImgCollection.reloadData()
                self.review_TableVw.reloadData()
            }
        }
    }
}

// MARK: - Back Gesture
extension ServiceDetailVC {

    private func setupBackGesture() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if webView.canGoBack {
            webView.goBack()
            return false
        }
        return true
    }
}

// MARK: - TableView
extension ServiceDetailVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.arrayRatingReview.count
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

// MARK: - CollectionView
extension ServiceDetailVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.arrayOfImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ServiceDetailImageCell
        let obj = viewModel.arrayOfImages[indexPath.row]
        Utility.setImageWithSDWebImage(obj, cell.place_Img)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
