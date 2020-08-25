//
//  PeopleViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI

class PeopleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .myBackgroundColor()
        setupNavigationController()
    }
    
    private func setupNavigationController(){
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .myBackgroundColor()
        navigationItem.title = "People"
        
        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}


//MARK: -UISearchBarDelegate
extension PeopleViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}

//MARK:- SwiftUI

struct PeopleViewControllerProvider: PreviewProvider {
    
    static var previews: some View {
        ContenerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContenerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: Context) -> MainTabBarController {
            MainTabBarController()
        }
        
        func updateUIViewController(_ uiViewController: MainTabBarController, context: Context) {
            
        }
    }
}
