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
   // let frendName = UILabel(labelText: "", textFont: .avenirBold(size: 24),aligment: .left, linesCount: 0)
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with value: MChat, currentUser: MPeople) {
        let imageURL = URL(string: value.friendUserImageString )
        
        if currentUser.isGoldMember || currentUser.isTestUser {
            frendImage.sd_setImage(with: imageURL, completed: nil)
        } else {
            frendImage.sd_setImage(with: imageURL) {[weak self] image, error, cache, url in
                self?.frendImage.image = image?.sd_blurredImage(withRadius: 100)
            }
        }
       // frendName.text = value.friendUserName
    }
    
    private func setup() {
        backgroundColor = .myWhiteColor()
        layer.cornerRadius = MDefaultLayer.smallCornerRadius.rawValue
        clipsToBounds = true
       
        frendImage.clipsToBounds = true
        frendImage.layer.cornerRadius = MDefaultLayer.smallCornerRadius.rawValue
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       // frendImage.layer.cornerRadius = frendImage.frame.height / 2
    }
    private func setupConstraints(){
        
        frendImage.translatesAutoresizingMaskIntoConstraints = false
   //     frendName.translatesAutoresizingMaskIntoConstraints = false
   
        addSubview(frendImage)
    //    addSubview(frendName)
        
        NSLayoutConstraint.activate([
            frendImage.topAnchor.constraint(equalTo: topAnchor),
            frendImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            frendImage.widthAnchor.constraint(equalTo: widthAnchor),
            frendImage.heightAnchor.constraint(equalTo: frendImage.widthAnchor),
            frendImage.bottomAnchor.constraint(equalTo: bottomAnchor)
            
//            frendName.topAnchor.constraint(equalTo: frendImage.bottomAnchor),
//            frendName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
//            frendName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
//            frendName.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
