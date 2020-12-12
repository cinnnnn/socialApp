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
    
    let image = GalleryImageView(galleryImage: nil,
                                 isPrivate: false,
                                 showProtectButton: true,
                                 showImage: true,
                                 clipsToBounds: true,
                                 contentMode: .scaleAspectFill)
    
    let dotImage = UIImageView(systemName: "ellipsis",
                               config: UIImage.SymbolConfiguration(font: .avenirRegular(size: 16)),
                               tint: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        image.image = nil
    }
    
    func configure(galleryImage: String, isPrivate: Bool, complition:@escaping() -> Void) {
        guard let url = URL(string: galleryImage) else { return }
        image.sd_setImage(with: url, completed: nil)
        image.setup(isPrivate: isPrivate, showImage: true, showProtectButton: true)
        complition()
    }
}

extension EditPhotoCell {
    private func setupConstraints() {
        addSubview(image)
        addSubview(dotImage)
        image.translatesAutoresizingMaskIntoConstraints = false
        dotImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: leadingAnchor),
            image.trailingAnchor.constraint(equalTo: trailingAnchor),
            image.topAnchor.constraint(equalTo: topAnchor),
            image.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            dotImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            dotImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
}
