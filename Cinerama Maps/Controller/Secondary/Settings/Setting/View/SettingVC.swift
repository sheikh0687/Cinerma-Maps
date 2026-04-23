//
//  SettingVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 23/08/24.
//

import UIKit

class SettingVC: UIViewController {

    @IBOutlet weak var profile_Img: UIImageView!
    @IBOutlet weak var lbl_UserName: UILabel!
    
    let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        fetchProfileDetail()
    }
    
    private func fetchProfileDetail()
    {
        viewModel.fetchUserProfileDetails(vC: self)
        viewModel.fetchSuccessfully = { [] in
            DispatchQueue.main.async { [self] in
                let obj = self.viewModel.arrayUserProfile
                self.lbl_UserName.text = "\(obj?.first_name ?? "") \(obj?.last_name ?? "")"
                
                if Router.BASE_IMAGE_URL != obj?.image {
                    Utility.setImageWithSDWebImage(obj?.image ?? "", self.profile_Img)
                } else {
                    self.profile_Img.image = R.image.profile_ic()
                }
            }
        }
    }
    
    @IBAction func btn_Back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_EditProfile(_ sender: UIButton) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupVC") as! SignupVC
        vC.isFrom = "Profile"
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_TermsCondition(_ sender: UIButton) {
        if sender.tag == 0 {
            let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Policy_sVC") as! Policy_sVC
            vC.isFrom = "AboutUS"
            self.navigationController?.pushViewController(vC, animated: true)
        } else if sender.tag == 1 {
            let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Policy_sVC") as! Policy_sVC
            vC.isFrom = "TermCondition"
            self.navigationController?.pushViewController(vC, animated: true)
        } else {
            let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Policy_sVC") as! Policy_sVC
            vC.isFrom = "Policy"
            self.navigationController?.pushViewController(vC, animated: true)
        }
    }
    
    @IBAction func btn_Subscription(_ sender: UIButton) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_ChangeLanguage(_ sender: UIButton) {
        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LanguageVC") as! LanguageVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Application(_ sender: UIButton) {
        Utility.doShare("https://apps.apple.com/us/app/anytime-work/id1576680333", "Please install this application from Apple Store link", self)
    }
    
    @IBAction func btn_ContactUs(_ sender: UIButton) {
//        let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
//        self.navigationController?.pushViewController(vC, animated: true)
        Utility.openWhatsApp(number: "966582456792")
    }
    
    @IBAction func btn_DeleteAccnt(_ sender: UIButton) {
       
    }
    
    @IBAction func btn_Socials(_ sender: UIButton) {
        if sender.tag == 0 {
            Utility.openAnyUrl(Url: "https://www.instagram.com/cineramamaps/")
        } else if sender.tag == 1 {
            Utility.openAnyUrl(Url: "https://www.tiktok.com/@cineramamaps")
        } else if sender.tag == 2 {
            Utility.openAnyUrl(Url: "https://www.snapchat.com/add/cineramamaps?invite_id=5-f0rPyl&locale=en_SA%40calendar%3Dgregorian&share_id=dklrrBY6Sty1jg1nSK544A&sid=96dba25ac24e427a9251e17b20126cea")
        } else {
            Utility.openAnyUrl(Url: "https://x.com/i/flow/login?redirect_after_login=%2Fcineramamaps")
        }
    }
    
    @IBAction func btn_Logout(_ sender: UIButton) {
        isLogout = true
        UserDefaults.standard.removeObject(forKey: k.session.status)
        UserDefaults.standard.synchronize()
        Switcher.updateRootVC()
    }
}
