//
//  AuthView.swift
//  socialApp
//
//  Created by Денис Щиголев on 08.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import AuthenticationServices

class AuthView: UIView {
    
    private let loginButton = UIButton(newBackgroundColor: nil,
                               title: "Войти с Email",
                               titleColor: .myGrayColor(),
                               font: .avenirRegular(size: 16))
    
    private let appleButton = ASAuthorizationAppleIDButton()
    
    private let confirmLabel = UILabel(labelText: MLabels.loginAgreeInfo.rawValue,
                                       textFont: .avenirRegular(size: 12),
                                       textColor: .myGrayColor(),
                                       aligment: .center,
                                       linesCount: 0)
    
    private let termsOfServiceButton = OneLineButton(info: "условиями и положениями",
                                                     font: .avenirRegular(size: 12),
                                                     textColor: .myGrayColor(),
                                                     lineColor: .myLightGrayColor())
    private let privacyButton = OneLineButton(info: "политикой конфиденциальности",
                                                     font: .avenirRegular(size: 12),
                                                     textColor: .myGrayColor(),
                                                     lineColor: .myLightGrayColor())
    private let animatedLogoImage = AnimationCustomView(name: "communication",
                                                        loopMode: .loop,
                                                        contentMode: .scaleAspectFit)
    weak var delegate: AuthViewControllerDelegate?
    
    init(){
        super.init(frame: .zero)
        setup()
        setupButtonAction()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        appleButton.cornerRadius = appleButton.frame.height / 2
    }
}

extension AuthView {
    private func setup(){
        backgroundColor = .myWhiteColor()
        appleButton.layoutIfNeeded()
        animatedLogoImage.animationView.play()
    }
    
    private func setupButtonAction() {
        loginButton.addTarget(delegate, action: #selector(delegate?.loginButtonPressed), for: .touchUpInside)
        appleButton.addTarget(delegate, action: #selector(delegate?.appleButtonPressed), for: .touchUpInside)
        termsOfServiceButton.addTarget(delegate, action: #selector(delegate?.termsOfServicePressed), for: .touchUpInside)
        privacyButton.addTarget(delegate, action: #selector(delegate?.privacyPressed), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        animatedLogoImage.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        confirmLabel.translatesAutoresizingMaskIntoConstraints = false
        termsOfServiceButton.translatesAutoresizingMaskIntoConstraints = false
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(animatedLogoImage)
        addSubview(loginButton)
        addSubview(appleButton)
        addSubview(confirmLabel)
        addSubview(termsOfServiceButton)
        addSubview(privacyButton)
        
        NSLayoutConstraint.activate([
            animatedLogoImage.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            animatedLogoImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            animatedLogoImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            animatedLogoImage.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -20),
            
            loginButton.bottomAnchor.constraint(equalTo: appleButton.topAnchor, constant: -25),
            loginButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 20),
            
            appleButton.bottomAnchor.constraint(equalTo: confirmLabel.topAnchor, constant: -20),
            appleButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            appleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            appleButton.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1/MDefaultLayer.widthMultiplier.rawValue),
            
            confirmLabel.bottomAnchor.constraint(equalTo: termsOfServiceButton.topAnchor),
            confirmLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            confirmLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            confirmLabel.heightAnchor.constraint(equalToConstant: 20),
            
            termsOfServiceButton.bottomAnchor.constraint(equalTo: privacyButton.topAnchor, constant: -5),
            termsOfServiceButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            termsOfServiceButton.heightAnchor.constraint(equalToConstant: 20),
            
            privacyButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            privacyButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            privacyButton.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
}
