//
//  SetupScheduleVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 23/08/24.
//

import UIKit

class PlaceTableVC: UIViewController {
    
    @IBOutlet weak var txt_MapName: UITextField!
    @IBOutlet weak var btn_MapTypeDrop: UIButton!
    @IBOutlet weak var txt_HowManyDays: UITextField!
    @IBOutlet weak var txt_Address: UITextView!
    @IBOutlet weak var btn_ByCNRMOt: UIButton!
    @IBOutlet weak var btn_CreateAndUpdate: UIButton!
    
    @IBOutlet weak var btn_MapNameDrop: UIButton!
    @IBOutlet weak var btn_NumberOfDayDrop: UIButton!
    @IBOutlet weak var addPlaceVw: UIView!
    
    var viewModel: PlaceTableViewModel
    var addTripVM: AddTripViewModel
    var byCNRM:String = ""
    
    var address:String! = ""
    var lat = 0.0
    var lon = 0.0
    
    init(viewModel: PlaceTableViewModel, addTripVM:AddTripViewModel) {
        self.viewModel = viewModel
        self.addTripVM = addTripVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        // Provide a default ViewModel to avoid crash
        self.viewModel = PlaceTableViewModel()
        self.addTripVM = AddTripViewModel()// Replace with proper default if needed
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(address_Picker))
        txt_Address.isUserInteractionEnabled = true
        txt_Address.addGestureRecognizer(tapGesture1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBinding()
        setupDaysName()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.uiDependOn == "GoogleEdit" {
            self.btn_MapTypeDrop.setTitle(addTripVM.mapType, for: .normal)
            self.txt_MapName.text = addTripVM.trip_Name
            self.setAddTrip()
        } else {
            self.addPlaceVw.isHidden = true
            setupDetailBinding()
            self.setAddTrip()
        }
    }
    
    @objc func address_Picker()
    {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddressPickerVC") as! AddressPickerVC
        vc.locationPickedBlock = {(addressCordinate, latVal, lonVal, addressVal) in
            self.txt_Address.text = addressVal
            self.address = addressVal
            self.lat = latVal
            self.lon = lonVal
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btn_Back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_ConfirmTripByCNRM(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            sender.setImage(R.image.rectangleUncheck(), for: .normal)
            byCNRM = "No"
        } else {
            sender.isSelected = true
            sender.setImage(R.image.rectangleChecked(), for: .normal)
            byCNRM = "Yes"
        }
    }
    
    @IBAction func btn_MapType(_ sender: UIButton) {
//        viewModel.dropDown.show()
    }
    
    @IBAction func btn_MapName(_ sender: UIButton) {
        viewModel.dropDownMapName.show()
    }
    
    @IBAction func btn_NumberOfDays(_ sender: UIButton) {
        viewModel.dropDownDays.show()
    }
    
    @IBAction func btn_AddMapName(_ sender: UIButton) {
        viewModel.navigateToTripScheduleViewController(from: self.navigationController)
    }
    
    private func setupBinding()
    {
        viewModel.fetchScheduleTripMapName(vC: self, addPlaceVw: addPlaceVw)
        viewModel.fetchedSuccessfully = { [] in
            print("Data Fetched Successfully!")
            self.viewModel.configureDropDownForMapName(sender: self.btn_MapNameDrop)
        }
    }
    
    private func setupDaysName()
    {
        viewModel.fetchNumberOfDays(vC: self)
        viewModel.fetchedDayNameSuccessfully = { [self] in
            self.viewModel.configureDropDownForDaySelection(sender: self.btn_NumberOfDayDrop)
        }
    }
    
    private func setupDetailBinding()
    {
        viewModel.fetchDetailScheduleTrip(vC: self)
        viewModel.fetchedSuccessfully = { [self] in
            let obj = self.viewModel.arrayOfDetailTrip
            
            self.btn_MapTypeDrop.setTitle(L102Language.currentAppleLanguage() == "en" ? obj?.map_type ?? "" : obj?.map_type_ar ?? "", for: .normal)
            self.btn_MapNameDrop.setTitle(obj?.table_map_name ?? "", for: .normal)
            self.btn_NumberOfDayDrop.setTitle(obj?.day_name ?? "", for: .normal)
            
            self.txt_MapName.text = obj?.trip_name
//            self.addTripVM.map_Name = obj?.table_map_name ?? ""
            
            if let table_map_name = obj?.table_map_name {
                viewModel.mapType = table_map_name
            }
            
            self.viewModel.dayName = obj?.day_name ?? ""
            self.viewModel.dayiD = obj?.day_id ?? ""
            self.viewModel.dayNameAr = obj?.day_name_ar ?? ""
            
            self.addTripVM.location = obj?.address ?? ""
            self.addTripVM.valLat = Double(obj?.lat ?? "") ?? 0.0
            self.addTripVM.valLon = Double(obj?.lon ?? "") ?? 0.0
            
            self.addTripVM.mapType = obj?.map_type ?? ""
            self.addTripVM.map_TypeAr = obj?.map_type_ar ?? ""
            
            self.addTripVM.place_iD = obj?.place_id ?? ""
            
            self.addTripVM.country_Id = obj?.country_id ?? ""
            self.addTripVM.country_Name = obj?.country_name ?? ""
            self.addTripVM.country_NameAr = obj?.country_name_ar ?? ""
            
            self.addTripVM.trip_PlaceiD = obj?.trip_place_id ?? ""
            self.addTripVM.map_PlaceiD = obj?.map_place_id ?? ""
            
            self.addTripVM.trip_iD = obj?.id ?? ""
            self.addTripVM.trip_Name = obj?.trip_name ?? ""
            self.addTripVM.trip_NameAr = obj?.trip_name_ar ?? ""
            
            if obj?.trip_by_cineramap == "Yes" {
                self.btn_ByCNRMOt.setImage(R.image.rectangleChecked(), for: .normal)
            } else {
                self.btn_ByCNRMOt.setImage(R.image.rectangleUncheck(), for: .normal)
            }
        }
    }
    
    @IBAction func btn_Save(_ sender: UIButton) {
        addTripVM.table_map_name = viewModel.mapType
        addTripVM.day_Id = viewModel.dayiD
        addTripVM.day_Name = viewModel.dayName
        addTripVM.day_NameAr = viewModel.dayNameAr
        addTripVM.isCNRM = self.byCNRM
        addTripVM.addNewTrip(vC: self)
    }
    
    private func setAddTrip()
    {
        addTripVM.showErrorMessage = { [weak self] in
            if let errorMessage = self?.addTripVM.errorMessage {
                Utility.showAlertMessage(withTitle: k.appName, message: errorMessage, delegate: nil, parentViewController: self!)
            }
        }
        
        addTripVM.addedSuccessfully = { [self] in
            if addTripVM.isFrom == "GoogleEdit" {
                Utility.showAlertWithAction(withTitle: k.appName, message: R.string.localizable.tripAddedSuccessfully(), delegate: nil, parentViewController: self) { bool in
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                Utility.showAlertWithAction(withTitle: k.appName, message: R.string.localizable.tripUpdatedSuccessfully(), delegate: nil, parentViewController: self) { bool in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
