//
//  AnimateDislikeButton.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import Lottie

class AnimateDislikeButton: UIButton, LikeDislikePeopleButton {
    
    private var animationImage = AnimationView()
    
    var actionPeople: MPeople?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }

}

extension AnimateDislikeButton {
    func play(complition: @escaping()->()) {
        animationImage.play(fromFrame: 0, toFrame: 25, loopMode: .playOnce) { isComplite in
            if isComplite {
                complition()
            }
        }
    }
    
    func setupFirstFrame() {
        animationImage.currentFrame = 0
    }
    
    private func setup() {
        backgroundColor = UIColor.myLightGrayColor().withAlphaComponent(0.5)

        animationImage.isUserInteractionEnabled = false
        animationImage.animation = Animation.named("crossReady")
        animationImage.loopMode = .playOnce
        animationImage.animationSpeed = 2
        animationImage.contentMode = .scaleAspectFit
        
    }

    
    private func setupConstraints() {
        animationImage.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(animationImage)
        
        NSLayoutConstraint.activate([
            animationImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            animationImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationImage.widthAnchor.constraint(equalTo: widthAnchor),
            animationImage.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
}
