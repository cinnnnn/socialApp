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
        animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
