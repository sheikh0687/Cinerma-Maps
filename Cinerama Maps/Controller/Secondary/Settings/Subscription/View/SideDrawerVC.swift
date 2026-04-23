//
//  SideDrawerVC.swift
//  Cinerama Maps
//
//  Created by Muhammad Farooq on 05/05/2025.
//

import UIKit

class SideDrawerVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var drawerMainView: UIView!
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    weak var navController: UINavigationController?
    @IBOutlet weak var tagTableView: UITableView!
    var tags: [Tag_details] = []
    var onTagSelected: ((String?) -> Void)? // Getting The Same Tag on Map
    var favoriteTags: [Place_details] = []
    var openPlaceDetail: ((Place_details)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagTableView.register(UINib(nibName: "TableTagsCell", bundle: nil), forCellReuseIdentifier: "TableTagsCell")
       
                tagTableView.dataSource = self
                tagTableView.delegate = self
                tagTableView.reloadData()
        topLayout.constant = 60
        drawerMainView.frame.origin.x = 0

        // Animate drawer sliding in
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.x = self.drawerMainView.frame.width
        }
        
        

//        // Tap anywhere outside drawerMainView to dismiss
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
//        tap.cancelsTouchesInView = false
//        self.view.addGestureRecognizer(tap)
    }
    
    @IBAction func actCancel(_ sender: UIButton) {
        dismissSelf()
    }
    
    @objc func dismissSelf() {
        let isRTL = UIView.userInterfaceLayoutDirection(for: self.view.semanticContentAttribute) == .rightToLeft
        let screenWidth = UIScreen.main.bounds.width

        UIView.animate(withDuration: 0.3, animations: {
            if isRTL {
                // Slide off to the right
                self.view.frame.origin.x = screenWidth
            } else {
                // Slide off to the left
                self.view.frame.origin.x = -self.drawerMainView.frame.width
            }
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case 1:
            return tags.count
        default:
            return 0
            
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableTagsCell", for: indexPath) as! TableTagsCell
        switch indexPath.section {
        case 0:
            let tag = favoriteTags[indexPath.row]
            cell.tag_lbl_name.text = L102Language.currentAppleLanguage() == "ar" ? tag.place_name_ar : tag.place_name
            cell.badgeLabel.text = "\(tag.favoriteCount ?? 1)"
            cell.badgeView.layer.cornerRadius = cell.badgeView.frame.height / 2
            cell.tag_lbl_name.textColor = .black
            cell.badgeView.backgroundColor = .gray.withAlphaComponent(0.2)
        default:
            let tag = tags[indexPath.row]
            cell.tag_lbl_name.text = L102Language.currentAppleLanguage() == "ar" ? tag.tag_name_ar : tag.tag_name
            cell.badgeLabel.text = tag.total_tag_place_count
            cell.badgeLabel.textColor = .white
            cell.badgeView.layer.cornerRadius = cell.badgeView.frame.height / 2
            cell.tag_lbl_name.textColor = UIColor.hexStringToUIColor(hex: tag.color_code ?? "")
            cell.badgeView.backgroundColor = UIColor.hexStringToUIColor(hex: tag.color_code ?? "")
        }
        return cell
    }
    // Getting The Same Tag on Map
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            openPlaceDetail?(favoriteTags[indexPath.row])
            dismissSelf()
        default:
            let selectedTag: Tag_details = tags[indexPath.row]
            let selectedTagId = selectedTag.id ?? ""
            onTagSelected?(selectedTagId)
            dismissSelf()
        }
    }
    // ends

    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
 
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = Bundle.main.loadNibNamed("PlacesHeader", owner: self, options: nil)?.first as? PlacesHeader else {
                return nil
            }
        switch section {
        case 0:
            headerView.imgHeart.isHidden = false
            headerView.imgWidth.constant = 28
            headerView.lblName.text = R.string.localizable.favourite_Places()
         
        default:
            headerView.imgHeart.isHidden = true
            headerView.imgWidth.constant = 0
            headerView.lblName.text = R.string.localizable.tags()
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
            headerView.addGestureRecognizer(tapGesture)
            headerView.tag = section
            return headerView
        }
        
        @objc func headerTapped(_ sender: UITapGestureRecognizer) {
            guard let section = sender.view?.tag else { return }
            
            if section == 0 {
                onTagSelected?("favorites")
            }
            else if section == 1 {
               onTagSelected?(nil)
           }
            dismissSelf()
        }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        36
    }
}
