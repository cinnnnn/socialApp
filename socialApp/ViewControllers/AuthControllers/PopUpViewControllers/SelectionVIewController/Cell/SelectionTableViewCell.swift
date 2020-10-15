//
//  SelectionTableViewCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 11.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class SelectionTableViewCell: UITableViewCell {
    
    static let reuseID = "SelectionTableViewCell"
    private let checkImage = UIImageView(image: #imageLiteral(resourceName: "radio_filled"),
                                             contentMode: .scaleAspectFit,
                                             frame: CGRect(x: 0, y: 0, width: 20, height: 20),
                                             tint: .myGrayColor())
    private let uncheckImage = UIImageView(image: #imageLiteral(resourceName: "radio"),
                                             contentMode: .scaleAspectFit,
                                             frame: CGRect(x: 0, y: 0, width: 20, height: 20),
                                             tint: .myGrayColor())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        setupConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setup() {
        backgroundColor = .myWhiteColor()
        textLabel?.font = .avenirRegular(size: 16)
        
        checkImage.image?.sd_tintedImage(with: .myGrayColor())
        uncheckImage.image?.sd_tintedImage(with: .myGrayColor())
    }
    
    func configure(value: String) {
        textLabel?.text = value
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        switch selected {
        
        case true:
            selectedBackgroundView?.backgroundColor = .myWhiteColor()
            accessoryView = checkImage
        case false:
            backgroundColor = .myWhiteColor()
            accessoryView = uncheckImage
        }
    }
    private func setupConstraints(){
        
//        addSubview(checkImage)
//        checkImage.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            checkImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
//            checkImage.centerXAnchor.constraint(equalTo: centerXAnchor),
//            checkImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
//            checkImage.widthAnchor.constraint(equalTo: checkImage.heightAnchor)
//        ])
        
    }
}
