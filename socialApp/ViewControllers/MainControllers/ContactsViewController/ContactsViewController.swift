//
//  ContactsViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {
    
    let contactsView = ContactsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupConstraints()
    }
    
    private func setup() {
        navigationItem.title = "Контакты"
        navigationController?.setNavigationBarHidden(false, animated: true)
        contactsView.configure(delegate: self,
                               emailSelector: #selector(emailTapped))
    }
    
}

extension ContactsViewController {
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

extension ContactsViewController {
    private func setupConstraints() {
        contactsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contactsView)
        
        NSLayoutConstraint.activate([
            contactsView.topAnchor.constraint(equalTo: view.topAnchor),
            contactsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contactsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contactsView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
