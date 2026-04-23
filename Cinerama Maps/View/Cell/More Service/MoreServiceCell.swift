//
//  MoreServiceCell.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 16/11/24.
//

import UIKit
import WebKit

class MoreServiceCell: UITableViewCell, WKNavigationDelegate {
    
    @IBOutlet weak var view_Company: UIView!
    @IBOutlet weak var lbl_CompanyName: UILabel!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var vw_Container: UIView!
    @IBOutlet weak var vw_ContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var lbl_Description: UILabel!
    @IBOutlet weak var company_Img: UIImageView!
    
    @IBOutlet weak var view_Cities: UIView!
    @IBOutlet weak var city_Img: UIImageView!
    @IBOutlet weak var lbl_CityTitle: UILabel!
    @IBOutlet weak var lbl_CityDescription: UILabel!
    @IBOutlet weak var lbl_CityName: UILabel!
    @IBOutlet weak var city_Container: UIView!              // ⭐️ New UIView replacing lbl_CityDescription
    @IBOutlet weak var city_ContainerHeight: NSLayoutConstraint! // ⭐️ Height outlet
    
    private var webView: WKWebView?
    private var cityWebView: WKWebView?
    
    var onCompanyWebViewHeightUpdate: ((CGFloat) -> Void)?
    var onCityWebViewHeightUpdate: ((CGFloat) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // ⭐️ Stop loading on reuse to avoid ghost callbacks
//        webView?.stopLoading()
//        cityWebView?.stopLoading()
//        
//        // ⭐️ Reset heights so old content doesn't flash
//        vw_ContainerHeight.constant = 44
//        city_ContainerHeight.constant = 44

    }
    
    // MARK: - Setup WebViews
    func setupCompanyWebView(processPool: WKProcessPool) {
        webView?.removeFromSuperview()
        webView = makeWebView(processPool: processPool, delegate: self)
        vw_Container.addSubview(webView!)
        pinWebView(webView!, to: vw_Container)
    }
    
    func setupCityWebView(processPool: WKProcessPool) {
        cityWebView?.removeFromSuperview()
        cityWebView = makeWebView(processPool: processPool, delegate: self)
        city_Container.addSubview(cityWebView!)
        pinWebView(cityWebView!, to: city_Container)
    }
    
    private func makeWebView(processPool: WKProcessPool, delegate: WKNavigationDelegate) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.processPool = processPool
        config.websiteDataStore = .nonPersistent()
        
        let prefs = WKPreferences()
        prefs.javaScriptEnabled = true
        config.preferences = prefs
        
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = delegate
        wv.allowsBackForwardNavigationGestures = false
        wv.scrollView.isScrollEnabled = false
        wv.scrollView.contentInsetAdjustmentBehavior = .never
        wv.backgroundColor = .clear
        wv.isOpaque = false
        return wv
    }
    
    private func pinWebView(_ wv: WKWebView, to container: UIView) {
        wv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wv.topAnchor.constraint(equalTo: container.topAnchor),
            wv.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            wv.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            wv.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }
    
    // MARK: - Load HTML
    func loadCompanyHTML(_ html: String) {
        webView?.loadHTMLString(styledHTML(html), baseURL: URL(string: "https://cineramamaps.com"))
    }
    
    func loadCityHTML(_ html: String) {
        cityWebView?.loadHTMLString(styledHTML(html), baseURL: URL(string: "https://cineramamaps.com"))
    }
    
    private func styledHTML(_ html: String) -> String {
        let dir = L102Language.currentAppleLanguage() == "ar" ? "rtl" : "ltr"
        let align = L102Language.currentAppleLanguage() == "ar" ? "right" : "left"
        return """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
        <style>
            body {
                font-family: -apple-system;
                font-size: 15px;
                color: black;
                padding: 0; margin: 0;
                direction: \(dir);
                text-align: \(align);
            }
            img { max-width: 100%; height: auto; }
            a { color: #007AFF; }
        </style>
        </head>
        <body>\(html)</body>
        </html>
        """
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.scrollHeight") { [weak self] result, _ in
            guard let self = self, let height = result as? CGFloat, height > 0 else { return }
            DispatchQueue.main.async {
                if webView === self.webView {
                    self.vw_ContainerHeight.constant = height
                    self.onCompanyWebViewHeightUpdate?(height)
                } else if webView === self.cityWebView {
                    self.city_ContainerHeight.constant = height
                    self.onCityWebViewHeightUpdate?(height)
                }
                // ⭐️ Force layout on the cell immediately
                self.layoutIfNeeded()
            }
        }
    }
}
