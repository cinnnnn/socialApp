//
//  ScreenProtectViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 11.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class ScreenProtectViewController: UIViewController {

    
    private let screenProtectView = ScreenProtectView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupConstraints()
    }
  
}

extension ScreenProtectViewController {
    
    private func setup() {
        view.backgroundColor = .myWhiteColor()
    }
    
    private func setupConstraints() {
        screenProtectView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(screenProtectView)
        
        NSLayoutConstraint.activate([
            screenProtectView.topAnchor.constraint(equalTo: view.topAnchor),
            screenProtectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            screenProtectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            screenProtectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
