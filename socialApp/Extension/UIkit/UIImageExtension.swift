//
//  UIImageExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

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
    
    func applyFadeFilter() -> UIImage? {
            let newFilter = CIFilter.photoEffectMono()
            let context = CIContext()
             newFilter.inputImage = CIImage(image: self)
            guard let outputImage = newFilter.outputImage else { return nil }
            guard let rect = CIImage(image: self)?.extent else { return nil }
            guard let myCgImage = context.createCGImage(outputImage, from: rect) else { return nil }
            let finalImage = UIImage(cgImage: myCgImage)
            return finalImage
    }
}


