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
    let settingslabel = UILabel(labelText: "", textFont: .avenirBold(size: 16),textColor: .myLabelColor())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        settingsImage.tintColor = .mySecondButtonLabelColor()
        
        let selectView = UIView(frame: bounds)
        selectView.backgroundColor = .mySuperLightGrayColor()
        selectedBackgroundView = selectView
        
        let unselectView = UIView(frame: bounds)
        unselectView.backgroundColor = .myWhiteColor()
        backgroundView = unselectView
    }
    
    func configure(settings: CollectionCellModel) {
        settingslabel.text = settings.description()
        if let image = settings.image() {
            settingsImage.image = image.withConfiguration(UIImage.SymbolConfiguration(font: .avenirRegular(size: 25), scale: .default))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedBackgroundView?.layer.cornerRadius = frame.height / 2
        backgroundView?.layer.cornerRadius = frame.height / 2
    }
    
    private func setupConstraints(){

        addSubview(settingslabel)
//        addSubview(settingsImage)

        settingslabel.translatesAutoresizingMaskIntoConstraints = false
//        settingsImage.translatesAutoresizingMaskIntoConstraints = false
    
        NSLayoutConstraint.activate([
//            settingsImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
//            settingsImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            settingslabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingslabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            settingslabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
        ])
    }
}
