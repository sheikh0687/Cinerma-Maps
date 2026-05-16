//
//  PaymentVC.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 28/08/24.
//

import UIKit
import InputMask
import PassKit
import SwiftyJSON
import BenefitPay_iOS
import CryptoKit

class PaymentVC: UIViewController {
    
    @IBOutlet weak var paymentWithTapView: UIView!
    @IBOutlet weak var cardInfoView: UIView!
    
    @IBOutlet weak var btnPaymentWithTapPaymentGateway: UIButton!
    
    @IBOutlet weak var lbl_Type:UILabel!
    @IBOutlet weak var lbl_TotalDuration:UILabel!
    @IBOutlet weak var lbl_totalAmount:UILabel!
    @IBOutlet weak var lbl_DiscountAmount: UILabel!
    
    @IBOutlet weak var txtCardHolderName: UITextField!
    @IBOutlet weak var txtCardNumber: UITextField!
    @IBOutlet weak var txtExpiryDate: UITextField!
    @IBOutlet weak var txtSecurityCode: UITextField!
    @IBOutlet weak var txt_PromoCode: UITextField!
    
    @IBOutlet var listnerCardNum: MaskedTextFieldDelegate!
    @IBOutlet var listerExpiryDate: MaskedTextFieldDelegate!
    
    let viewModel: PaymentViewModel
    let ApplePaySwagMerchantID = "merchant.Main.CineramaMap"
    
    var typeVal: String = ""
    var duration: String = ""
    var totalPaidAmount: Double = 0
    var totalPaidAmountInUSD: Double = 0
    var amount: Double = 0
    var discount_Amount: Double = 0
    var strOfferiD:String = ""
    
    var currencyCode: String {
        let json = CurrencyHandler.shared.selectedCurrency ?? JSON([:])
        let currencyCode = json["currencyCode"].stringValue
        return currencyCode
    }
    
    init(viewModel: PaymentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        // Provide a default ViewModel to avoid crash
        self.viewModel = PaymentViewModel()  // Replace with proper default if needed
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amount = totalPaidAmount
        self.viewModel.configureListener(listnerCardNum: listnerCardNum, listerExpiryDate: listerExpiryDate)
        bindViewModel()
        self.lbl_Type.text = typeVal
        self.lbl_TotalDuration.text = "\(self.duration) \(R.string.localizable.month())"
        
        self.lbl_totalAmount.text = "\(currencyCode) \(self.totalPaidAmount)"
        self.lbl_DiscountAmount.text = "\(currencyCode) \(self.totalPaidAmount)"
        self.cardInfoView.isHidden = true
        self.paymentWithTapView.isHidden = false
    }
    
    @IBAction func btn_Back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func bindViewModel()
    {
        viewModel.showErrorMessage = { [weak self] in
            if let errorMessage = self?.viewModel.errorMessage {
                Utility.showAlertMessage(withTitle: k.appName, message: errorMessage, delegate: nil, parentViewController: self!)
            }
        }
        
        viewModel.planPurchasefetchedSuccessfully = { [self] in
            let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PresentPopUpVC") as! PresentPopUpVC
            vC.modalTransitionStyle = .crossDissolve
            vC.modalPresentationStyle = .overFullScreen
            self.present(vC, animated: true)
        }
        
        /// callback to redirect user to payment gateway
        viewModel.redirectToPayment = { [weak self] url in
            guard let self = self else { return }
            let vC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentWebview") as! PaymentWebview
            vC.setURL(url)
            vC.paymentCompletion = { [weak self] success, istapPayment in
                
                guard let self = self else { return }
                if istapPayment {
                    if success {
                        self.viewModel.transactionId = UUID().uuidString
                        self.viewModel.requestForFinalPayment(vC: self)
                    } else {
                        viewModel.showErrorMessage?()
                    }
                } else {
                    viewModel.offerCode = self.txt_PromoCode.text ?? ""
                    viewModel.offeriD = self.strOfferiD

                    viewModel.verifyPayment(vc: self)
                }
            }
            self.navigationController?.pushViewController(vC, animated: true)
        }
    }
    
    @IBAction func btnPayWithTapPaymentGateway(_ sender: UIButton) {
        let orderId = viewModel.countryCityiD
        let firstName  = k.userDefault.string(forKey: k.session.firstName) ?? ""
        let lastName  = k.userDefault.string(forKey: k.session.lastName) ?? ""
        let email  = k.userDefault.string(forKey: k.session.userEmail) ?? ""
        let currency  = self.currencyCode
        let lang = L102Language.currentAppleLanguage()
        
        let url = Router.paymentWithTapPaymentGateway.url() + "?order_id=\(orderId)&first_name=\(firstName)&last_name=\(lastName)&email=\(email)&amount=\(viewModel.offerApplyStatus == true ? discount_Amount : totalPaidAmount)&currency=\(currency)&lang=\(lang)&usd_amount=\(totalPaidAmountInUSD)"
        
        print("Payment with tap gateway URL: \(url)")
        
        viewModel.redirectToPayment?(url)
    }
    
