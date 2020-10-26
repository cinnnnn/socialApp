//
//  PeopleCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class PeopleCell: UICollectionViewCell,PeopleConfigurationCell {
    
    static var reuseID = "PeopleCell"
    
    weak var likeDislikeDelegate: LikeDislikeTappedDelegate?
    var person: MPeople?
    let peopleView = PeopleView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        layer.cornerRadius = MDefaultLayer.bigCornerRadius.rawValue
        clipsToBounds = true
        
        peopleView.likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        peopleView.dislikeButton.addTarget(self, action: #selector(dislikeTapped), for: .touchUpInside)
    }
    func configure(with value: MPeople, complition: @escaping()-> Void) {
        
        person = value
        peopleView.configure(with: value) {
            complition()
        }
    }
    
    override func prepareForReuse() {
        peopleView.galleryScrollView.prepareReuseScrollView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        peopleView.layoutSubviews()
    }
}

extension PeopleCell {
    @objc private func likeTapped() {
        if let person = person {
            likeDislikeDelegate?.likePeople(people: person)
        }
    }
    
    @objc private func dislikeTapped() {
        if let person = person {
            likeDislikeDelegate?.dislikePeople(people: person)
        }
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
