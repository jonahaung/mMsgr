//
//  MainTabBar+Search.swift
//  mMsgr
//
//  Created by jonahaung on 2/11/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

extension MainTabBarController {
    
    func configureSearchBar() {
        
        let searchResultController = SearchResultsController()
        let searchController = UISearchController(searchResultsController: searchResultController)
    
        let searchBar = searchController.searchBar
        searchBar.textField?.textAlignment = .left
        searchBar.placeholder = "Serch Contacts"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        
        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController = searchController
        
    }
    
}

extension MainTabBarController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchResultController = searchController?.searchResultsController as? SearchResultsController else { return }
        searchResultController.searchText = searchText
    }
}
