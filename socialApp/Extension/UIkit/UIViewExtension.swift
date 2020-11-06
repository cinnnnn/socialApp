//
//  UIViewExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

extension UIView {
    
    func applyGradient(){
        
        self.backgroundColor = nil
        self.layoutIfNeeded()
        
        let gradientView = GradientView(from: .topTrailing, to: .bottomLeading, startColor: #colorLiteral(red: 1, green: 0.6655073762, blue: 0.9930477738, alpha: 1), endColor: #colorLiteral(red: 0.5750052333, green: 0.5949758887, blue: 0.9911155105, alpha: 1))
        
        if let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer{
            
            gradientLayer.frame = self.bounds
            self.layer.addSublayer(gradientLayer)
        }
    }
}

extension UIView {
    func addSingleTapRecognizer(target: Any?, selector: Selector?) {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: target, action: selector)
            singleTapGestureRecognizer.numberOfTapsRequired = 1
            singleTapGestureRecognizer.isEnabled = true
            singleTapGestureRecognizer.cancelsTouchesInView = false
            self.addGestureRecognizer(singleTapGestureRecognizer)
    }
}

extension UIView {
    func addCustomTransition(type: CATransitionType, duration: CFTimeInterval = 0.3) {
        let transition: CATransition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = type
        transition.subtype = .fromRight
        
        self.window?.layer.add(transition, forKey: nil)
    }
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}

extension UIView {
    func anchor(leading: NSLayoutXAxisAnchor?,
                trailing: NSLayoutXAxisAnchor?,
                top: NSLayoutYAxisAnchor?,
                bottom:NSLayoutYAxisAnchor?,
                height: NSLayoutDimension? = nil,
                width: NSLayoutDimension? = nil,
                multiplier: CGSize = .init(width: 1, height: 1),
                padding: UIEdgeInsets = .zero,
                size: CGSize = .zero) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let height = height, size.height == 0 {
            heightAnchor.constraint(equalTo: height, multiplier: multiplier.height).isActive = true
        }
        
        if let width = width, size.width == 0 {
            widthAnchor.constraint(equalTo: width, multiplier: multiplier.width).isActive = true
        }
        
        if size.width != 0 && width == nil {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 && height == nil {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}
