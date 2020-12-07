//
//  AboutViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 23.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    let aboutView = AboutView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupConstraints()
    }
    
    private func setup() {
        navigationItem.title = "Информация"
        
        aboutView.configure(delegate: self,
                            emailSelector: #selector(emailTapped),
                            termsOfServiceSelector: #selector(termsOfServiceTapped),
                            privacyButtonSelector: #selector(privacyTapped))
    }
    
}

extension AboutViewController {
    @objc private func emailTapped() {
        if let url = URL(string: "mailto:\(MLinks.email.rawValue)") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func termsOfServiceTapped() {
        if let url = URL(string: MLinks.termsOfServiceLink.rawValue) {
           let webController = WebViewController(urlToOpen: url)
            webController.modalPresentationStyle = .pageSheet
            present(webController, animated: true, completion: nil)
        }
    }
    
    @objc private func privacyTapped() {
        if let url = URL(string: MLinks.privacyLink.rawValue) {
            let webController = WebViewController(urlToOpen: url)
            webController.modalPresentationStyle = .pageSheet
            present(webController, animated: true, completion: nil)
        }
    }
}

extension AboutViewController {
    private func setupConstraints() {
        aboutView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(aboutView)
        
        NSLayoutConstraint.activate([
            aboutView.topAnchor.constraint(equalTo: view.topAnchor),
            aboutView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            aboutView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            aboutView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
