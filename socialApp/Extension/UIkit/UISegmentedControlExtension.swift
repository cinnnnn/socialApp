//
//  UISegmentedControlExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    
    convenience init(first: String, second: String, selectedIndex: Int) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        
        selectedSegmentTintColor = .systemBackground
        backgroundColor = .black
        insertSegment(withTitle: first, at: 0, animated: true)
        insertSegment(withTitle: second, at: 1, animated: true)
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        setTitleTextAttributes(titleTextAttributes, for:.normal)

        let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: UIColor.black]
        setTitleTextAttributes(titleTextAttributes1, for:.selected)
        
        selectedSegmentIndex = selectedIndex
    }
}
