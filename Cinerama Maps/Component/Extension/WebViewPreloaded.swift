//
//  WebViewPreloaded.swift
//  Cinerama Maps
//
//  Created by Arbaz  on 19/05/26.
//

import Foundation

struct CachedWebContent: Codable {
    let html: String
    let height: CGFloat
}

class WebViewCacheManager {

    static let shared = WebViewCacheManager()
    private init() {}

    private func fileURL(forKey key: String) -> URL {
        let fileName = key.replacingOccurrences(of: " ", with: "_")
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("\(fileName).json")
    }

    // SAVE HTML + HEIGHT
    func save(html: String, height: CGFloat, forKey key: String) {
        let data = CachedWebContent(html: html, height: height)
        if let encoded = try? JSONEncoder().encode(data) {
            try? encoded.write(to: fileURL(forKey: key))
        }
    }

    // LOAD HTML + HEIGHT
    func load(forKey key: String) -> CachedWebContent? {
        guard let data = try? Data(contentsOf: fileURL(forKey: key)) else { return nil }
        return try? JSONDecoder().decode(CachedWebContent.self, from: data)
    }
}
