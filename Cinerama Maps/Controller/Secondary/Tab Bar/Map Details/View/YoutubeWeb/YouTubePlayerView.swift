//
//  YouTubePlayerView.swift
//  Cinerama Maps
//
//  Created by Arbaz  on 18/04/26.
//

import SwiftUI
import WebKit

// MARK: - SwiftUI YouTube Player
struct YouTubePlayerView: View {
    let videoID: String
    let originalURL: String
    var showCloseButton: Bool = true
    @Environment(\.dismiss) var dismiss
    @State private var showError = false
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            // Header
            if showCloseButton {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .background(Color.black)
            }            
            if showError {
                embeddingDisabledView
            } else {
                GeometryReader { geo in
                    ZStack {
                        YouTubeWebView (
                            videoID: videoID,
                            onError: { showError = true },
                            isLoading: $isLoading
                        )
                        .frame(width: geo.size.width,
                               height: geo.size.width * 9 / 16)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: geo.size.width,
                                       height: geo.size.width * 9 / 16)
                        }
                    }
                }
            }
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    // MARK: - Error View
    var embeddingDisabledView: some View {
        VStack(spacing: 20) {
            Image(systemName: "play.slash.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Video can't be played here")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("This video cannot be embedded.\nTap below to watch it on YouTube.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { openInYouTube() }) {
                HStack(spacing: 10) {
                    Image(systemName: "play.rectangle.fill")
                    Text("Watch on YouTube")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 14)
                .background(Color.red)
                .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    func openInYouTube() {
        if let appURL = URL(string: "youtube://\(videoID)"),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL = URL(string: originalURL) {
            UIApplication.shared.open(webURL)
        }
        dismiss()
    }
}

// MARK: - WKWebView Bridge
struct YouTubeWebView: UIViewRepresentable {
    let videoID: String
    var onError: () -> Void
    @Binding var isLoading: Bool
    
    // ✅ Same as Policy_sVC
    private static let processPool = WKProcessPool()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onError: onError, isLoading: $isLoading)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.processPool = YouTubeWebView.processPool
        config.websiteDataStore = .nonPersistent()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // ✅ ADD THESE TWO
        config.allowsPictureInPictureMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true
        
        let prefs = WKPreferences()
        prefs.javaScriptEnabled = true
        config.preferences = prefs
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = context.coordinator
        
        // ✅ ADD THIS — mimics Safari so YouTube allows playback
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard uiView.url == nil else { return }
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body, html { 
                    width: 100%; 
                    height: 100%; 
                    background-color: #000; 
                    overflow: hidden;
                }
                .video-container {
                    position: relative;
                    width: 100%;
                    height: 100%;
                }
                iframe {
                    position: absolute;
                    top: 0; left: 0;
                    width: 100%;
                    height: 100%;
                    border: none;
                }
            </style>
        </head>
        <body>
            <div class="video-container">
                <iframe
                    src="https://www.youtube-nocookie.com/embed/\(videoID)?playsinline=1&autoplay=1&rel=0&modestbranding=1&showinfo=0"
                    allow="autoplay; fullscreen; encrypted-media; picture-in-picture"
                    allowfullscreen
                    frameborder="0">
                </iframe>
            </div>
        </body>
        </html>
        """
        uiView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, WKNavigationDelegate {
        var onError: () -> Void
        @Binding var isLoading: Bool
        
        init(onError: @escaping () -> Void, isLoading: Binding<Bool>) {
            self.onError = onError
            self._isLoading = isLoading
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
            
            // Detect YouTube error codes
            let js = """
            setTimeout(function() {
                var errorCodes = ['152', '153', '150', '101'];
                var bodyText = document.body.innerText || '';
                for (var i = 0; i < errorCodes.length; i++) {
                    if (bodyText.includes(errorCodes[i])) {
                        window.webkit.messageHandlers.youtubeError.postMessage('error');
                        break;
                    }
                }
            }, 2000);
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
            onError()
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading = false
            onError()
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url, 
               navigationAction.navigationType == .linkActivated {
                // Prevent navigating away from the embed
                if url.host?.contains("youtube.com") == true && !url.path.contains("/embed/") {
                    decisionHandler(.cancel)
                    return
                }
                
                // If it's a completely external link, stay in app or prevent it
                if url.scheme == "http" || url.scheme == "https" {
                    // You could also open it in a SafariViewController here if you wanted, 
                    // but "not opening a new tab" usually means "don't leave the current context".
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
    }
}
