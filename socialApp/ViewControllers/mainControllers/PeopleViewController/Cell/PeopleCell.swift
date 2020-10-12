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
    
    var person: MPeople?
    let galleryScrollView = GalleryScrollView(imagesURL: [])

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func configure(with value: MPeople, complition: @escaping()-> Void) {
        galleryScrollView.setupImages(imagesURL: [value.userImage] + value.gallery) {
            complition()
        }
    }
    
    override func prepareForReuse() {
        galleryScrollView.prepareReuseScrollView()
    }
}

extension PeopleCell {
    private func setupConstraints() {
        addSubview(galleryScrollView)
        galleryScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            galleryScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            galleryScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            galleryScrollView.topAnchor.constraint(equalTo: topAnchor),
            galleryScrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
