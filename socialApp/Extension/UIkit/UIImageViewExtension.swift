//
//  UIImageExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 28.06.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

extension UIImageView {
    
    convenience init(image: UIImage?, contentMode: UIView.ContentMode, frame: CGRect? = nil, tint: UIColor? = nil) {
        self.init()
        
        
        self.contentMode = contentMode
        
        if let newFrame = frame {
            self.frame = newFrame
        }
        
        if let newTint = tint {
            self.tintColor = newTint
            self.image = image?.withRenderingMode(.alwaysTemplate)
        } else {
            self.image = image
        }
    }
    
    convenience init (systemName: String, config: UIImage.SymbolConfiguration, tint: UIColor? = nil, frame: CGRect? = nil) {
        self.init()
        
        if let newTint = tint {
            self.tintColor = newTint
            self.image = UIImage(systemName: systemName, withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        } else {
            self.image = UIImage(systemName: systemName, withConfiguration: config)
        }
        
        if let newFrame = frame {
            self.frame = newFrame
        }
    }
}
