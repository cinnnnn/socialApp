//
//  GalleryScrollView.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import CoreImage.CIFilterBuiltins

class GalleryScrollView: UIScrollView {
    
    var gallery: [String : MGalleryPhotoProperty] = [:]
    var profileImage = ""
    
    convenience init(profileImage: String, gallery: [String : MGalleryPhotoProperty], showPrivate: Bool, showProtectButton: Bool) {
        self.init()
        self.profileImage = profileImage
        self.gallery = gallery
        setup()
        setupImages(profileImage: profileImage,
                    gallery: gallery,
                    showPrivate: showPrivate,
                    showProtectButton: showProtectButton,
                    complition: nil)
    }
    
    private func setup() {
        isPagingEnabled = true
        backgroundColor = .myWhiteColor()
        showsVerticalScrollIndicator = false
        layer.cornerRadius = MDefaultLayer.bigCornerRadius.rawValue
        clipsToBounds = true
        bounces = false
    }
    
    func setupImages(profileImage: String,
                     gallery: [String : MGalleryPhotoProperty],
                     showPrivate: Bool,
                     showProtectButton: Bool,
                     complition:(()->Void)?) {
        //add profile image
        if let url = URL(string: profileImage) {
            let imageView = GalleryImageView(galleryImage: nil,
                                             isPrivate: false,
                                             showProtectButton: false,
                                             showImage: true,
                                             clipsToBounds: true,
                                             contentMode: .scaleAspectFill)
    
            imageView.sd_setImage(with: url, completed: nil)
            
            addSubview(imageView)
        }
        //add gallery photo
        for image in gallery {
            if let url = URL(string: image.key) {
                let imageView = GalleryImageView(galleryImage: nil,
                                                 isPrivate: image.value.isPrivate,
                                                 showProtectButton: showProtectButton,
                                                 showImage: showPrivate,
                                                 clipsToBounds: true,
                                                 contentMode: .scaleAspectFill)
                
                imageView.sd_setImage(with: url) { _, _, _, _ in
                   
                    imageView.setup(isPrivate: image.value.isPrivate, showImage: showPrivate, showProtectButton: showProtectButton)
                }
                
                addSubview(imageView)
            }
        }
        if let complition = complition {
            complition()
        }
    }
    
    func prepareReuseScrollView() {
        subviews.forEach { view in
            if let view = view as? GalleryImageView {
                view.removeFromSuperview()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var countOfView = 0
        for view in subviews {
            if let view = view as? GalleryImageView {
                
                view.frame = CGRect(x: 0,
                                    y: frame.height * CGFloat(countOfView),
                                    width: frame.width,
                                    height: frame.height)
                countOfView += 1
            }
        }
        contentSize.height = frame.height * CGFloat(countOfView)
        layer.cornerRadius = frame.width / MDefaultLayer.widthMultiplier.rawValue / 2
    }
}

