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

    // ⭐️ Connect this outlet to the HEIGHT constraint of wv_Container in Storyboard
    @IBOutlet weak var wv_ContainerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - VARIABLES
    var titleVal: String = ""
    var dateTime: String = "" {
        didSet {
            // ⭐️ Safely update label if view is already loaded
            guard isViewLoaded else { return }
            lbl_Date.text = dateTime
        }
    }
    var descriptionVal: String = ""
    var placeImg: String = ""
    var offerCode: String = ""
    var isFrom: String = ""
    private var hasSetFinalHeight = false
    
    // ⭐️ Isolated process pool (fix WEBP crash 100%)
    private let processPool = WKProcessPool()
    private var webView: WKWebView!
    
    // ⭐️ Prevent redundant height updates
    private var isObservingContentSize = false
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupSkeletons()
        setGuideTips()
        setupBackGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // ⭐️ Stop loading when leaving screen
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
            guard newHeight > 10 else { return } // ⭐️ Ignore invalid/zero heights
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // ⭐️ Only update if height actually changed (avoid layout thrashing)
                if self.wv_ContainerHeightConstraint.constant != newHeight {
                    self.wv_ContainerHeightConstraint.constant = newHeight
                    self.webView.scrollView.isScrollEnabled = false
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

// MARK: - WebView Setup
extension GuidelinesVC {
    
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
        webView.backgroundColor = .clear
        webView.isOpaque = false
        
        // ⭐️ Disable internal scroll — outer ScrollView handles all scrolling
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
        
        // ⭐️ KVO to catch height changes from lazy-loaded images / late rendering
//        webView.scrollView.addObserver(self,
//                                       forKeyPath: "contentSize",
//                                       options: .new,
//                                       context: nil)
//        isObservingContentSize = true
    }
}

// MARK: - WKNavigationDelegate
extension GuidelinesVC {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // ⭐️ Small delay to allow images/media to finish laying out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self, !self.hasSetFinalHeight else { return }
            
            self.webView.evaluateJavaScript("document.body.scrollHeight") { result, _ in
                guard let height = result as? CGFloat, height > 10 else { return }
                DispatchQueue.main.async {
                    self.hasSetFinalHeight = true  // ⭐️ Set ONCE, never updated again
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
        let styledHTML = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
        <style>
            * { box-sizing: border-box; }
            body {
                font-family: 'Avenir-Book', -apple-system;
                font-size: 16px;
                color: black;
                padding: 0px;
                margin: 0px;
                direction: \(L102Language.currentAppleLanguage() == "ar" ? "rtl" : "ltr");
                text-align: \(L102Language.currentAppleLanguage() == "ar" ? "right" : "left");
            }
            img { max-width: 100%; height: auto; display: block; }
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

// MARK: - Setup UI
extension GuidelinesVC {
    
    private func setGuideTips() {
        if isFrom == "Advertisement" {
            self.lbl_Date.isHidden = true
            self.lbl_Headline.text = R.string.localizable.advertisementDetails()
            self.lbl_Title.textColor = .black
            discountButtonVw.isHidden = true
        } else if isFrom == "Guideline" {
            self.lbl_Date.isHidden = false
            self.lbl_Date.text = "\(self.dateTime)"
            print(self.dateTime)
            self.lbl_Headline.text = R.string.localizable.guidelinesAndTips()
            self.lbl_Title.textColor = R.color.main()
            discountButtonVw.isHidden = true
        } else {
            self.lbl_Headline.text = R.string.localizable.offerDetails()
            self.lbl_Date.isHidden = true
            self.btn_DiscountOt.setTitle(offerCode, for: .normal)
            discountButtonVw.isHidden = false
        }
        
        self.lbl_Title.text = self.titleVal
        
        loadHTML(descriptionVal)
        
        if Router.BASE_IMAGE_URL != placeImg {
            img.sd_setImage(with: URL(string: placeImg), placeholderImage: nil) { [weak self] _, _, _, _ in
                self?.img.hideSkeleton()
            }
        } else {
            self.img.image = R.image.blank()
            self.img.hideSkeleton()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.stopSkeletons()
        }
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

    private func setupSkeletons() {
        [lbl_Title, lbl_Date, img, wv_Container].forEach {
            $0?.isSkeletonable = true
        }
        img.isSkeletonable = true
        img.skeletonCornerRadius = 8
        startSkeletons()
    }

    private func startSkeletons() {
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        let gradient = SkeletonGradient(baseColor: .clouds)
        lbl_Title.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        lbl_Date.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        img.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        wv_Container.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
    }

    func stopSkeletons() {
        lbl_Title.hideSkeleton()
        lbl_Date.hideSkeleton()
        img.hideSkeleton()
        wv_Container.hideSkeleton()
    }
}
