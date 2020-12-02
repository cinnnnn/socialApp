//
//  CountOfUnreadMessageView.swift
//  socialApp
//
//  Created by Денис Щиголев on 30.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class CountOfUnreadMessageLabel: UILabel {
    
    private var topInset: CGFloat = 0
    private var bottomInset: CGFloat = 0
    private var leftInset: CGFloat = 5
    private var rightInset: CGFloat = 5
    
    init(count: Int) {
        super.init(frame: .zero)
        setupCount(countOfMessages: count)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func drawText(in rect: CGRect) {
//        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
//        super.drawText(in: rect.inset(by: insets))
//    }
//
//    override var intrinsicContentSize: CGSize {
//        let size = super.intrinsicContentSize
//        return CGSize(width: size.width + leftInset + rightInset,
//                      height: size.height + topInset + bottomInset)
//    }
//
//    override var bounds: CGRect {
//        didSet {
//            // ensures this works within stack views if multi-line
//            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
//        }
//    }
    
    
    private func setup(){
        backgroundColor = .myLabelColor()
        clipsToBounds = true
        font = .avenirRegular(size: 14)
        textColor = .myWhiteColor()
        textAlignment = .left
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 4
    }
    
    func setupCount(countOfMessages: Int) {
        isHidden = countOfMessages == 0 ? true : false
        text = " \(countOfMessages) "
    }
}
