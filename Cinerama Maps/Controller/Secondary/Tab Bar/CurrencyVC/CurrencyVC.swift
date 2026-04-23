import UIKit
import SwiftyJSON

final class CurrencyVC: UIViewController {
    
    @IBOutlet weak var currencyTableView: UITableView!
    
    @IBOutlet weak var btnBackground: UIButton!
    
    var selectedCurrency: ((JSON) -> Void)?
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        btnBackground.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        currencyTableView.layer.cornerRadius = 5.0
        self.view.backgroundColor = .clear
        currencyTableView.delegate = self
        currencyTableView.dataSource = self
        selectedIndex = CurrencyHandler.shared.currencies.firstIndex(where: { $0["currencyCode"].stringValue == CurrencyHandler.shared.selectedCurrency?["currencyCode"].stringValue} ) ?? 0
        
    }
    
    @IBAction func dismissCurrencyPopup(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
}

extension CurrencyVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return CurrencyHandler.shared.currencies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyCell
        let currency = CurrencyHandler.shared.currencies[indexPath.row]
        print(currency)
        cell.currencyLabel?.text = currency["currencyCode"].stringValue
        Utility.setImageWithSDWebImage(currency["flagUrl"].stringValue, cell.countryFlag)
        
        cell.radioImage.image = selectedIndex == indexPath.row ? UIImage(named: "ic_CheckedCircle_Black") : UIImage(named: "ic_Circle_Black")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = CurrencyHandler.shared.currencies[indexPath.row]
        selectedCurrency?(currency)
        dismissCurrencyPopup(0)
    }
}
