//
//  ScreenRecordingView.swift
//  socialApp
//
//  Created by Денис Щиголев on 23.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class ScreenProtectView: UIView {
    
    let header = UILabel(labelText: "Мы защищаем конфиденциальность", textFont: .avenirBold(size: 24), linesCount: 0)
    let text = UILabel(labelText: "Cкрыли экран, пока у тебя идет запись",
                       textFont: .avenirRegular(size: 16),
                       textColor: .myGrayColor(),
                       linesCount: 0)
    
     init(){
        super.init(frame: UIScreen.main.bounds)
        setup()
        setupConsctraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .myWhiteColor()
    }
}

extension ScreenProtectView {
    private func setupConsctraints() {
        header.translatesAutoresizingMaskIntoConstraints = false
        text.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(header)
        addSubview(text)
        
        NSLayoutConstraint.activate([
            
            header.centerYAnchor.constraint(equalTo: centerYAnchor),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            text.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 20),
            text.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            text.trailingAnchor.constraint(equalTo: header.trailingAnchor),
        ])
    }
}
