//
//  MapMarkerView.swift
//  Cinerama Maps
//
//  Created by Asad on 04/12/2024.
//

import UIKit
import SwiftUI

class MapMarkerView: UIView {

    @IBOutlet weak var shadowImg: UIImageView!
    @IBOutlet weak var outerImg: UIImageView!
    @IBOutlet weak var lblPlaceName: UILabel!
    @IBOutlet weak var innerImg: UIImageView!
    @IBOutlet weak var pinView: PieChartView!
    @IBOutlet weak var mapIcon: UIImageView!
    @IBOutlet weak var txtHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        outerImg.layer.shadowColor = UIColor.black.cgColor
        outerImg.layer.shadowOpacity = 0.5
        outerImg.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerImg.layer.shadowRadius = 2
        outerImg.layer.masksToBounds = false
        lblPlaceName.alpha = 0
    }
    
    func setText(text: String, font: UIFont) {
        lblPlaceName.text = text
        lblPlaceName.textAlignment = .center
        lblPlaceName.addTextOutline(usingColor: .white, outlineWidth: 2)
    }
}

class PieChartView: UIView {
    var sliceColors: [UIColor] = []

    override func draw(_ rect: CGRect) {
        guard sliceColors.count > 0 else { return }

        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        let angleIncrement = 2 * CGFloat.pi / CGFloat(sliceColors.count)

        // Rotate -30 degrees (in radians)
        let rotationOffset = 30 * CGFloat.pi / 180

        for i in 0..<sliceColors.count {
            let startAngle = CGFloat(i) * angleIncrement + rotationOffset
            let endAngle = startAngle + angleIncrement

            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.close()

            let sliceColor = sliceColors[i % sliceColors.count]
            sliceColor.setFill()
            path.fill()
        }
    }
}

extension UILabel {
    func addTextOutline(usingColor outlineColor: UIColor, outlineWidth: CGFloat) {
        class OutlinedText: UILabel {
            var outlineWidth: CGFloat = 0
            var outlineColor: UIColor = .clear

            override func drawText(in rect: CGRect) {
                guard let context = UIGraphicsGetCurrentContext() else {
                    super.drawText(in: rect)
                    return
                }

                let originalTextColor = self.textColor

                context.setLineWidth(self.outlineWidth)
                context.setLineJoin(.round)
                context.setTextDrawingMode(.stroke)

                self.textColor = self.outlineColor
                super.drawText(in: rect)

                context.setTextDrawingMode(.fill)
                self.textColor = originalTextColor
                super.drawText(in: rect)
            }
        }

        let outlineTag = 9999

        // Remove previous outline if it exists
        if let prevTextOutline = viewWithTag(outlineTag) {
            prevTextOutline.removeFromSuperview()
        }

        let textOutline = OutlinedText()
        textOutline.outlineColor = outlineColor
        textOutline.outlineWidth = outlineWidth
        textOutline.text = self.text
        textOutline.textColor = self.textColor
        textOutline.font = self.font
        textOutline.textAlignment = self.textAlignment
        textOutline.numberOfLines = self.numberOfLines
        textOutline.lineBreakMode = self.lineBreakMode
        textOutline.adjustsFontSizeToFitWidth = self.adjustsFontSizeToFitWidth
        textOutline.minimumScaleFactor = self.minimumScaleFactor
        textOutline.tag = outlineTag
        textOutline.backgroundColor = .clear
        textOutline.clipsToBounds = false
        textOutline.isUserInteractionEnabled = false

        // Make the frame exactly match self.bounds
        textOutline.frame = self.bounds
        textOutline.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Add behind the main label's text
        insertSubview(textOutline, at: 0)
    }

}

