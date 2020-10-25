//
//  ActiveChatsCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI
import SDWebImage

class ActiveChatsCell: UICollectionViewCell, SelfConfiguringCell {
    static var reuseID: String = "ActiveChatCell"
    
    let frendImage = UIImageView(image: #imageLiteral(resourceName: "advertLogo"), contentMode: .scaleAspectFill)
    let frendName = UILabel(labelText: "", textFont: .avenirRegular(size: 12), textColor: .myGrayColor())
    let lastMessage = UILabel(labelText: "", textFont: .avenirRegular(size: 14), textColor: .myLabelColor(), linesCount: 2)
    let dateOfMessage = UILabel(labelText: "", textFont: .avenirRegular(size: 12), textColor: .myGrayColor())
    var dateOfLastMessage: Date?
    var displayLink: CADisplayLink?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupConstraints()
    }
    
      //MARK: - setup
    private func setup() {
        
        backgroundColor = .myWhiteColor()
        
        clipsToBounds = true
        frendImage.clipsToBounds = true
    }
    //MARK: - configure
    func configure(with value: MChat) {
        
        let imageURL = URL(string: value.friendUserImageString)
        frendImage.sd_setImage(with: imageURL, completed: nil)
        frendName.text = value.friendUserName
        lastMessage.text = value.lastMessage
        dateOfMessage.text = value.date.getPeriod()
        displayLink = CADisplayLink(target: self, selector: #selector(dateUpdate))
        displayLink?.preferredFramesPerSecond = 1
        displayLink?.add(to: .main, forMode: .default)
    
        
        dateOfLastMessage = value.date
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frendImage.layer.cornerRadius = frendImage.frame.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        displayLink?.invalidate()
    }
}

extension ActiveChatsCell {
    
    @objc private func dateUpdate() {
        guard let date = dateOfLastMessage else { return }
        dateOfMessage.text = date.getPeriod()
    }
}

//MARK: -  setupConstraints
extension ActiveChatsCell {
    private func setupConstraints() {
        
        frendImage.translatesAutoresizingMaskIntoConstraints = false
        frendName.translatesAutoresizingMaskIntoConstraints = false
        lastMessage.translatesAutoresizingMaskIntoConstraints = false
        dateOfMessage.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(frendImage)
        addSubview(frendName)
        addSubview(lastMessage)
        addSubview(dateOfMessage)
        
        NSLayoutConstraint.activate([
            frendImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            frendImage.topAnchor.constraint(equalTo: topAnchor),
            frendImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            frendImage.widthAnchor.constraint(equalTo: frendImage.heightAnchor),
            
            frendName.leadingAnchor.constraint(equalTo: frendImage.trailingAnchor, constant: 15),
            frendName.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            lastMessage.leadingAnchor.constraint(equalTo: frendName.leadingAnchor),
            lastMessage.trailingAnchor.constraint(equalTo: dateOfMessage.trailingAnchor),
            lastMessage.topAnchor.constraint(equalTo: frendName.bottomAnchor, constant: 5),
            
            dateOfMessage.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -10),
            dateOfMessage.topAnchor.constraint(equalTo: frendName.topAnchor)
        ])
    }
}




