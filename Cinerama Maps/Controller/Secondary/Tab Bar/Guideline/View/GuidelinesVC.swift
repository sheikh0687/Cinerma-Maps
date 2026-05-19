//
//  GuidelinesVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 28/08/24.
//

import UIKit
import WebKit
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
    var dateTime: String = ""
    var descriptionVal: String = ""
    var placeImg: String = ""
    var offerCode: String = ""
    var isFrom: String = ""
    
    private var hasLoadedOnce = false
    private var webView: WKWebView!
    
    // ✅ Cache key = unique identifier per content
    private var cacheKey: String {
        return "\(isFrom)_\(titleVal)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // ✅ Shared warm process pool + persistent data store
    private static let sharedProcessPool = WKProcessPool()
    private static let sharedDataStore = WKWebsiteDataStore.default()
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackGesture()
        
        guard !hasLoadedOnce else { return }
        hasLoadedOnce = true
        
        setupWebView()
        setGuideTips()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView?.stopLoading()
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
}

// MARK: - Setup UI
extension GuidelinesVC {
    
    private func setGuideTips() {
        wv_ContainerHeightConstraint.constant = 0
        wv_Container.isHidden = true
        view.layoutIfNeeded()
        
        if isFrom == "Advertisement" {
            lbl_Date.isHidden = true
            lbl_Headline.text = R.string.localizable.advertisementDetails()
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
        let config = WKWebViewConfiguration()
        config.processPool = GuidelinesVC.sharedProcessPool
        config.websiteDataStore = GuidelinesVC.sharedDataStore  // ✅ persistent cache
        
        let prefs = WKPreferences()
        prefs.javaScriptEnabled = true
        config.preferences = prefs
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
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

        webView.evaluateJavaScript(
            "Math.max(document.body.scrollHeight, document.documentElement.scrollHeight)"
        ) { [weak self] result, _ in

            guard let self else { return }
            guard let height = result as? CGFloat, height > 10 else { return }

            // Update UI smoothly
            self.wv_Container.isHidden = false
            self.wv_ContainerHeightConstraint.constant = height
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }

            // ⭐ SAVE HTML + HEIGHT TO CACHE
            webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { htmlResult, _ in
                if let finalHTML = htmlResult as? String {
                    WebViewCacheManager.shared.save(
                        html: finalHTML,
                        height: height,
                        forKey: self.cacheKey
                    )
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
        let cleanHTML = html.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanHTML.isEmpty, cleanHTML.uppercased() != "NA" else {
            wv_ContainerHeightConstraint.constant = 0
            wv_Container.isHidden = true
            return
        }

        let styledHTML = buildStyledHTML(cleanHTML, isArabic: isArabic)

        // 🔥 STEP 1 — SHOW CACHE INSTANTLY
        if let cache = WebViewCacheManager.shared.load(forKey: cacheKey) {
            wv_Container.isHidden = false
            wv_ContainerHeightConstraint.constant = cache.height   // ⭐ INSTANT HEIGHT
            webView.loadHTMLString(cache.html, baseURL: nil)
            view.layoutIfNeeded()
        }

        // 🔥 STEP 2 — LOAD FRESH IN BACKGROUND
        webView.loadHTMLString(styledHTML, baseURL: nil)
    }
    
    private func buildStyledHTML(_ content: String, isArabic: Bool) -> String {
        return """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
        <style>
            * { box-sizing: border-box; margin: 0; padding: 0; }
            html, body { width: 100%; height: auto; overflow: hidden; }
            body {
                font-family: -apple-system, "Helvetica Neue", Arial, sans-serif;
                font-size: 16px;
                line-height: 1.6;
                color: #1A1A1A;
                background-color: transparent;
                direction: \(isArabic ? "rtl" : "ltr");
                text-align: \(isArabic ? "right" : "left");
            }
            h1 { font-size: 20px; font-weight: 700; color: #E8510A; margin: 0 0 8px 0; padding: 0; line-height: 1.3; }
            h2 { font-size: 17px; font-weight: 700; color: #E8510A; margin: 16px 0 6px 0; padding: 0; line-height: 1.35; }
            h3 { font-size: 15px; font-weight: 600; color: #E8510A; margin: 12px 0 4px 0; padding: 0; line-height: 1.35; }
            p { font-size: 15px; color: #1A1A1A; margin: 0 0 10px 0; }
            ul, ol { font-size: 15px; color: #1A1A1A; margin: 4px 0 10px 0; padding-\(isArabic ? "right" : "left"): 20px; }
            li { margin-bottom: 4px; }
            strong, b { color: #1A1A1A; font-weight: 700; }
            hr { border: none; border-top: 1px solid #E0E0E0; margin: 12px 0; }
            img { max-width: 100%; height: auto; border-radius: 6px; display: block; }
            iframe { max-width: 100%; }
            a { color: #E8510A; text-decoration: none; }
            a:active { opacity: 0.7; }
        </style>
        </head>
        <body>\(content)</body>
        </html>
        """
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

// MARK: - Pre-warm
extension GuidelinesVC {
    
    /// Call once from AppDelegate or root TabBarVC
    static func preWarm() {
        let config = WKWebViewConfiguration()
        config.processPool = GuidelinesVC.sharedProcessPool
        config.websiteDataStore = GuidelinesVC.sharedDataStore
        let warmUp = WKWebView(frame: .zero, configuration: config)
        warmUp.loadHTMLString("<html><body></body></html>", baseURL: nil)
    }
}
