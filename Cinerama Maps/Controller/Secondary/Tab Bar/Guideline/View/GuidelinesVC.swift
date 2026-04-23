//
//  GuidelinesVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 28/08/24.
//

import UIKit
import WebKit

//class GuidelinesVC: UIViewController {
//    
//    @IBOutlet weak var lbl_Title: UILabel!
//    @IBOutlet weak var lbl_Date: UILabel!
//    @IBOutlet weak var wv_Container: UIView!
//    @IBOutlet weak var img: UIImageView!
//    
//    @IBOutlet weak var lbl_Headline: UILabel!
//    @IBOutlet weak var discountButtonVw: UIView!
//    @IBOutlet weak var btn_DiscountOt: UIButton!
//    
//    var titleVal:String = ""
//    var dateTime:String = ""
//    var descriptionVal:String = ""
//    var placeImg:String = ""
//    
//    var offerCode:String = ""
//    
//    var isFrom:String = ""
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setGuideTips()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.tabBarController?.tabBar.isHidden = true
//    }
//    
//    @IBAction func btn_Back(_ sender: UIButton) {
//        self.navigationController?.popViewController(animated: true)
//    }
//    
//    private func setGuideTips() {
//        
//        if isFrom == "Advertisement" {
//            self.lbl_Date.isHidden = true
//            self.lbl_Headline.text = R.string.localizable.advertisementDetails()
//            self.lbl_Title.textColor = .black
//            discountButtonVw.isHidden = true
//        } else if isFrom == "Guideline" {
//            self.lbl_Date.text = "\(R.string.localizable.theWritingDateIs()) \(self.dateTime)"
//            self.lbl_Date.isHidden = false
//            self.lbl_Headline.text = R.string.localizable.guidelinesAndTips()
//            self.lbl_Title.textColor = R.color.main()
//            discountButtonVw.isHidden = true
//        } else {
//            self.lbl_Headline.text = R.string.localizable.offerDetails()
//            self.lbl_Date.isHidden = true
//            self.btn_DiscountOt.setTitle(offerCode, for: .normal)
//            discountButtonVw.isHidden = false
//        }
//        
//        self.lbl_Title.text = self.titleVal
//        
//        let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>body { font-family: 'Avenir-Book'; font-size: 16px; color: black; }</style></header>"
//        wv_Description.loadHTMLString(headerString + descriptionVal, baseURL: nil)
//                
//        if Router.BASE_IMAGE_URL != placeImg {
//            Utility.setImageWithSDWebImage(placeImg, self.img)
//        } else {
//            self.img.image = R.image.blank()
//        }
//    }
//}

class GuidelinesVC: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - OUTLETS
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Date: UILabel!
    @IBOutlet weak var wv_Container: UIView!   // ⭐️ Replace WKWebView outlet with a plain UIView container
    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var lbl_Headline: UILabel!
    @IBOutlet weak var discountButtonVw: UIView!
    @IBOutlet weak var btn_DiscountOt: UIButton!
    
    // MARK: - VARIABLES
    var titleVal: String = ""
    var dateTime: String = ""
    var descriptionVal: String = ""
    var placeImg: String = ""
    var offerCode: String = ""
    var isFrom: String = ""
    
    // ⭐️ Isolated process pool (fix WEBP crash 100%)
    private let processPool = WKProcessPool()
    private var webView: WKWebView!
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
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
extension GuidelinesVC {
    
    private func loadHTML(_ html: String) {
        let styledHTML = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
        <style>
            body {
                font-family: 'Avenir-Book', -apple-system;
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

// MARK: - Setup UI
extension GuidelinesVC {
    
    private func setGuideTips() {
        if isFrom == "Advertisement" {
            self.lbl_Date.isHidden = true
            self.lbl_Headline.text = R.string.localizable.advertisementDetails()
            self.lbl_Title.textColor = .black
            discountButtonVw.isHidden = true
            
        } else if isFrom == "Guideline" {
            self.lbl_Date.text = "\(R.string.localizable.theWritingDateIs()) \(self.dateTime)"
            self.lbl_Date.isHidden = false
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
        
        loadHTML(descriptionVal) // ⭐️ Use the safe loadHTML method
        
        if Router.BASE_IMAGE_URL != placeImg {
            Utility.setImageWithSDWebImage(placeImg, self.img)
        } else {
            self.img.image = R.image.blank()
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
