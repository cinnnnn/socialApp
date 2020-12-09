//
//  AuthViewControllerDelegate.swift
//  socialApp
//
//  Created by Денис Щиголев on 08.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

@objc protocol AuthViewControllerDelegate: class {
    @objc func loginButtonPressed()
    @objc func appleButtonPressed()
    @objc func termsOfServicePressed()
    @objc func privacyPressed()
}
