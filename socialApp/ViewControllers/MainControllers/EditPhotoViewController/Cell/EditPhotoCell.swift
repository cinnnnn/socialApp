//
//  EditPhotoCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class EditPhotoCell: UICollectionViewCell {
    static let reuseID = "editPhotoCell"
    
    let image = UIImageView(image: nil, contentMode: .scaleAspectFill)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        image.image = nil
    }
    
    private func setup() {
        clipsToBounds = true
        image.layer.cornerRadius = MDefaultLayer.bigCornerRadius.rawValue
    }
    
    func configure(imageStringURL: String, complition:@escaping() -> Void) {
        guard let url = URL(string: imageStringURL) else { return }
        image.clipsToBounds = true
        image.sd_setImage(with: url, completed: nil)
        complition()
    }
}

extension EditPhotoCell {
    private func setupConstraints() {
        addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: leadingAnchor),
            image.trailingAnchor.constraint(equalTo: trailingAnchor),
            image.topAnchor.constraint(equalTo: topAnchor),
            image.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
