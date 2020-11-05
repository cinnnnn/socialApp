//
//  UniversalInfoCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 04.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class UniversalInfoCell: UITableViewCell, UnversalButtonCell {
    
    static let reuseID = "UniversalInfoCell"
    
    let cellImage = UIImageView()
    let cellLabel = UILabel(labelText: "", textFont: .avenirRegular(size: 14),textColor: .myGrayColor(), linesCount: 0)
    var withImage = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        cellImage.tintColor = .mySecondButtonLabelColor()
        
        let selectView = UIView(frame: bounds)
        selectView.backgroundColor = .mySuperLightGrayColor()
        selectedBackgroundView = selectView
        
        let unselectView = UIView(frame: bounds)
        unselectView.backgroundColor = .myWhiteColor()
        backgroundView = unselectView
    }
    
    func configure(with: UniversalCollectionCellModel, withImage: Bool) {
        
        cellLabel.text = with.description()
        self.withImage = withImage
        if let image = with.image(), withImage {
            cellImage.image = image.withConfiguration(UIImage.SymbolConfiguration(font: .avenirRegular(size: 25), scale: .default))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedBackgroundView?.layer.cornerRadius = frame.height / 2
        backgroundView?.layer.cornerRadius = frame.height / 2
    }
    
    private func setupConstraints(){
        
        addSubview(cellLabel)
        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if withImage {
            addSubview(cellImage)
            cellImage.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cellImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                cellImage.centerYAnchor.constraint(equalTo: centerYAnchor),
                
                cellLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                cellLabel.leadingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 10),
                cellLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            ])
        } else {
            NSLayoutConstraint.activate([
                cellLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                cellLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                cellLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            ])
        }
    }
}

