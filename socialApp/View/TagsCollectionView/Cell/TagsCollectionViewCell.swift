//
//  TagsCollectionViewCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 24.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class TagsCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "TagsCollectionViewCell"
    
    private let tagText = UILabel(labelText: "tag", textFont: .avenirRegular(size: 16))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .myLightGrayColor()
        
        clipsToBounds = true
    }
    
    func configure(tag: MTag) {
        self.tagText.text = tag.tagText

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
       // tagButton.setImage(nil, for: .normal)
     //   tagButton = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
}

extension TagsCollectionViewCell {
    private func setupConstraints() {
        tagText.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tagText)

        NSLayoutConstraint.activate([
            
            tagText.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            tagText.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            tagText.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 10),
            tagText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
        
    }
}
