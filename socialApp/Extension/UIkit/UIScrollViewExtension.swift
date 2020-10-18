//
//  UIScrollViewExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 30.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit


extension UIScrollView {
    func updateContentView() {
        let bottomOffset:CGFloat = 45
        if let maxY = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY {
            contentSize.height = maxY + bottomOffset
        }
    }
}

