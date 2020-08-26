//
//  Protocols.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

// configure cell of collectionView

protocol SelfConfiguringCell {
    static var reuseID: String { get }
    func configure(with value: MChat)
}

protocol PeopleConfigurationCell {
    static var reuseID: String { get }
    func configure(with value: MPeople)
}

