//
//  Policy'sVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 28/08/24.
//

import UIKit
import Foundation
import WebKit

class Policy_sVC: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate {

    // MARK: - OUTLETS
    @IBOutlet weak var lbl_Headline: UILabel!
    @IBOutlet weak var webContainer: UIView!
    
    // MARK: - VARIABLES
    private var webView: WKWebView!
    var isFrom: String = ""
    
    // ⭐️ KEY FIX: Isolated process pool (fix WEBP crash 100%)
    private let processPool = WKProcessPool()
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle()
        setupWebView()
        setupBackGesture()
        fetchAllPolicies()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // ⭐️ IMPORTANT: stop loading when leaving screen
        webView.stopLoading()
    }
    
    deinit {
        // ⭐️ CRITICAL: Destroy WebView properly (fix WebKit crash)
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        webView.stopLoading()
        webView.removeFromSuperview()
        webView = nil
        print("WKWebView Deallocated ✅")
    }
}

extension Policy_sVC {
    
    private func setupWebView() {
        
        // Remove old instance safely
        webView?.removeFromSuperview()
        webView = nil
        
        let config = WKWebViewConfiguration()
        config.processPool = processPool        // ⭐️ CRASH FIX
        config.websiteDataStore = .nonPersistent() // ⭐️ CRASH FIX
        
        let prefs = WKPreferences()
        prefs.javaScriptEnabled = true
        config.preferences = prefs
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false // ⭐️ swipe conflict fix
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.backgroundColor = .clear
        webView.isOpaque = false
        
        webContainer.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: webContainer.topAnchor),
            webView.bottomAnchor.constraint(equalTo: webContainer.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: webContainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webContainer.trailingAnchor)
        ])
    }
}

extension Policy_sVC {
    
    func setupTitle() {
        if isFrom == "TermCondition" {
            lbl_Headline.text = R.string.localizable.termsAndCondition()
        } else if isFrom == "Policy" {
            lbl_Headline.text = R.string.localizable.privacyPolicy()
        } else {
            lbl_Headline.text = R.string.localizable.aboutUs()
        }
    }
}

extension Policy_sVC {
    
    private func setupBackGesture() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // If webView has history → go back inside web
        if webView.canGoBack {
            webView.goBack()
            return false
        }
        
        return true
    }
}

extension Policy_sVC {
    
    @IBAction func btn_Back(_ sender: UIButton) {
        
        if webView.canGoBack {
            webView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension Policy_sVC {
    
    private func loadHTML(_ html: String) {
        
        let styledHTML = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                font-family: -apple-system;
                font-size: 16px;
                padding: 16px;
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
        
        webView.loadHTMLString(styledHTML,
                               baseURL: URL(string: "https://cineramamaps.com"))
    }
}

extension Policy_sVC {
    
    func fetchAllPolicies() {
        Api.shared.requestToAppPolicies(self) { [weak self] responseData in
            guard let self = self else { return }
            
            var html = ""
            
            if self.isFrom == "TermCondition" {
                html = L102Language.currentAppleLanguage() == "en"
                ? (responseData.term ?? "")
                : (responseData.term_sp ?? "")
                
            } else if self.isFrom == "Policy" {
                html = L102Language.currentAppleLanguage() == "ar"
                ? (responseData.privacy_sp ?? "")
                : (responseData.privacy ?? "")
                
            } else {
                html = L102Language.currentAppleLanguage() == "ar"
                ? (responseData.about_us_sp ?? "")
                : (responseData.about_us ?? "")
            }
            
            self.loadHTML(html)
        }
    }
}
