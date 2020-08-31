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
    
    let photo = UIImageView(image: #imageLiteral(resourceName: "Photo6"), contentMode: .scaleAspectFill)
    let container = UIView()
    let nameLabel = UILabel(labelText: "Оленька", textFont: .boldSystemFont(ofSize: 22))
    let messageTextView = UITextView(text: "Твои планы на выходные?", isEditableText: false, delegate: nil)
    let acceptButton = UIButton(newBackgroundColor: .systemBackground, newBorderColor: .myHeaderColor(), title: "Принять", titleColor: .label)
    let denyButton = UIButton(newBackgroundColor: .systemBackground, newBorderColor: .red, title: "Отклонить", titleColor: .red)
    let buttonStackView = UIStackView()
    
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
        
        buttonStackView.addArrangedSubview(denyButton)
        buttonStackView.addArrangedSubview(acceptButton)
        buttonStackView.alignment = .center
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 20
        buttonStackView.distribution = .fillEqually
    }
    
    //MARK: - setupConstraints()
    private func setupConstraints() {
        
        photo.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        denyButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
      
        view.addSubview(photo)
        view.addSubview(container)
        container.addSubview(nameLabel)
        container.addSubview(messageTextView)
        container.addSubview(buttonStackView)
     
        
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
            
            buttonStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            buttonStackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30),
            buttonStackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -30),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50)
            
            
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
