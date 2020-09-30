//
//  AdvertInactiveView.swift
//  socialApp
//
//  Created by Денис Щиголев on 16.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class AdvertInactiveView: UIView {
    
    let goToConfigButton = UIButton(newBackgroundColor: .label, title: "Добавить объявление", titleColor: .systemBackground)
    let infoLabel = UILabel(labelText: "Ты можешь посмотреть, что написали остальные, только когда опубликуешь свое объявление",
                            multiline: true,
                            textFont: .systemFont(ofSize: 16, weight: .regular),
                            textColor: .label)
    let logoImage = UIImageView(image: #imageLiteral(resourceName: "advertLogo"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(isHidden: Bool) {
        self.init()
        
        self.isHidden = isHidden
        
        addSubview(goToConfigButton)
        addSubview(infoLabel)
        addSubview(logoImage)
        
        setup()
        setupConstraints()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .systemBackground
        infoLabel.textAlignment = .center
    }
    
}
//MARK: SetupConstraints
extension AdvertInactiveView {
    
    private func setupConstraints() {
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        goToConfigButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        logoImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 25),
        logoImage.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 25),
        logoImage.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -25),
        logoImage.heightAnchor.constraint(equalTo: logoImage.widthAnchor, multiplier: 1.0/1.0),
        
        infoLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 25),
        infoLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -25),
        infoLabel.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 25),
        infoLabel.heightAnchor.constraint(equalToConstant: 150),
        
        goToConfigButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -25),
        goToConfigButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 25),
        goToConfigButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -25),
        goToConfigButton.heightAnchor.constraint(equalTo: goToConfigButton.widthAnchor, multiplier: 1.0/7.28),
        ])
    }
}


