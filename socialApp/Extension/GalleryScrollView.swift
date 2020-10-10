//
//  GalleryScrollView.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class GalleryScrollView: UIScrollView {
    
    var images: [String] = []
    
    convenience init(imagesURL: [String]) {
        self.init()
        self.images = images
        setup()
        setupImages(imagesURL: imagesURL, complition: nil)
    }
    
    private func setup() {
        isPagingEnabled = true
        backgroundColor = .red
    }
    
    func setupImages(imagesURL: [String], complition:(()->Void)?) {
        for imageStringURL in imagesURL {
            if let url = URL(string: imageStringURL) {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.sd_setImage(with: url, completed: nil)
                addSubview(imageView)
            }
        }
        if let complition = complition {
            complition()
        }
    }
    
    func prepareReuseScrollView() {
        subviews.forEach { view in
            if let view = view as? UIImageView {
                view.removeFromSuperview()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var countOfView = 0
        for view in subviews {
            if let view = view as? UIImageView {
                
                view.frame = CGRect(x: 0,
                                    y: frame.height * CGFloat(countOfView),
                                    width: frame.width,
                                    height: frame.height)
                countOfView += 1
            }
        }
        contentSize.height = frame.height * CGFloat(countOfView)
    }
}

