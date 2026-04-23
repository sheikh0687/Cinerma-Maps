//
//  UIKitIconLoader.swift
//  Cinerama Maps
//
//  Created by Arbaz  on 17/04/26.
//

import Foundation
import SwiftUI

struct UIKitIconLoader: UIViewRepresentable {
    let url: String

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        // ⭐ Force intrinsic size to zero so SwiftUI frame wins
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return imageView
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {
        Utility.imageWithSDWebImage(url, imageView)
    }
}
