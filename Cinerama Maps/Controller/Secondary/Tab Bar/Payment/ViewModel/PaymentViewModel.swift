//
//  PaymentViewModel.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 15/11/24.
//

import Foundation
import InputMask
import SwiftyJSON
import PassKit

class PaymentViewModel {
    
    var cardHolderName:String = ""
    var cardHolderNumber:String = ""
    var cvc:String = ""
    var month:String = ""
    var year:String = ""
    var total_Amount:String = ""
    
    var countryMapiD:String = ""
    var countryCityiD:String = ""
    var transactionId:String = ""
    
    var offerApplyStatus:Bool = false
    var offerCode:String = ""
    var offeriD:String = ""
    
    var errorMessage: String? {
        didSet {
            self.showErrorMessage?()
        }
    }
    
    var showErrorMessage: (() -> Void)?
    var redirectToPayment: ((String) -> Void)?
    var planPurchasefetchedSuccessfully:(() -> Void)?
    
    func isValidUserInput() -> Bool
    {
        if cardHolderName.isEmpty {
            errorMessage = R.string.localizable.pleaseEnterTheName()
            return false
        } else if cardHolderNumber.isEmpty {
            errorMessage = R.string.localizable.pleaseEnterTheCardNumber()
            return false
        } else if cvc.isEmpty {
            errorMessage = R.string.localizable.pleaseEnterTheCvcNumber()
            return false
        } else if month.isEmpty && year.isEmpty {
            errorMessage = R.string.localizable.pleaseEnterTheMonthAndYear()
            return false
        }
        return true
    }
    
    func configureListener(listnerCardNum: MaskedTextFieldDelegate, listerExpiryDate: MaskedTextFieldDelegate)
    {
        listnerCardNum.affinityCalculationStrategy = .prefix
        listnerCardNum.affineFormats = ["[0000] [0000] [0000] [0000]"]
        
        listerExpiryDate.affinityCalculationStrategy = .prefix
        listerExpiryDate.affineFormats = ["[00]/[00]"]
    }
    
    func callAddPaymentRequest(vC: UIViewController)
    {
        guard isValidUserInput() else { return }
        
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        paramDict["payment_method"] = "Card" as AnyObject
        paramDict["currency"] = (CurrencyHandler.shared.selectedCurrency?["currencyCode"].stringValue ?? "SAR") as AnyObject
        paramDict["transaction_type"] = "Top Up" as AnyObject
        paramDict["type"] = "creditcard" as AnyObject
        paramDict["name"] = cardHolderName as AnyObject
        paramDict["number"] = cardHolderNumber as AnyObject
        paramDict["cvc"] = cvc as AnyObject
        paramDict["month"] = month as AnyObject
        paramDict["year"] = year as AnyObject
        paramDict["total_amount"] = total_Amount as AnyObject
        
        print(paramDict)
        
        Api.shared.requestToAddPayment(vC, paramDict) { [self] responseData in
            self.parseDataSaveCard(apiResponse: responseData, vC: vC)
        }
    }
    
    func parseDataSaveCard(apiResponse : AnyObject, vC: UIViewController) {
        DispatchQueue.main.async { [self] in
            let swiftyJsonVar = JSON(apiResponse)
            print(swiftyJsonVar)
            let status = swiftyJsonVar["result"]["status"]
            if( status == "initiated") {
                self.transactionId = swiftyJsonVar["result"]["id"].stringValue
                let transactionURL = swiftyJsonVar["result"]["source"]["transaction_url"].stringValue
                print(transactionURL)
                //TODO: add a webview to load the payment URL
                redirectToPayment?(transactionURL)
              //  self.requestForFinalPayment(vC: vC, planiD: swiftyJsonVar["result"]["id"].stringValue)
            } else {
                self.errorMessage = swiftyJsonVar["result"]["source"]["message"].stringValue
            }
            vC.unBlockUi()
        }
    }
    
    func verifyPayment(vc: UIViewController) {
        DispatchQueue.main.async {  vc.showProgressBar() }
        var paramDict: [String : Any] = [:]
        paramDict["payment_id"] = transactionId
        
        Api.shared.reuestForPaymentVerification(param: paramDict) { success in
            if success {
                self.requestForFinalPayment(vC: vc)
            } else {
                DispatchQueue.main.async {  vc.hideProgressBar() }
                self.showErrorMessage?()
            }
        }
    }
    
    func requestForFinalPayment(vC: UIViewController)
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = k.userDefault.value(forKey: k.session.userId) as AnyObject?
        paramDict["plan_id"] = self.countryCityiD as AnyObject
        paramDict["amount"] = total_Amount as AnyObject
        
        paramDict["map_country_id"] = countryMapiD as AnyObject
        paramDict["map_city_id"] = countryCityiD as AnyObject
        paramDict["transaction_id"] = transactionId as AnyObject
        paramDict["currency"] = (CurrencyHandler.shared.selectedCurrency?["currencyCode"].stringValue ?? "SAR") as AnyObject
        
        if offerApplyStatus {
            paramDict["offer_code"] = offerCode as AnyObject
            paramDict["offer_id"] = offeriD as AnyObject
        } else {
            paramDict["offer_code"] = k.emptyString as AnyObject
            paramDict["offer_id"] = k.emptyString as AnyObject
        }
        
        print(paramDict)
        
        Api.shared.requestToPurchasePlan(vC, paramDict) { responseData in
            DispatchQueue.main.async {  vC.hideProgressBar() }
            self.planPurchasefetchedSuccessfully?()
        }
    }
}

