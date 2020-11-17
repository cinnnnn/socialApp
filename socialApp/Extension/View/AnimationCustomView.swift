//
//  AnimationCustomView.swift
//  socialApp
//
//  Created by Денис Щиголев on 21.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import Lottie

class AnimationCustomView: UIView {
    
    let animationView = AnimationView()
    
    convenience init(name: String, loopMode: LottieLoopMode, contentMode: UIView.ContentMode) {
        self.init()
        animationView.animation = Animation.named(name)
        animationView.loopMode = loopMode
        animationView.contentMode = contentMode
        
        setup()
        setupConstraints()
    }
    
    private func setup() {
        animationView.animationSpeed = 1
        animationView.backgroundBehavior = .pauseAndRestore
    }
    
    private func setupConstraints() {
        addSubview(animationView)
        translatesAutoresizingMaskIntoConstraints = false
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: trailingAnchor),
            topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: bottomAnchor),
            animationView.topAnchor.constraint(equalTo: topAnchor),
            animationView.bottomAnchor.constraint(equalTo: bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
    }
}
