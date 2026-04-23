//
//  TabBarVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 22/08/24.
//

import UIKit
import SwiftyJSON

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        tabBar.tintColor = R.color.main()                // selected icon color
        tabBar.unselectedItemTintColor = .darkGray // unselected icon color

        setupTabBarIcons()
    }
    
    private func setupTabBarIcons() {
        guard let viewControllers = self.viewControllers, viewControllers.count >= 4 else { return }

        let targetSize = CGSize(width: 24, height: 24)

        let homeImage = resizeImage(image: UIImage(named: "Home26")!, targetSize: targetSize)
        let mapsImage = resizeImage(image: UIImage(named: "Map26")!, targetSize: targetSize)
        let offersImage = resizeImage(image: UIImage(named: "Offer26")!, targetSize: targetSize)
        let favImage = resizeImage(image: UIImage(named: "Fav26")!, targetSize: targetSize)

        viewControllers[0].tabBarItem.image = homeImage.withRenderingMode(.alwaysTemplate)
        viewControllers[1].tabBarItem.image = mapsImage.withRenderingMode(.alwaysTemplate)
        viewControllers[2].tabBarItem.image = offersImage.withRenderingMode(.alwaysTemplate)
        viewControllers[3].tabBarItem.image = favImage.withRenderingMode(.alwaysTemplate)
        
        viewControllers[0].tabBarItem.image = homeImage.withRenderingMode(.alwaysOriginal)
        viewControllers[1].tabBarItem.image = mapsImage.withRenderingMode(.alwaysOriginal)
        viewControllers[2].tabBarItem.image = offersImage.withRenderingMode(.alwaysOriginal)
        viewControllers[3].tabBarItem.image = favImage.withRenderingMode(.alwaysOriginal)

        // Optional: Adjust image insets if needed (vertically center the icon)
//        for vc in viewControllers {
//            vc.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = CGSize(width: size.width * widthRatio, height: size.height * heightRatio)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
//    private func updateTabBarTitles() {
//        // Assuming tab at index 1 is the one you want to update
//        if let viewControllers = self.viewControllers {
//            let vC0 = viewControllers[0]
//            let vC1 = viewControllers[1]
//            let vC2 = viewControllers[2]
//            let vC3 = viewControllers[3]
//            
//            // Check the current language and update the title accordingly
//            if LanguageManager.shared.currentLanguage == .en {
//                vC0.tabBarItem.title = "Home"
//                vC1.tabBarItem.title = "Maps"
//                vC2.tabBarItem.title = "Offers"
//                vC3.tabBarItem.title = "Favorites"
//            } else {
//                vC0.tabBarItem.title = "الرئيسية"
//                vC1.tabBarItem.title = "الخرائط"
//                vC2.tabBarItem.title = "العروض"
//                vC3.tabBarItem.title = "المفضلة"
//            }
//        }
//    }
}
