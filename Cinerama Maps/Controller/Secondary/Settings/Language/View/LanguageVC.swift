//
//  LanguageVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 27/11/24.
//

import UIKit


class LanguageVC: UIViewController {
    
    @IBOutlet weak var eng_Img: UIImageView!
    @IBOutlet weak var arb_Img: UIImageView!
    
    var selected_Language:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if L102Language.currentAppleLanguage() == "en" {
            self.eng_Img.image = R.image.ic_CheckedCircle_Black()
        } else {
            self.arb_Img.image = R.image.ic_CheckedCircle_Black()
        }
    }
    
    @IBAction func btn_back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_English(_ sender: UIButton) {
        self.eng_Img.image = R.image.ic_CheckedCircle_Black()
        self.arb_Img.image = R.image.ic_Circle_Black()
        self.selected_Language = "en"
    }
    
    @IBAction func btn_Arabic(_ sender: UIButton) {
        self.eng_Img.image = R.image.ic_Circle_Black()
        self.arb_Img.image = R.image.ic_CheckedCircle_Black()
        self.selected_Language = "ar"
    }
    
    @IBAction func btn_Save(_ sender: UIButton) {
        switch selected_Language {
        case "en":
            k.userDefault.set(emLang.en.rawValue, forKey: k.session.language)
            L102Language.setAppleLAnguageTo(lang: "en")
            let transition: UIView.AnimationOptions = .transitionFlipFromLeft
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            Switcher.updateRootVC()
        default:
            k.userDefault.set(emLang.ar.rawValue, forKey: k.session.language)
            L102Language.setAppleLAnguageTo(lang: "ar")
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            Switcher.updateRootVC()
        }
    }
}
