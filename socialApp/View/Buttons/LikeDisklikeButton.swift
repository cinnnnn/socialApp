//
//  LikeDisklikeButton.swift
//  socialApp
//
//  Created by Денис Щиголев on 02.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class LikeDisklikeButton: UIButton {
    
    convenience init(buttonImage: UIImage,
                     tintColor: UIColor,
                     backgroundColor: UIColor) {
        self.init()
        
        setImage(buttonImage, for: .normal)
        imageView?.tintColor = tintColor
        imageView?.backgroundColor = backgroundColor
        self.backgroundColor = backgroundColor
        clipsToBounds = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
}
