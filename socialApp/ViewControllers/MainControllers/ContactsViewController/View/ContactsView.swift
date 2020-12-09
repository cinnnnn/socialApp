//
//  AboutView.swift
//  socialApp
//
//  Created by Денис Щиголев on 23.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class ContactsView: UIView {
    
    private let emailHeader = UILabel(labelText: MLabels.aboutEmailHeader.rawValue,
                              textFont: .avenirRegular(size: 16),
                              linesCount: 0)
    private  let emailButton = OneLineButton(info: MLinks.email.rawValue, font: .avenirBold(size: 16))
    
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
    
    func configure(delegate: Any?, emailSelector: Selector){
        emailButton.addTarget(delegate, action: emailSelector, for: .touchUpInside)
    }
}


extension ContactsView {
    private func setupConstraints() {
        emailHeader.translatesAutoresizingMaskIntoConstraints = false
        emailButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(emailHeader)
        addSubview(emailButton)
        NSLayoutConstraint.activate([
            emailHeader.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            emailHeader.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emailHeader.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            emailButton.topAnchor.constraint(equalTo: emailHeader.bottomAnchor, constant: 20),
            emailButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
        ])
    }
}
