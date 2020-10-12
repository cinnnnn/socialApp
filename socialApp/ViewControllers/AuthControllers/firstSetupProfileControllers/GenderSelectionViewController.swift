//
//  GenderSelectionTableViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 11.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth

class GenderSelectionViewController: UIViewController {

    var currentUser: User?
    let tableView = SelectionTableView(elements: MGender.modelStringAllCases,
                                       description: MGender.description,
                                       frame: .zero,
                                       style: .grouped)
    
    //for swiftUI
    init() {super.init(nibName: nil, bundle: nil)}
    
    init(currentUser: User){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        
        view.backgroundColor = .myWhiteColor()
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.backgroundColor = .myWhiteColor()
        
        navigationItem.backButtonTitle = "Выбрать гендер"
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save,
                                                         target: self,
                                                         action: #selector(saveButtonTapped)),
                                         animated: false)
        
        view.addSubview(tableView)
        tableView.frame = view.frame
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @objc private func saveButtonTapped() {
        let nextViewController = SexualitySelectionViewController()
        navigationController?.pushViewController(nextViewController, animated: true)
    }
}


//MARK: - SwiftUI
import SwiftUI

struct GenderViewControllerProvider: PreviewProvider {
    
    static var previews: some View {
        ContenerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContenerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: Context) -> GenderSelectionViewController {
            GenderSelectionViewController()
        }
        
        func updateUIViewController(_ uiViewController: GenderSelectionViewController, context: Context) {
            
        }
    }
}
