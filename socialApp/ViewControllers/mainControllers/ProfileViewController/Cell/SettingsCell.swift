//
//  SettingsCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 07.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class SettingsCell: UICollectionViewCell {
    
    static let reuseID = "SettingsCell"
    
    let settingsImage = UIImageView()
    let settingslabel = UILabel(labelText: "", textFont: .avenirBold(size: 16))
    let settingsArrow = UIImageView(image: #imageLiteral(resourceName: "arrow"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .myWhiteColor()
        
        let selectView = UIView(frame: bounds)
        selectView.backgroundColor = .myLightGrayColor()
        selectedBackgroundView = selectView
        
        let unselectView = UIView(frame: bounds)
        unselectView.backgroundColor = .myWhiteColor()
        backgroundView = unselectView
    }
    
    func configure(settings: MSettings) {
        settingsImage.image = settings.image()
        settingslabel.text = settings.description()
       
    }
    
    private func setupConstraints(){
        
       // addSubview(settingsImage)
        addSubview(settingslabel)
        addSubview(settingsArrow)
        
      //  settingsImage.translatesAutoresizingMaskIntoConstraints = false
        settingslabel.translatesAutoresizingMaskIntoConstraints = false
        settingsArrow.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//            settingsImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
//            settingsImage.centerYAnchor.constraint(equalTo: centerYAnchor),
//            settingsImage.heightAnchor.constraint(equalToConstant: 20),
//            settingsImage.widthAnchor.constraint(equalToConstant: 20),
            
            settingslabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            settingslabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            settingsArrow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            settingsArrow.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingsArrow.heightAnchor.constraint(equalToConstant: 20),
            settingsArrow.widthAnchor.constraint(equalToConstant: 10),
        ])
    }
}
