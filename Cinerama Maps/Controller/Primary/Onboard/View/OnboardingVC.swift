//
//  OnboardingVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 22/08/24.
//

import UIKit

class OnboardingVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let identifier = "OnboardingCell"
    var currentIndex = 0
//    let collectionRTLLayout = RTLCollectionViewFlowLayout()
    
    var arrayMainHeading =
    [
        R.string.localizable.exploreTheWorldWithCineramaMap(),
        R.string.localizable.makeMemoriesThatWillStayWithYouForever(),
        R.string.localizable.planYourDreamTripWithTourbliss()
    ]
    
    var arraySubHeading =
    [
        R.string.localizable.weAreWithYouEveryStepOfTheWayOnYourJourneyTakingCareOfAllTheDetailsAndProvidingSupportAsYourDigitalTourGuideMeetingYourNeedsAndManagingYourBookings(),
        R.string.localizable.inCineramaThereSNoHiddenSpotForTouristsAllDiscoveredAndImportantPlacesCanBeFoundOnOurMaps(),
        R.string.localizable.yourElectronicTourGuideWeVeCreatedSchedulesOfTheBestPlacesBasedOnYourInterestsWithTheOptionToCreateYourOwnCustomSchedule()
    ]
    
    var arrayImageList =
    [
        R.image.slide1(),
        R.image.slide2(),
        R.image.slide3()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.collectionView.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
        
        let flowLayout = RTLCollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = flowLayout
        
        // Set semantic direction to match language
        if L102Language.currentAppleLanguage() == "ar" {
            self.collectionView.semanticContentAttribute = .forceLeftToRight
        } else {
            self.collectionView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    @IBAction func btnNext(_ sender: UIButton) {
        if self.currentIndex < (self.arrayImageList.count - 1) {
            self.currentIndex += 1
            self.pageControl.currentPage = self.currentIndex
            
            DispatchQueue.main.async {
                self.collectionView.isPagingEnabled = false
                self.collectionView.scrollToItem(at: IndexPath(item: self.currentIndex, section: 0), at: .centeredHorizontally, animated: true
                )
                self.collectionView.isPagingEnabled = true
            }
        } else {
            let vc = Kstoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnSkip(_ sender: UIButton) {
        let vc = Kstoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension OnboardingVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayImageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCell
        cell.img.image = self.arrayImageList[indexPath.row]
        cell.lbl_Main.text = self.arrayMainHeading[indexPath.row]
        cell.lbl_Sub.text = self.arraySubHeading[indexPath.row]
        return cell
    }
}

extension OnboardingVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
}

extension OnboardingVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(indexPath.row)
        self.currentIndex = indexPath.row
        self.pageControl.currentPage = indexPath.row
    }
}
