//
//  TagsCollectionViewDelegate.swift
//  socialApp
//
//  Created by Денис Щиголев on 24.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

@objc protocol TagsCollectionViewDelegate {
    @objc optional func tagTextFiledDidBeginEditing()
    @objc optional func tagTextFiledShouldReturn(text: String)
}
