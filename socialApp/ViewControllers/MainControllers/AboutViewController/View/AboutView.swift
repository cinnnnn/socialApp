//
//  AboutView.swift
//  socialApp
//
//  Created by Денис Щиголев on 23.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class AboutView: UIView {
    
    private let emailHeader = UILabel(labelText: MLabels.aboutEmailHeader.rawValue,
                              textFont: .avenirRegular(size: 16),
                              linesCount: 0)
    private  let emailButton = OneLineButton(info: MLinks.email.rawValue, font: .avenirBold(size: 16))
    private let termsOfServiceButton = OneLineButton(info: "Условия и положения", font: .avenirBold(size: 16))
   
    private let privacyButton = OneLineButton(info: "Политика конфиденциальности", font: .avenirBold(size: 16))
    
    init(){
        super.init(frame: .zero)
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(){
        backgroundColor = .myWhiteColor()
    }
    
    func configure(delegate: Any?, emailSelector: Selector, termsOfServiceSelector: Selector, privacyButtonSelector: Selector){
        emailButton.addTarget(delegate, action: emailSelector, for: .touchUpInside)
        termsOfServiceButton.addTarget(delegate, action: termsOfServiceSelector, for: .touchUpInside)
        privacyButton.addTarget(delegate, action: privacyButtonSelector, for: .touchUpInside)
    }
}


extension AboutView {
    private func setupConstraints() {
        emailHeader.translatesAutoresizingMaskIntoConstraints = false
        emailButton.translatesAutoresizingMaskIntoConstraints = false
        termsOfServiceButton.translatesAutoresizingMaskIntoConstraints = false
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(emailHeader)
        addSubview(emailButton)
        addSubview(termsOfServiceButton)
        addSubview(privacyButton)
        
        NSLayoutConstraint.activate([
            emailHeader.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            emailHeader.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emailHeader.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            emailButton.topAnchor.constraint(equalTo: emailHeader.bottomAnchor, constant: 20),
            emailButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            termsOfServiceButton.bottomAnchor.constraint(equalTo: privacyButton.topAnchor, constant: -20),
            termsOfServiceButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            privacyButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            privacyButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
        ])
    }
}
