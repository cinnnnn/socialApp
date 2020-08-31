//
//  RequestViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 31.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI

class RequestViewController: UIViewController {
    
    let photo = UIImageView(image: #imageLiteral(resourceName: "Photo3"), contentMode: .scaleAspectFill)
    let container = UIView()
    let nameLabel = UILabel(labelText: "Зельда", textFont: .boldSystemFont(ofSize: 22))
    let messageTextView = UITextView(text: "Легенды Зельды", isEditableText: false, delegate: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAction()
        setupConstraints()
        configure()
        
    }
    
    //MARK: - setupAction()
    private func setupAction() {
        
        
    }
    
    //MARK: - configure()
    private func configure(){
        
        container.backgroundColor = .myBackgroundColor()
        container.layer.cornerRadius = 30
    }
    
    //MARK: - setupConstraints()
    private func setupConstraints() {
        
        photo.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
      
        view.addSubview(photo)
        view.addSubview(container)
        container.addSubview(nameLabel)
        container.addSubview(messageTextView)
     
        
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
            messageTextView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30)
            
            
        ])
    }
}


//MARK: - SwiftUI
struct RequestViewControllerProvider: PreviewProvider {
    
    static var previews: some View {
        ContenerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContenerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: Context) -> RequestViewController {
            RequestViewController()
        }
        
        func updateUIViewController(_ uiViewController: RequestViewController, context: Context) {
            
        }
    }
}
