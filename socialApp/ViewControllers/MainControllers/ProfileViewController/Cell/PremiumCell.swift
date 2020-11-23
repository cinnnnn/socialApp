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
            scrollInfoCollectionView.setupHeader(text: "Подписка Flava premium активна")
        } else {
            scrollInfoCollectionView.setupHeader(text: "Flava premium")
        }
        scrollInfoCollectionView.setNeedsLayout()
        scrollInfoCollectionView.addSingleTapRecognizer(target: delegate, selector: tapSelector)
    }
    
    private func setupConstraints(){

        scrollInfoCollectionView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollInfoCollectionView)
        
        NSLayoutConstraint.activate([
            scrollInfoCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollInfoCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollInfoCollectionView.topAnchor.constraint(equalTo: topAnchor),
            scrollInfoCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
