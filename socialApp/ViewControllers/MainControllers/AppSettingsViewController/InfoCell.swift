//
//  InfoCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

import UIKit

class InfoCell: UICollectionViewCell {
    
    static let reuseID = "InfoCell"
    
    let infoLabel = UILabel(labelText: "",
                            textFont: .avenirBold(size: 16),
                            textColor: .myLabelColor())
    let subInfoLabel = UILabel(labelText: "",
                               textFont: .avenirRegular(size: 16),
                               textColor: .myGrayColor())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        let selectView = UIView(frame: bounds)
        selectView.backgroundColor = .mySuperLightGrayColor()
        selectedBackgroundView = selectView
        
        let unselectView = UIView(frame: bounds)
        unselectView.backgroundColor = .myWhiteColor()
        backgroundView = unselectView
    }
    
    func configure(header: String, subHeader: String) {
        infoLabel.text = header
        subInfoLabel.text = subHeader
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedBackgroundView?.layer.cornerRadius = frame.height / 2
        backgroundView?.layer.cornerRadius = frame.height / 2
    }
    
    private func setupConstraints(){

        addSubview(infoLabel)
        addSubview(subInfoLabel)

        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        subInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            
            subInfoLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 10),
            subInfoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            subInfoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            subInfoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}
