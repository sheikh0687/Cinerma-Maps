//
//  ServiceDetailVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 23/08/24.
//

import UIKit
import WebKit
import SkeletonView

class ServiceDetailImageCell: UICollectionViewCell {
    
    @IBOutlet weak var place_Img: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if L102Language.currentAppleLanguage() == "en" {
            pageControl.semanticContentAttribute = .forceLeftToRight
        } else {
            pageControl.semanticContentAttribute = .forceRightToLeft
        }
    }
}

class ServiceDetailVC: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate {

    // MARK: - OUTLETS
    @IBOutlet weak var review_TableVw: UITableView!
    @IBOutlet weak var review_TableHeight: NSLayoutConstraint!
    @IBOutlet weak var servicePlace_ImgCollection: UICollectionView!
    @IBOutlet weak var lbl_ServiceName: UILabel!
    @IBOutlet weak var wv_Container: UIView!
    @IBOutlet weak var lbl_ContactNum: UILabel!
    @IBOutlet weak var lbl_Address: UILabel!
    @IBOutlet weak var wv_ContainerHeight: NSLayoutConstraint!

    // MARK: - VARIABLES
    let viewModel = ServiceDetailViewModel()
    let servicePlaceRTL = RTLCollectionViewFlowLayout()

    private let processPool = WKProcessPool()
    private var webView: WKWebView!

    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.review_TableVw.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        servicePlace_ImgCollection.isPagingEnabled = true
        servicePlace_ImgCollection.showsHorizontalScrollIndicator = false
        setupWebView()
        setupBackGesture()
        setupSkeletons()   // 1️⃣ Skeletons first
        setUpBinding()     // 2️⃣ Start API call — stopSkeletons() fires in callback
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.stopLoading()
    }

    deinit {
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

// MARK: - WKNavigationDelegate
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
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView navigation failed: \(error.localizedDescription)")
    }
}

// MARK: - WebView Setup
extension ServiceDetailVC {

    private func setupWebView() {
        webView?.removeFromSuperview()
        webView = nil

        let config = WKWebViewConfiguration()
        config.processPool = processPool
        config.websiteDataStore = .nonPersistent()

        let prefs = WKPreferences()
        prefs.javaScriptEnabled = true
        config.preferences = prefs

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
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
        let isArabic = L102Language.currentAppleLanguage() == "ar"
        let styledHTML = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
        <style>
            * { box-sizing: border-box; }
            body {
                font-family: -apple-system, "Helvetica Neue", Arial, sans-serif;
                font-size: 16px;
                line-height: 1.6;
                color: #1A1A1A;
                background-color: transparent;
                padding: 0px;
                margin: 0px;
                direction: \(isArabic ? "rtl" : "ltr");
                text-align: \(isArabic ? "right" : "left");
            }
            h1 {
                font-size: 20px;
                font-weight: 700;
                color: #E8510A;
                margin: 0 0 8px 0;
                padding: 0;
                line-height: 1.3;
            }
            h2 {
                font-size: 17px;
                font-weight: 700;
                color: #E8510A;
                margin: 16px 0 6px 0;
                padding: 0;
                line-height: 1.35;
            }
            h3 {
                font-size: 15px;
                font-weight: 600;
                color: #E8510A;
                margin: 12px 0 4px 0;
                padding: 0;
                line-height: 1.35;
            }
            p {
                font-size: 15px;
                color: #1A1A1A;
                margin: 0 0 10px 0;
            }
            ul, ol {
                font-size: 15px;
                color: #1A1A1A;
                margin: 4px 0 10px 0;
                padding-\(isArabic ? "right" : "left"): 20px;
            }
            li { margin-bottom: 4px; }
            strong, b { color: #1A1A1A; font-weight: 700; }
            hr { border: none; border-top: 1px solid #E0E0E0; margin: 12px 0; }
            img { max-width: 100%; height: auto; border-radius: 6px; display: block; }
            iframe { max-width: 100%; }
            a { color: #E8510A; text-decoration: none; }
            a:active { opacity: 0.7; }
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

                // ⭐️ STEP 1: Hide ALL skeletons first — unblocks every view
                self.lbl_ServiceName.hideSkeleton()
                self.lbl_ContactNum.hideSkeleton()
                self.lbl_Address.hideSkeleton()
                self.wv_Container.hideSkeleton()
                self.servicePlace_ImgCollection.hideSkeleton(reloadDataAfter: false)
                self.review_TableVw.hideSkeleton(reloadDataAfter: false)

                // ⭐️ STEP 2: Now safe to push data into unblocked views
                let obj = self.viewModel.arrayServiceDetail
                self.lbl_ServiceName.text = L102Language.currentAppleLanguage() == "en"
                    ? obj?.company_name
                    : obj?.company_name_ar

                let html = L102Language.currentAppleLanguage() == "ar"
                    ? (obj?.description_ar ?? "")
                    : (obj?.description ?? "")  // ⭐️ Fixed: use correct key per language
                
                self.loadHTML(html)

                self.lbl_ContactNum.text = obj?.mobile
                self.lbl_Address.text = obj?.address

                if L102Language.currentAppleLanguage() == "ar" {
                    self.servicePlaceRTL.scrollDirection = .horizontal
                    self.servicePlace_ImgCollection.collectionViewLayout = self.servicePlaceRTL
                    self.servicePlace_ImgCollection.semanticContentAttribute = .forceLeftToRight
                }

                // ⭐️ STEP 3: Reload collections AFTER skeletons are hidden
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
extension ServiceDetailVC: UITableViewDataSource, UITableViewDelegate, SkeletonTableViewDataSource {

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "ReviewCell"
    }

    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
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
extension ServiceDetailVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SkeletonCollectionViewDataSource, UIScrollViewDelegate {

    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "Cell"
    }

    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.arrayOfImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ServiceDetailImageCell
        let obj = viewModel.arrayOfImages[indexPath.row]
        
        cell.pageControl.numberOfPages = viewModel.arrayOfImages.count
        Utility.setImageWithSDWebImage(obj, cell.place_Img)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == servicePlace_ImgCollection {
            let page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
            if let visibleCell = servicePlace_ImgCollection.visibleCells.first as? ServiceDetailImageCell {
                visibleCell.pageControl.currentPage = page
            }
        }
    }
}

// MARK: - Skeleton
extension ServiceDetailVC {

    func setupSkeletons() {
        let skeletonableViews: [UIView?] = [
            lbl_ServiceName, lbl_ContactNum, lbl_Address,
            wv_Container, servicePlace_ImgCollection, review_TableVw
        ]
        skeletonableViews.forEach { $0?.isSkeletonable = true }

        wv_Container.skeletonCornerRadius = 8
        servicePlace_ImgCollection.skeletonCornerRadius = 10

        startSkeletons()
    }

    func startSkeletons() {
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        let gradient = SkeletonGradient(baseColor: .clouds)

        lbl_ServiceName.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        lbl_ContactNum.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        lbl_Address.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        wv_Container.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        servicePlace_ImgCollection.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        review_TableVw.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
    }

    // ⭐️ Kept for any external callers — internally binding handles stop inline now
    func stopSkeletons() {
        lbl_ServiceName.hideSkeleton()
        lbl_ContactNum.hideSkeleton()
        lbl_Address.hideSkeleton()
        wv_Container.hideSkeleton()
        servicePlace_ImgCollection.hideSkeleton(reloadDataAfter: false)
        review_TableVw.hideSkeleton(reloadDataAfter: false)
    }
}
