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
        contentSize.height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height
    }
}

