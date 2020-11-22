//
//  PremiumCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 22.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class PremiumCell: UICollectionViewCell {
    
    static let reuseID = "PremiumCell"
    
    let premiumLabel = UILabel(labelText: "Flava premium", textFont: .avenirBold(size: 16))
    let scrollInfoCollectionView = CollectionViewInfoGallery(elements: MPremiumInfo.shared.elements,
                                                             header: "Flava premium")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        clipsToBounds = true
        layer.cornerRadius = MDefaultLayer.smallCornerRadius.rawValue
        contentView.isUserInteractionEnabled = true
        
        let selectView = UIView(frame: bounds)
        selectView.backgroundColor = .mySecondSatColor()
        selectedBackgroundView = selectView
        
        let unselectView = UIView(frame: bounds)
        unselectView.backgroundColor = .mySecondColor()
        backgroundView = unselectView
        
        scrollInfoCollectionView.setupBackgroundColor(color: .mySecondSatColor())
        scrollInfoCollectionView.setupHeaderFont(font: .avenirBold(size: 16))
        
        
    }
    
    func configure(currentUser: MPeople, tapSelector: Selector, delegate: Any?) {
        if currentUser.isGoldMember || currentUser.isTestUser {
            scrollInfoCollectionView.isHidden = true
            premiumLabel.isHidden = false
        } else {
            scrollInfoCollectionView.isHidden = false
            premiumLabel.isHidden = true
        }
        scrollInfoCollectionView.setNeedsLayout()
        scrollInfoCollectionView.addSingleTapRecognizer(target: delegate, selector: tapSelector)
    }
    
    private func setupConstraints(){

        premiumLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollInfoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(premiumLabel)
        addSubview(scrollInfoCollectionView)
        
        NSLayoutConstraint.activate([
            
            premiumLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            premiumLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            premiumLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            
            scrollInfoCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollInfoCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollInfoCollectionView.topAnchor.constraint(equalTo: topAnchor),
            scrollInfoCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
