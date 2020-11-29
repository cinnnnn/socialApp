//
//  LoadingView.swift
//  socialApp
//
//  Created by Денис Щиголев on 16.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    var logoImage: AnimationCustomView?
    
    convenience init(name: String, isHidden: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) {
        self.init()
        self.logoImage = AnimationCustomView(name: name, loopMode: .loop, contentMode: contentMode)
        self.isHidden = isHidden
        if !isHidden {
            logoImage?.animationView.play()
        }
        setup()
        setupConstraints()
    }
    
    
    private func setup() {
        backgroundColor = .myWhiteColor()
    }
    
    func show() {
        isHidden = false
        logoImage?.layer.opacity = 1
        logoImage?.animationView.play()
    }
    
    func hide() {
        UIView.animate(withDuration: 1) { [weak self] in
            self?.logoImage?.layer.opacity = 0
        } completion: { [weak self] isComplite in
            if isComplite {
                self?.logoImage?.animationView.stop()
                self?.isHidden = true
            }
        }
    }
}

extension LoadingView {
    //MARK: SetupConstraints
    private func setupConstraints() {
        guard let logoImage = logoImage else { return }
        addSubview(logoImage)
        
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        logoImage.topAnchor.constraint(equalTo: topAnchor),
        logoImage.leadingAnchor.constraint(equalTo: leadingAnchor),
        logoImage.trailingAnchor.constraint(equalTo: trailingAnchor),
        logoImage.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}


