//
//  SelectionTableViewHeader.swift
//  socialApp
//
//  Created by Денис Щиголев on 12.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class SelectionTableViewHeader: UITableViewHeaderFooterView {
    
    static let reuseID = "SelectionTableViewHeader"
    
    let headerText = UILabel(labelText: "", textFont: .avenirRegular(size: 16), textColor: .myGrayColor())
    let cancelButton = UIButton(newBackgroundColor: .myWhiteColor(),
                                borderWidth: 0,
                                title: "Отмена",
                                titleColor: .myLabelColor(),
                                font: .avenirRegular(size: 16))
    let saveButton = UIButton(newBackgroundColor: .myWhiteColor(),
                              newBorderColor: .myLightGrayColor(),
                              borderWidth: 1,
                              title: "Сохранить",
                              titleColor: .myLabelColor(),
                              font: .avenirRegular(size: 16))
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupConstraints()
        
        tintColor = .myWhiteColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
}

extension SelectionTableViewHeader {
    
    private func setupConstraints() {
        addSubview(headerText)
        addSubview(cancelButton)
        addSubview(saveButton)
        
        headerText.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerText.centerYAnchor.constraint(equalTo: centerYAnchor),
            headerText.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 18),
            
            saveButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            
            cancelButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -5),
            cancelButton.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
}
