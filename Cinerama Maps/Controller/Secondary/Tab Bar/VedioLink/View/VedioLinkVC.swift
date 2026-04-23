//
//  VedioLinkVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 17/12/24.
//

import UIKit
import WebKit

class VedioLinkVC: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    var strUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.navigationDelegate = self
        let urlRequest = URLRequest.init(url: URL.init(string: strUrl)!)
        print(urlRequest)
        self.webView.load(urlRequest)
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
