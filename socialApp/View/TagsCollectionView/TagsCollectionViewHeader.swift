//
//  TagsCollectionViewHeader.swift
//  socialApp
//
//  Created by Денис Щиголев on 24.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class TagsCollectionViewHeader: UICollectionReusableView {
    static let reuseId = "TagsCollectionViewHeader"
    
    let title = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    func configure(text: String?, font: UIFont?, textColor: UIColor?) {
        title.text = text
        title.font = font
        title.textColor = textColor
    }
}