    @IBAction func btn_Apply(_ sender: UIButton) {
        if self.txt_PromoCode.hasText {
            addOffers()
        } else {
            self.alert(alertmessage: R.string.localizable.pleaseEnterThePromoCode())
        }
    }
    
//    @IBAction func btn_Checkoffers(_ sender: UIButton) {
//        let vC = Kstoryboard.instantiateViewController(withIdentifier: "CheckOffersVC") as! CheckOffersVC
//        self.navigationController?.pushViewController(vC, animated: true)
//    }
    
//    @IBAction func btn_Pay(_ sender: UIButton) {
//        viewModel.cardHolderName = self.txtCardHolderName.text ?? ""
//        if let cardNumber = self.txtCardNumber.text {
//            let sanitizedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
//            viewModel.cardHolderNumber = sanitizedCardNumber
//        }
//        viewModel.cvc = self.txtSecurityCode.text ?? ""
//        let expiryDate = self.txtExpiryDate.text ?? ""
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/yy" // Specify the format of the input string
//        
//        if let date = dateFormatter.date(from: expiryDate) {
//            let calendar = Calendar.current
//            let month = calendar.component(.month, from: date)
//            let year = calendar.component(.year, from: date)
//            
//            print("Month: \(month), Year: \(year)") // Output: Month: 12, Year: 2038
//            viewModel.month = String(month)
//            viewModel.year = String(year)
//        }
//        viewModel.total_Amount = "\(totalPaidAmount)"
//        viewModel.callAddPaymentRequest(vC: self)
//    }
    
//    @IBAction func btn_PayWithApple(_ sender: UIButton) {
//        payByApplePay()
//    }
//    
//    func payByApplePay() {
//        viewModel.total_Amount = "\(totalPaidAmount)"
//        let request = PKPaymentRequest()
//        request.merchantIdentifier = ApplePaySwagMerchantID
//        request.merchantCapabilities = PKMerchantCapability.capability3DS
//        request.countryCode = CurrencyHandler.shared.selectedCurrency?["countryCode"].stringValue ?? "SA"
//        request.currencyCode = CurrencyHandler.shared.selectedCurrency?["currencyCode"].stringValue ?? "SAR"
//        request.supportedNetworks = [.amex, .visa, .masterCard, .discover]
//        
//        let paymentItemsss = PKPaymentSummaryItem.init(label: "With Apple", amount: NSDecimalNumber(value: Double(viewModel.total_Amount) ?? 0.0))
//        request.paymentSummaryItems = [paymentItemsss]
//        
//        guard let presentController = PKPaymentAuthorizationViewController(paymentRequest: request) else {
//            self.alert(alertmessage: "Unable to present Apple Pay authorization.")
//            return
//        }
//        presentController.delegate = self
//        self.present(presentController, animated: true, completion: nil)
//    }
}

extension PaymentVC {
    
    func addOffers()
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        paramDict["offer_code"] = self.txt_PromoCode.text as AnyObject
        paramDict["amount"] = totalPaidAmount as AnyObject
        
        print(paramDict)
        
        Api.shared.requestToApplyForOffer(self, paramDict) { responseData in
            debugPrint(responseData)
            if responseData.status == "1" {
                self.viewModel.offerApplyStatus = true
                self.lbl_DiscountAmount.text = "\(self.currencyCode) \(responseData.after_discount?.round() ?? 0)"
                self.discount_Amount = responseData.discount_amount?.round() ?? 0
                print(self.discount_Amount.round())
                self.strOfferiD = responseData.offer_id ?? ""
                self.txt_PromoCode.text = ""
                self.alert(alertmessage: L102Language.currentAppleLanguage() == "en" ? "Promo Code Apply Successfully" : "تم تطبيق الرمز الترويجي بنجاح")
            } else {
                self.viewModel.offerApplyStatus = false
                self.alert(alertmessage: responseData.result ?? "")
            }
        }
    }
}

extension PaymentVC: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        self.dismiss(animated: true, completion: nil)
        let planiD = payment.token.transactionIdentifier
        viewModel.transactionId = planiD
        viewModel.requestForFinalPayment(vC: self)
    }
}
