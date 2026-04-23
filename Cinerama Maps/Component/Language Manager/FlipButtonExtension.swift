//
//  FlipButtonExtension.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 04/08/25.
//

import UIKit
import ObjectiveC

private var shouldFlipButtonKey: UInt8 = 0

extension UIButton {
    @IBInspectable var shouldFlipForRTL: Bool {
        get {
            return objc_getAssociatedObject(self, &shouldFlipButtonKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &shouldFlipButtonKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsLayout()
        }
    }

    @objc func cstmLayoutSubviews() {
        self.cstmLayoutSubviews()
        // Only flip if the inspectable property is true
        guard shouldFlipForRTL else { return }
        let isRTL = UIApplication.isRTL()
        self.semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        self.titleLabel?.textAlignment = isRTL ? .right : .left
        
        if let image = self.image(for: .normal) {
            let adjustedImage = isRTL
                ? image.imageFlippedForRightToLeftLayoutDirection()
                : image
            self.setImage(adjustedImage, for: .normal)
        }
    }
}
