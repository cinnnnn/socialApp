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
    
    weak var likeDislikeDelegate: PeopleButtonTappedDelegate?
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
        peopleView.likeButton.addTarget(self, action: #selector(likeTapped(sender:)), for: .touchUpInside)
        peopleView.dislikeButton.addTarget(self, action: #selector(dislikeTapped(sender:)), for: .touchUpInside)
        peopleView.timeButton.addTarget(self, action: #selector(timeTapped), for: .touchUpInside)
    }
    
    func configure(with value: MPeople, currentPeople: MPeople, complition: @escaping()-> Void) {
        
        peopleView.configure(with: value, currentPeople: currentPeople, showPrivatePhoto: false) {
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
    @objc private func likeTapped(sender: Any) {
        guard let sender = sender as? LikeDisklikeButton else { return }
        guard let people = sender.actionPeople else { return }
        likeDislikeDelegate?.likePeople(people: people)
    }
    
    @objc private func dislikeTapped(sender: Any) {
        guard let sender = sender as? LikeDisklikeButton else { return }
        guard let people = sender.actionPeople else { return }
        likeDislikeDelegate?.dislikePeople(people: people)
    }
    
    @objc private func timeTapped() {
        likeDislikeDelegate?.timeTapped()
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
