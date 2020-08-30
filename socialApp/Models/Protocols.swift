//
//  Protocols.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

// configure cell of collectionView

protocol SelfConfiguringCell {
    static var reuseID: String { get }
    func configure(with value: MChat)
}

protocol PeopleConfigurationCell {
    static var reuseID: String { get }
    var delegate: PeopleCellDelegate? { get set}
    var likeButton: UIButton { get }
    func configure(with value: MPeople)
    
}

protocol PeopleCellDelegate: class {
    func likeTupped(userID: Int)
}
