//
//  GalleryImageView.swift
//  socialApp
//
//  Created by Денис Щиголев on 20.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class GalleryImageView: UIImageView {
    
    let privateButton = UIButton(image: UIImage(systemName: "lock.shield.fill",
                                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 38, weight: .black)) ?? #imageLiteral(resourceName: "info"),
                                 tintColor: .myWhiteColor(),
                                 backgroundColor: .clear)
    var isPrivate = false
    var showProtectButton = false
    var showImage = false
    
    convenience init(galleryImage: UIImage?, isPrivate: Bool, showProtectButton: Bool, showImage: Bool, clipsToBounds: Bool, contentMode: UIView.ContentMode) {
        self.init()
        self.contentMode = contentMode
        self.clipsToBounds = clipsToBounds
        self.isPrivate = isPrivate
        self.showProtectButton = showProtectButton
        self.showImage = showImage
        self.privateButton.isHidden = !showProtectButton
        if let image = galleryImage {
            self.image = image
        }
        
        setup(isPrivate: isPrivate, showImage: showImage, showProtectButton: showProtectButton)
        setupConstraints()
    }
}

extension GalleryImageView {
    func setup(isPrivate: Bool, showImage: Bool, showProtectButton: Bool) {
        if isPrivate {
            if !showImage {
                image = image?.sd_blurredImage(withRadius: 100)
            }
            privateButton.isHidden = !showProtectButton
        } else {
            privateButton.isHidden = true
        }
    }
    
    private func setupConstraints() {
        
        privateButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(privateButton)
        
        NSLayoutConstraint.activate([
            privateButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            privateButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            privateButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3),
            privateButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
        ])
        
    }
}
