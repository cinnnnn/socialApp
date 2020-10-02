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

extension UIAlertController {
    func setMyStyle() {
        setBackgroudColor(color: .label )
        setTint(color: .myWhiteColor())
    }
    
    func setMyLightStyle() {
        setBackgroudColor(color: .myWhiteColor() )
        setTint(color: .label)
    }
    
    //Set background color of UIAlertController
      func setBackgroudColor(color: UIColor) {
        if let bgView = self.view.subviews.first,
          let groupView = bgView.subviews.first,
          let contentView = groupView.subviews.first {
          contentView.backgroundColor = color
        }
      }

      //Set tint color of UIAlertController
      func setTint(color: UIColor) {
        self.view.tintColor = color
      }
}

