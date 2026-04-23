//
//  FlipImageExtension.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 04/08/25.
//

import UIKit
import ObjectiveC

private var shouldFlipImageKey: UInt8 = 0

extension UIImageView {
    @IBInspectable var shouldFlipForRTL: Bool {
        get {
            return objc_getAssociatedObject(self, &shouldFlipImageKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &shouldFlipImageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsLayout()
        }
    }

    @objc func cstmLayoutSubviews() {
        self.cstmLayoutSubviews()
        // Only flip if the inspectable property is true
        guard shouldFlipForRTL else { return }
        if UIApplication.isRTL() {
            if let img = self.image, !img.imageFlippedForRightToLeftLayoutDirection().isEqual(img) {
                self.image = img.imageFlippedForRightToLeftLayoutDirection()
            }
        } else {
            if let img = self.image, img.imageFlippedForRightToLeftLayoutDirection().isEqual(img) {
                self.image = img.withHorizontallyFlippedOrientation()
            }
        }
    }
}
