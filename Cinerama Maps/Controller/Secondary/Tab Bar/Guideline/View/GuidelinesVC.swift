//
//  GuidelinesVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 28/08/24.
//

import UIKit
import WebKit
import SkeletonView
import SDWebImage

class GuidelinesVC: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - OUTLETS
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Date: UILabel!
    @IBOutlet weak var wv_Container: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbl_Headline: UILabel!
    @IBOutlet weak var discountButtonVw: UIView!
    @IBOutlet weak var btn_DiscountOt: UIButton!
    @IBOutlet weak var wv_ContainerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - VARIABLES
    var titleVal: String = ""
    var dateTime: String = "" {
        didSet {
            guard isViewLoaded else { return }
            lbl_Date.text = dateTime
        }
    }
    var descriptionVal: String = ""
    var placeImg: String = ""
    var offerCode: String = ""
    var isFrom: String = ""
    private var hasSetFinalHeight = false
    
    private let processPool = WKProcessPool()
    private var webView: WKWebView!
    private var isObservingContentSize = false
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupBackGesture()
        setupSkeletons()          // 1️⃣ Show skeleton first
        // ⭐️ Do NOT call setGuideTips() here
        // stopSkeletons() will call it once skeletons are ready to hide
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.stopSkeletons()  // 2️⃣ Hide skeleton + load data
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.stopLoading()
    }
    
    deinit {
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView?.stopLoading()
        webView?.removeFromSuperview()
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
    
    // MARK: - KVO Observer
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize",
           let scrollView = object as? UIScrollView {
            let newHeight = scrollView.contentSize.height
            guard newHeight > 10 else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.wv_ContainerHeightConstraint.constant != newHeight {
                    self.wv_ContainerHeightConstraint.constant = newHeight
                    self.webView.scrollView.isScrollEnabled = false
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

// MARK: - Setup UI
extension GuidelinesVC {
    
    // ⭐️ Only called from stopSkeletons() — never directly from viewDidLoad
    private func setGuideTips() {
        if isFrom == "Advertisement" {
            lbl_Date.isHidden = true
            lbl_Headline.text = R.string.localizable.advertisementDetails()
//            lbl_Title.textColor = .black
            discountButtonVw.isHidden = true
        } else if isFrom == "Guideline" {
            lbl_Date.isHidden = false
            lbl_Date.text = "\(self.dateTime)"
            lbl_Headline.text = R.string.localizable.guidelinesAndTips()
            lbl_Title.textColor = R.color.main()
            discountButtonVw.isHidden = true
        } else {
            lbl_Headline.text = R.string.localizable.offerDetails()
            lbl_Date.isHidden = true
            btn_DiscountOt.setTitle(offerCode, for: .normal)
            discountButtonVw.isHidden = false
        }
        
        lbl_Title.text = titleVal
        loadHTML(descriptionVal)
        
        if Router.BASE_IMAGE_URL != placeImg {
            img.sd_setImage(with: URL(string: placeImg), placeholderImage: nil)
        } else {
            img.image = R.image.blank()
        }
    }
}

// MARK: - WebView Setup
extension GuidelinesVC {
    
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
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        
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

// MARK: - WKNavigationDelegate
extension GuidelinesVC {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self, !self.hasSetFinalHeight else { return }
            self.webView.evaluateJavaScript("document.body.scrollHeight") { result, _ in
                guard let height = result as? CGFloat, height > 10 else { return }
                DispatchQueue.main.async {
                    self.hasSetFinalHeight = true
                    self.wv_ContainerHeightConstraint.constant = height
                    self.webView.scrollView.isScrollEnabled = false
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView navigation failed: \(error.localizedDescription)")
    }
}

// MARK: - Load HTML
extension GuidelinesVC {

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

// MARK: - Back Gesture
extension GuidelinesVC {
    
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

// MARK: - Skeleton
extension GuidelinesVC {

    func setupSkeletons() {
        [lbl_Title, lbl_Date, img, wv_Container].forEach {
            $0?.isSkeletonable = true
        }
        img.skeletonCornerRadius = 8
        wv_Container.skeletonCornerRadius = 8
        startSkeletons()
    }

    func startSkeletons() {
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        let gradient = SkeletonGradient(baseColor: .clouds)
        lbl_Title.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        lbl_Date.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        img.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        wv_Container.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
    }

    func stopSkeletons() {
        // 1️⃣ Hide ALL skeletons first — unblocks every view
        lbl_Title.hideSkeleton()
        lbl_Date.hideSkeleton()
        img.hideSkeleton()
        wv_Container.hideSkeleton()

        // 2️⃣ Views are now clear — safe to push real data
        DispatchQueue.main.async { [weak self] in
            self?.setGuideTips()
        }
    }
}
