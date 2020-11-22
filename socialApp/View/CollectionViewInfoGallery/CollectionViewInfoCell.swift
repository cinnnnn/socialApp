//
//  CollectionViewInfoCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 22.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class CollectionViewInfoCell: UICollectionViewCell {
    static let reuseID = "CollectionViewInfoCell"
    
    let header = UILabel(labelText: "", textFont: .avenirBold(size: 16), textColor: .myLabelColor())
    let info = UILabel(labelText: "", textFont: .avenirRegular(size: 16),textColor: .myGrayColor(), linesCount: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(item: MCollectionViewGalleryElement) {
        header.text = item.header
        info.text = item.info
        
        if let backgroundColor = item.backgroundColor {
            self.backgroundColor = backgroundColor
        }
        if let headerColor = item.headerColor {
            header.textColor = headerColor
        }
        
        if let infoColor = item.infoColor {
            info.textColor = infoColor
        }
    }
}

extension CollectionViewInfoCell {
    private func setupConstraints() {
        header.translatesAutoresizingMaskIntoConstraints = false
        info.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(header)
        addSubview(info)
        
        NSLayoutConstraint.activate([
            header.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            info.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            info.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            info.trailingAnchor.constraint(equalTo: header.trailingAnchor),
        ])
    }
}
