//
//  OneLineTextField.swift
//  socialApp
//
//  Created by Денис Щиголев on 02.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class OneLineTextField: UITextField {
    
    
    convenience init(isSecureText: Bool ){
        self.init()
        
        borderStyle = .none
        translatesAutoresizingMaskIntoConstraints = false
        isSecureTextEntry = isSecureText
        
        let bottomView =  UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bottomView.backgroundColor = .label
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 1),
            bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        
    }
}



