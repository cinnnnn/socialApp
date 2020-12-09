//
//  AboutView.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class AboutView: UIView {
    
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
    
    func configure(delegate: Any?, termsOfServiceSelector: Selector, privacyButtonSelector: Selector){
        termsOfServiceButton.addTarget(delegate, action: termsOfServiceSelector, for: .touchUpInside)
        privacyButton.addTarget(delegate, action: privacyButtonSelector, for: .touchUpInside)
    }
}


extension AboutView {
    private func setupConstraints() {
        termsOfServiceButton.translatesAutoresizingMaskIntoConstraints = false
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(termsOfServiceButton)
        addSubview(privacyButton)
        
        NSLayoutConstraint.activate([
            
            termsOfServiceButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            termsOfServiceButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            privacyButton.topAnchor.constraint(equalTo: termsOfServiceButton.bottomAnchor, constant: 20),
            privacyButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
        ])
    }
}
