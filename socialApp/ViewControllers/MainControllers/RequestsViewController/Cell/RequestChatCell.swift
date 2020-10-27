//
//  RequestChatCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 17.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class RequestChatCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseID: String = "RequestChatCell"
    let frendImage = UIImageView(image: nil, contentMode: .scaleAspectFill)
    let frendName = UILabel(labelText: "", textFont: .avenirBold(size: 16),aligment: .center, linesCount: 0)
    let animateProfileBack = AnimationCustomView(name: "loading_grayCircle", loopMode: .loop, contentMode: .scaleAspectFit)
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with value: MChat) {
        let imageURL = URL(string: value.friendUserImageString )
        frendImage.sd_setImage(with: imageURL, completed: nil)
        frendName.text = value.friendUserName
    }
    
    private func setup() {
        backgroundColor = .myWhiteColor()
        layer.cornerRadius = MDefaultLayer.smallCornerRadius.rawValue
        clipsToBounds = true
       
        frendImage.clipsToBounds = true
        animateProfileBack.animationView.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frendImage.layer.cornerRadius = frendImage.frame.height / 2
    }
    private func setupConstraints(){
        
        frendImage.translatesAutoresizingMaskIntoConstraints = false
        frendName.translatesAutoresizingMaskIntoConstraints = false
        animateProfileBack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(animateProfileBack)
        addSubview(frendImage)
        addSubview(frendName)
        
        NSLayoutConstraint.activate([
            animateProfileBack.topAnchor.constraint(equalTo: topAnchor),
            animateProfileBack.centerXAnchor.constraint(equalTo: centerXAnchor),
            animateProfileBack.widthAnchor.constraint(equalTo: widthAnchor),
            animateProfileBack.heightAnchor.constraint(equalTo: animateProfileBack.widthAnchor),
            
            frendImage.centerYAnchor.constraint(equalTo: animateProfileBack.centerYAnchor),
            frendImage.centerXAnchor.constraint(equalTo: animateProfileBack.centerXAnchor),
            frendImage.widthAnchor.constraint(equalTo: animateProfileBack.widthAnchor, multiplier: 0.7),
            frendImage.heightAnchor.constraint(equalTo: frendImage.widthAnchor),
            
            frendName.topAnchor.constraint(equalTo: animateProfileBack.bottomAnchor),
            frendName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            frendName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
}
