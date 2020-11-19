//
//  OneLineButton.swift
//  socialApp
//
//  Created by Денис Щиголев on 12.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class OneLineButtonWithHeader: UIButton {
    
    let headerLabel = UILabel(labelText: "", textFont: .avenirRegular(size: 16), textColor: .myGrayColor())
    let infoLabel  = UILabel(labelText: "", textFont: .avenirRegular(size: 16), textColor: .myLabelColor())
    let bottomLine = UIView(frame: .zero)
    
    convenience init(header: String, info: String) {
        self.init()
        headerLabel.text = header
        infoLabel.text = info
        bottomLine.backgroundColor = .myLightGrayColor()
        setupConstraints()
    }
    
    private func setupConstraints() {
        addSubview(headerLabel)
        addSubview(infoLabel)
        addSubview(bottomLine)
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            infoLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
            
            bottomLine.bottomAnchor.constraint(equalTo: infoLabel.bottomAnchor,constant: 3),
            bottomLine.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
}
