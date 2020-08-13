//
//  ActiveChatsCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI

protocol SelfConfiguringCell {
    static var reuseID: String { get }
    func configure(with value: MChat)
}

class ActiveChatsCell: UICollectionViewCell, SelfConfiguringCell {
    static var reuseID: String = "ActiveChatCell"
    
    let frendImage = UIImageView()
    let frendName = UILabel(labelText: "user1")
    let lastMessage = UILabel(labelText: "Whats ap!")
    let gradientView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
        layer.cornerRadius = 4
        clipsToBounds = true
    }
    
    func configure(with value: MChat) {
        
        frendImage.image = UIImage(named: value.userImageString)
        frendName.text = value.userName
        lastMessage.text = value.lastMessage
        
    }
    
    private func setupConstraints() {
        
        frendImage.translatesAutoresizingMaskIntoConstraints = false
        frendName.translatesAutoresizingMaskIntoConstraints = false
        lastMessage.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        gradientView.backgroundColor = .orange
        self.backgroundColor = .systemBackground
        
        addSubview(frendImage)
        addSubview(frendName)
        addSubview(lastMessage)
        addSubview(gradientView)
        
        NSLayoutConstraint.activate([
            frendImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            frendImage.topAnchor.constraint(equalTo: self.topAnchor),
            frendImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            frendImage.widthAnchor.constraint(equalTo: frendImage.heightAnchor),
            
            frendName.leadingAnchor.constraint(equalTo: frendImage.trailingAnchor, constant: 16),
            frendName.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            
            lastMessage.leadingAnchor.constraint(equalTo: frendName.leadingAnchor),
            lastMessage.topAnchor.constraint(equalTo: frendName.bottomAnchor, constant: 16),
            
            gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            gradientView.topAnchor.constraint(equalTo: self.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            gradientView.widthAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

//MARK: - SwiftUI
//struct ActiveCellControllerProvider: PreviewProvider {
//   
//    static var previews: some View {
//        ContenerView().edgesIgnoringSafeArea(.all)
//    }
//    
//    struct ContenerView: UIViewControllerRepresentable {
//        
//        func makeUIViewController(context: Context) -> ActiveChatsCell {
//            ActiveChatsCell()
//        }
//        
//        func updateUIViewController(_ uiViewController: ActiveChatsCell, context: Context) {
//            
//        }
//    }
//}
