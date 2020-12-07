//
//  HaveRequestGetPremiumView.swift
//  socialApp
//
//  Created by Денис Щиголев on 06.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class HaveRequestGetPremiumView: UIView {

    private let textLabel = UILabel(labelText: "Ты нравишься им",
                        textFont: .avenirRegular(size: 14),
                        textColor: .white,
                        linesCount: 0)
    
    private let premiumButton = OneLineButton(info: "Посмотреть всех",
                                              font: .avenirBold(size: 14),
                                              textColor: .white,
                                              lineColor: .white)
    
    
    
    init(onTapped: (target: Any, selector: Selector)) {
        super.init(frame: .zero)
        setup(onTapped: (target: onTapped.target,
                         selector: onTapped.selector))
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(countOfPeople: Int, isHidden: Bool) {
        self.isHidden = isHidden
        let waitText = countOfPeople == 1 ? " которому" : " которым"
        let peopleText = countOfPeople == 1 ? " человека" : " человек(а)"
        let textToShow = MLabels.haveRequestShowLabel1.rawValue + " \(countOfPeople) " + peopleText + waitText + MLabels.haveRequestShowLabel2.rawValue
        textLabel.text = textToShow
        
    }
}

extension HaveRequestGetPremiumView {
    private func setup(onTapped: (target: Any, selector: Selector)) {
        backgroundColor = .mySecondSatColor()
        
        premiumButton.addTarget(onTapped.target,
                                action: onTapped.selector,
                                for: .touchUpInside)
    }
    
    private func setupConstraint() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        premiumButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textLabel)
        addSubview(premiumButton)
        
        NSLayoutConstraint.activate([
            premiumButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            premiumButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            textLabel.bottomAnchor.constraint(equalTo: premiumButton.topAnchor, constant: -20),
            textLabel.leadingAnchor.constraint(equalTo: premiumButton.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20)
        ])
    }
}
