//
//  TagsCollectionViewDelegate.swift
//  socialApp
//
//  Created by Денис Щиголев on 24.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

@objc protocol TagsCollectionViewDelegate {
    @objc optional func tagTextFiledDidBeginEditing(tagsCollectionView:TagsCollectionView)
    @objc optional func tagTextFiledShouldReturn(tagsCollectionView:TagsCollectionView, text: String)
    @objc optional func tagTextDidChange(tagsCollectionView:TagsCollectionView)
    @objc optional func tagTextConstraintsDidChange(tagsCollectionView:TagsCollectionView)
}
