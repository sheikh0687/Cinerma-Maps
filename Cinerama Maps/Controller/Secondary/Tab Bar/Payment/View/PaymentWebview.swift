import UIKit
import WebKit

final class PaymentWebview: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    private var paymentURL: URL?
    var paymentCompletion: ((_ status: Bool, _ isTapPaymentGateway: Bool) -> Void)? = nil
   
    
    override func viewDidLoad() {
        webView.navigationDelegate = self
        guard let paymentURL else { return }
        let request = URLRequest(url: paymentURL)
        webView.load(request)
    }
    
    func setURL(_ url : String) {
        paymentURL = URL(string: url)
    }
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension PaymentWebview: WKNavigationDelegate, WKScriptMessageHandler {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
       
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        let url = webView.url?.absoluteString ?? ""
        if url.contains("thankyou") && url.contains("status=paid") {
            paymentCompletion?(true, false)
            self.navigationController?.popViewController(animated: true)
            
        }
        
        if url.contains("webservice/redirect") {
            paymentCompletion?(true, true)
            self.navigationController?.popViewController(animated: true)
        }
        
        if url.contains("webservice/failed") {
            paymentCompletion?(false, true)
            self.navigationController?.popViewController(animated: true)
        }
        
        print("webURL=: ", url)
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        print(error)
    }

}
