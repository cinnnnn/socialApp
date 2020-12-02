//
//  WaitingChatsCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class NewChatsCell: UICollectionViewCell,SelfConfiguringCell {
    static var reuseID: String = "NewChatsCell"
    
    let frendImage = UIImageView(image: nil, contentMode: .scaleAspectFill)
    let timerLabel = UILabel(labelText: "",
                             textFont: .avenirRegular(size: 12),
                             textColor: .myGrayColor(),
                             aligment: .center)
    var timer: Timer?
    
    func configure(with value: MChat, currentUser: MPeople) {
       
        let imageURL = URL(string: value.friendUserImageString )
        frendImage.sd_setImage(with: imageURL, completed: nil)
        getTimeToDelete(value: value)
        
        if timer == nil {
            timer = Timer(timeInterval: 60, repeats: true, block: {[weak self] _ in
                self?.getTimeToDelete(value: value)
            })
            timer?.tolerance = 10
            if let timer = timer {
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getTimeToDelete(value: MChat) {
        let defaultTimeToDelete = MChat.getDefaultPeriodMinutesOfLifeChat()
        let timerToDelete = value.createChatDate.getTimerToDate(timerMinuteCount: defaultTimeToDelete)
        timerLabel.text = timerToDelete
    }
    
    private func setup() {
        
        backgroundColor = .myWhiteColor()
        frendImage.layer.cornerRadius = MDefaultLayer.smallCornerRadius.rawValue
        frendImage.clipsToBounds = true

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timer?.invalidate()
        timer = nil
    }

    private func setupConstraints(){
        
        frendImage.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(frendImage)
        addSubview(timerLabel)
        
        NSLayoutConstraint.activate([
            frendImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            frendImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            frendImage.topAnchor.constraint(equalTo: topAnchor),
            frendImage.heightAnchor.constraint(equalTo: frendImage.widthAnchor),
            
            timerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            timerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            timerLabel.topAnchor.constraint(equalTo: frendImage.bottomAnchor, constant: 10),
            timerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
