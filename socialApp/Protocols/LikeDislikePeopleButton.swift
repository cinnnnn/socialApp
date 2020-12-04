//
//  LikeDislikePeopleButton.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

 protocol LikeDislikePeopleButton {
    var actionPeople: MPeople? { get set }
    func play(complition:@escaping()->())
}
