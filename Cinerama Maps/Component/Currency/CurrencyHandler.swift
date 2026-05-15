import Foundation
import SwiftyJSON

final class CurrencyHandler {
    static let shared = CurrencyHandler()
    
    var currencies: [JSON] = []
    var selectedCurrency: JSON?
    
    private init() { }
    
//    func fetchCurrenciesFromJsonFile() {
//        let locale: NSLocale = NSLocale.current as NSLocale
//        let country = locale.countryCode
//        
//        if let jsonData = Bundle.main.url(forResource: "Currency", withExtension: "json"),
//           let data = try? Data(contentsOf: jsonData),
//           
//            let json =  try? JSON(data: data, options: .fragmentsAllowed) {
//            self.currencies = json.arrayValue
//            
//            self.selectedCurrency = self.currencies.first(where: { $0["countryCode"].stringValue == country?.uppercased()})
//            if self.selectedCurrency == nil {
//                self.selectedCurrency = self.currencies.first(where: { $0["countryCode"].stringValue == "SA"})
//            }
//        }
//    }
  
    func fetchCurrenciesFromJsonFile() {
        let locale: NSLocale = NSLocale.current as NSLocale
        let country = locale.countryCode
        
        if let jsonData = Bundle.main.url(forResource: "Currency", withExtension: "json"),
           let data = try? Data(contentsOf: jsonData),
           let json = try? JSON(data: data, options: .fragmentsAllowed) {
            
            self.currencies = json.arrayValue
            
            self.selectedCurrency = self.currencies.first(where: {
                $0["countryCode"].stringValue == country?.uppercased()
            })
            
            if self.selectedCurrency == nil {
                self.selectedCurrency = self.currencies.first(where: {
                    $0["countryCode"].stringValue == "SA"
                })
            }
            
            // ✅ Debug: print the selected currency to confirm key names
            print("🌍 Selected Currency JSON: \(self.selectedCurrency ?? JSON.null)")
        }
    }

    func fetchCurrentCurrencyRate(code: String, completion: @escaping (Double) ->Void ) {
        Api.shared.reuestForCurrencyRate(code: code, completion: completion)
    }
}
