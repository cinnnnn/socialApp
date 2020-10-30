//
//  CountOfUnreadMessageView.swift
//  socialApp
//
//  Created by Денис Щиголев on 30.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class CountOfUnreadMessageView: UIView {
    
    private let countLabel = UILabel(labelText: "", textFont: .avenirRegular(size: 14), textColor: .myWhiteColor(), aligment: .center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(){
        backgroundColor = .myLabelColor()
        clipsToBounds = true
        countLabel.clipsToBounds = true
    }
    
    func updateBackgroundView() {
        if let subview = subviews.first {
            let height = subview.frame.height
            frame.size.height = height
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    func setupCount(countOfMessages: Int) {
        isHidden = countOfMessages == 0 ? true : false
        countLabel.text = String(countOfMessages)
    }
}

extension CountOfUnreadMessageView {
    
    private func setupConstraints() {
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            countLabel.topAnchor.constraint(equalTo: topAnchor),
        ])
    }
}
