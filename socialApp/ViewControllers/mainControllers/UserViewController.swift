//
//  UserViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI

class UserViewController: UIViewController {
    
    let photo = UIImageView(image: #imageLiteral(resourceName: "Photo3"), contentMode: .scaleAspectFill)
    let container = UIView()
    let nameLabel = UILabel(labelText: "Зельда", textFont: .boldSystemFont(ofSize: 22))
    let messageTextView = UITextView(text: "Легенды Зельды", isEditableText: false, delegate: nil)
    let messageTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        view.backgroundColor = .red
        container.backgroundColor = .orange
        messageTextField.backgroundColor = .blue
        
    }
    
    
    private func setupConstraints() {
        
        photo.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(photo)
        view.addSubview(container)
        container.addSubview(nameLabel)
        container.addSubview(messageTextView)
        container.addSubview(messageTextField)
        
      
        NSLayoutConstraint.activate([
            
            //main constraints
            photo.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photo.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photo.topAnchor.constraint(equalTo: view.topAnchor),
            photo.bottomAnchor.constraint(equalTo: container.topAnchor, constant: 30),
            
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 400),
            
            //container constraints
            
            nameLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 30),
            
            messageTextView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30),
            messageTextView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            messageTextView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30),
            
            messageTextField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            messageTextField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30),
            messageTextField.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -60)
            
            
        ])
        

        
       
        
    }
}

//MARK: - SwiftUI
struct UserViewControllerProvider: PreviewProvider {
   
    static var previews: some View {
        ContenerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContenerView: UIViewControllerRepresentable {
        
        
        typealias UIViewControllerType = UserViewController
        
        func makeUIViewController(context: Context) -> ContenerView.UIViewControllerType {
            UserViewController()
        }
        
        func updateUIViewController(_ uiViewController: UserViewController, context: Context) {
            
        }
    }
}
