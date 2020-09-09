//
//  UIImageExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

extension UIImage {
        
        func resizeImage(targetLength: CGFloat) -> UIImage {
            let size = self.size
            let maxLength = targetLength
            let largeSize = max(size.width, size.height)
            
            let rationScale = largeSize > maxLength ? largeSize / maxLength : 1

            let newSize = CGSize(width: size.width / rationScale, height: size.height / rationScale)
            
            
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        }
}


