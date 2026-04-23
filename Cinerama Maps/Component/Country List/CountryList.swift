//
//  CountryListTableViewController.swift
//  CountryListExample
//
//  Created by Juan Pablo on 9/8/17.
//  Copyright © 2017 Juan Pablo Fernandez. All rights reserved.
//

import UIKit

public protocol CountryListDelegate: AnyObject {
    func selectedCountry(country: Country)
}

public class CountryList: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    var tableView: UITableView!
    var searchController: UISearchController?
    
    var filteredCountries: [Country] = []
    weak var delegate: CountryListDelegate?
    private let countryList: [Country] = Countries.shared
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Set title appropriately
        self.title = L102Language.currentAppleLanguage() == "ar" ? "قائمة الدول" : "Country List"
        self.view.backgroundColor = .white
        
        tableView = UITableView(frame: view.bounds)
        tableView.register(CountryCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = UIColor.clear
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.tableFooterView = UIView()
        
        self.view.addSubview(tableView)
        
        self.definesPresentationContext = true
        self.extendedLayoutIncludesOpaqueBars = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ✅ Ensure navigation bar is visible
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setUpSearchBar()
    }
    
    // MARK: - UISearchResultsUpdating
    public func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased(), !text.isEmpty else {
            filteredCountries.removeAll()
            tableView.reloadData()
            return
        }
        
        filteredCountries = countryList.filter { $0.name?.lowercased().contains(text) ?? false }
        tableView.reloadData()
    }
    
    private func setUpSearchBar() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.obscuresBackgroundDuringPresentation = false
        
        // Localize placeholder
        let placeholder = L102Language.currentAppleLanguage() == "ar" ? "بحث" : "Search"
        
        self.searchController?.searchBar.placeholder = placeholder
        self.navigationItem.searchController = self.searchController
        self.definesPresentationContext = true
        
        // Set searchBar direction
        if Locale.characterDirection(forLanguage: Locale.preferredLanguages.first ?? "en") == .rightToLeft {
            self.searchController?.searchBar.semanticContentAttribute = .forceRightToLeft
        } else {
            self.searchController?.searchBar.semanticContentAttribute = .forceLeftToRight
        }
    }
    
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchController = searchController, searchController.isActive,
           !(searchController.searchBar.text?.isEmpty ?? true) {
            return filteredCountries.count
        }
        return countryList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CountryCell
        if let searchController = searchController, searchController.isActive,
           !(searchController.searchBar.text?.isEmpty ?? true) {
            cell.country = filteredCountries[indexPath.row]
        } else {
            cell.country = countryList[indexPath.row]
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country: Country
        if let searchController = searchController, searchController.isActive,
           !(searchController.searchBar.text?.isEmpty ?? true) {
            country = filteredCountries[indexPath.row]
        } else {
            country = countryList[indexPath.row]
        }
        
        self.searchController?.isActive = false
        delegate?.selectedCountry(country: country)
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
