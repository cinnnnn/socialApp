//
//  PeopleCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class PeopleCell: UICollectionViewCell, PeopleConfigurationCell {
    
    static var reuseID = "PeopleCell"
    
    private let peopleView = PeopleView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with value: MPeople,
                   currentPeople: MPeople,
                   buttonDelegate: PeopleButtonTappedDelegate?,
                   complition: @escaping()-> Void) {
        
        peopleView.configure(with: value,
                             currentPeople: currentPeople,
                             showPrivatePhoto: false,
                             withStatusBar: false,
                             buttonDelegate: buttonDelegate) { complition() }
        
        peopleView.buttonDelegate = buttonDelegate
    }
    
    override func prepareForReuse() {
        peopleView.prepareForRenew()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        peopleView.setNeedsLayout()
    }
}

//MARK: setupConstraints
extension PeopleCell {
    private func setupConstraints() {
        
        addSubview(peopleView)
        peopleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            peopleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            peopleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            peopleView.topAnchor.constraint(equalTo: topAnchor),
            peopleView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
