//
//  GuidelineTipApiViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 05/09/24.
//

import Foundation

class GuidelineTipApiViewModel {
    
    var arrayGuidelinesTip: [Res_GuidelineTips] = []
    var arrayOfFilteredGuideline: [Res_GuidelineTips] = []
    var fethcedSuccessfully:(() -> Void)?
    
    public func setupSearchBar(for search_Bar: UISearchBar) {
        search_Bar.placeholder = R.string.localizable.search()
        search_Bar.barTintColor = UIColor.white
        search_Bar.searchTextField.backgroundColor = UIColor.white
        search_Bar.searchTextField.textColor = UIColor.black
        search_Bar.searchTextField.font = UIFont(name: "Avenir-Medium", size: 12)
        
        if let clearButton = search_Bar.searchTextField.value(forKey: "_clearButton") as? UIButton {
            clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        }
        
        search_Bar.layer.cornerRadius = 10
        search_Bar.layer.masksToBounds = true
    }
    
    func fetchGuidelineTips(vC: UIViewController)
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject
        paramDict["cat_id"] = "" as AnyObject
        paramDict["sub_cat_id"] = "" as AnyObject
        paramDict["child_sub_cat_id"] = "" as AnyObject
        
        print(paramDict)
        
        Api.shared.requestGuidelineTips(vC, paramDict) { [weak self] responseData in
            guard let self = self else { return }
            if responseData.status == "1" {
                if let res = responseData.result {
                    if res.count > 0 {
                        self.arrayGuidelinesTip = res
                        self.arrayOfFilteredGuideline = res
                    }
                }
            } else {
                self.arrayGuidelinesTip = []
                self.arrayOfFilteredGuideline = []
            }
            self.fethcedSuccessfully?()
        }
    }
    
    func navigateToGuidlineViewController(from navigationController: UINavigationController?,title: String, dateTime: String, description: String, image: String, isFrom: String, titleArabic: String, descriptionArabic: String) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GuidelinesVC") as! GuidelinesVC
        if L102Language.currentAppleLanguage() == "en" {
            vC.titleVal = title
            vC.dateTime = dateTime
            vC.descriptionVal = description
            vC.placeImg = image
            vC.isFrom = isFrom
        } else {
            vC.titleVal = titleArabic
            vC.dateTime = dateTime
            vC.descriptionVal = descriptionArabic
            vC.placeImg = image
            vC.isFrom = isFrom
        }
        navigationController?.pushViewController(vC, animated: true)
    }
}
