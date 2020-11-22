//
//  GalleryScrollView.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import CHIPageControl

class GalleryView: UIView {
    
    var scrollView = UIScrollView()
    var gallery: [String : MGalleryPhotoProperty] = [:]
    var profileImage = ""
    var pageControl = CHIPageControlAleppo()
    
    convenience init(profileImage: String, gallery: [String : MGalleryPhotoProperty], showPrivate: Bool, showProtectButton: Bool) {
        self.init()
        self.profileImage = profileImage
        self.gallery = gallery
        setup()
        setupConstraints()
        setupImages(profileImage: profileImage,
                    gallery: gallery,
                    showPrivate: showPrivate,
                    showProtectButton: showProtectButton,
                    complition: nil)
    }
    
    private func setup() {
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        
        backgroundColor = .myWhiteColor()
        layer.cornerRadius = MDefaultLayer.bigCornerRadius.rawValue
        clipsToBounds = true
       
        pageControl.numberOfPages = gallery.count
        pageControl.hidesForSinglePage = false
        pageControl.tintColor = .myWhiteColor()
        pageControl.radius = 4
    
        pageControl.transform = CGAffineTransform(rotationAngle: .pi / 2)
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
            scrollView.addSubview(imageView)
          
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
                
              //  addSubview(imageView)
                scrollView.addSubview(imageView)
            }
        }
        pageControl.numberOfPages = gallery.count + 1
    
        if let complition = complition {
            complition()
        }
    }
    
    func prepareReuseScrollView() {
        scrollView.subviews.forEach { view in
            if let view = view as? GalleryImageView {
                view.removeFromSuperview()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var countOfView = 0
        
        for view in scrollView.subviews {
            if let view = view as? GalleryImageView {
                
                view.frame = CGRect(x: 0,
                                    y: frame.height * CGFloat(countOfView),
                                    width: frame.width,
                                    height: frame.height)
                countOfView += 1
                
            }
        }
        
        scrollView.contentSize.height = frame.height * CGFloat(countOfView)
        layer.cornerRadius = frame.width / MDefaultLayer.widthMultiplier.rawValue / 2
    }
    

}

extension GalleryView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let progress = scrollView.contentOffset.y / scrollView.frame.height
        pageControl.progress = Double(progress)
    }
}

extension GalleryView {
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            pageControl.centerYAnchor.constraint(equalTo: centerYAnchor),
            pageControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])
    }
}


