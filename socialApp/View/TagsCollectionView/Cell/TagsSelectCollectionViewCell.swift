//
//  TagsSelectCollectionViewCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 24.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class TagsSelectCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "TagsSelectCollectionViewCell"
    
    private let tagText = UILabel(labelText: "tag", textFont: .avenirRegular(size: 16))
    private var tagButton = UIImageView(systemName: "xmark", config: UIImage.SymbolConfiguration(font: .avenirRegular(size: 14)), tint: .myLabelColor())
    
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

extension TagsSelectCollectionViewCell {
    private func setupConstraints() {
        tagText.translatesAutoresizingMaskIntoConstraints = false
        tagButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagText)
        contentView.addSubview(tagButton)
        
        NSLayoutConstraint.activate([
            
            tagText.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            tagText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            tagText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10),
            tagText.trailingAnchor.constraint(equalTo: tagButton.leadingAnchor, constant: -5),
            
            tagButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tagButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }
}
