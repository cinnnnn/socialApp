//
//  UIAlertExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 01.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    convenience init(title: String,
                     text: String,
                     buttonText: String,
                     style: Style,
                     buttonHandler: @escaping ()-> Void = { } ) {
        self.init(title:title, message: text, preferredStyle: style)
       
        
        let okAction = UIAlertAction(title: buttonText,
                                     style: .default) { _ in
                                        buttonHandler()
        }
        addAction(okAction)
            
        }
        
    }
