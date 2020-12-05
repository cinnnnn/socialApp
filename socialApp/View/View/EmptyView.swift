//
//  EmptyPeopleView.swift
//  socialApp
//
//  Created by Денис Щиголев on 28.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class EmptyView: UIView {
    
    private var headerLabel = UILabel(labelText: "",
                                      textFont: .avenirBold(size: 16),
                                      linesCount: 0)
    private var textLabel = UILabel(labelText: "",
                                    textFont: .avenirRegular(size: 16),
                                    textColor: .myGrayColor(),
                                    linesCount: 0)
    private var emptyImage = AnimationCustomView(name: "", loopMode: .loop, contentMode: .scaleAspectFit)
//    private var emptyButton = RoundButton(newBackgroundColor: .myLabelColor(),
//                                  title: "",
//                                  titleColor: .myWhiteColor())
    private var emptyButton = OneLineButton(info: "",
                                            font: .avenirBold(size: 16),
                                            textColor: .myLabelColor(),
                                            lineColor: .myGrayColor())

    
    init(imageName: String, header: String, text: String, buttonText: String, delegate: Any?, selector: Selector){
        super.init(frame: .zero)
        
        emptyImage.setupImage(name: imageName)
        headerLabel.text = header
        textLabel.text = text
        emptyButton.setText(text: buttonText)

        setupConstraints()
        setupButton(target: delegate, selector: selector)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     func playAnimation() {
        emptyImage.play()
    }
    
    func stopAnimation() {
       emptyImage.stop()
   }
    
    func hide(hidden: Bool) {
        if hidden {
            emptyImage.stop()
            self.isHidden = true
        } else {
            emptyImage.play()
            self.isHidden = false
        }
    }
}

extension EmptyView {
    private func setupButton(target: Any?, selector: Selector) {
        emptyButton.addTarget(target, action: selector, for: .touchUpInside)
    }
    
    private func setupConstraints() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyImage.translatesAutoresizingMaskIntoConstraints = false
        emptyButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(emptyImage)
        addSubview(headerLabel)
        addSubview(textLabel)
        addSubview(emptyButton)
        
        NSLayoutConstraint.activate([
            emptyImage.topAnchor.constraint(equalTo: topAnchor),
            emptyImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyImage.bottomAnchor.constraint(equalTo:centerYAnchor),
            
            headerLabel.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 10),
            headerLabel.leadingAnchor.constraint(equalTo: emptyImage.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: emptyImage.trailingAnchor),
            
            textLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            textLabel.leadingAnchor.constraint(equalTo: emptyImage.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: emptyImage.trailingAnchor),
            
            emptyButton.leadingAnchor.constraint(equalTo: emptyImage.leadingAnchor),
            emptyButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
    }
}
