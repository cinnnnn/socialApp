//
//  InterestsSelectionView.swift
//  socialApp
//
//  Created by Денис Щиголев on 12.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class InterestsSelectionView: UIView {
    
    private let scrollView = UIScrollView()
    private let headerLabel = UILabel(labelText: MLabels.aboutSelectionHeader.rawValue, textFont: .avenirBold(size: 24),linesCount: 0)
    private let subHeaderLabel = UILabel(labelText: MLabels.interestSelectionSubHeader.rawValue,
                                 textFont: .avenirRegular(size: 16),
                                 textColor: .myGrayColor(),
                                 linesCount: 0)
    private var aboutTextView = UITextView(text: "", isEditable: true)
    private var selectedVisibleYValue: CGFloat?
    private var keybordMinYValue:CGFloat?
   
    init() {
        super.init(frame: .zero)
        setup()
        registerNotification()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getInterestsText() -> String {
        if let interestsText = aboutTextView.text {
            return interestsText
        } else {
            return ""
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.updateContentView(bottomOffset: 0)
    }
    
    private func setup() {
        aboutTextView.addDoneButton(onDone: (target: self, action: #selector(scrollTapped)))
        aboutTextView.delegate = self
        scrollView.addSingleTapRecognizer(target: self, selector: #selector(scrollTapped))
    }
    
    private func registerNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateView(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateView(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func scrollTapped() {
        aboutTextView.resignFirstResponder()
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    //MARK: updateView
    @objc private func updateView(notification: Notification?) {
        
        let info = notification?.userInfo
        guard let keyboardSize = info?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let size = keyboardSize.cgRectValue
        let toolBarHight:CGFloat = 100
        keybordMinYValue = size.minY
        
        if notification?.name == UIResponder.keyboardWillShowNotification  {
            
            guard let value = selectedVisibleYValue else { return }
            let scrollValue  = value - size.minY + toolBarHight
            let scrollPoint = CGPoint(x: 0, y: scrollValue)
            if value > keybordMinYValue ?? 0 {
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
    //MARK: forceUpdateContentOffset
    private func forceUpdateContentOffset(inset: CGFloat) {
        guard let keyboardYValue = keybordMinYValue else { return }
        let toolBarHight:CGFloat = 100
        guard let value = selectedVisibleYValue else { return }
        let scrollValue  = value - keyboardYValue + toolBarHight + inset
        let scrollPoint = CGPoint(x: 0, y: scrollValue)
        if value > keybordMinYValue ?? 0 {
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
    }
}

extension InterestsSelectionView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        selectedVisibleYValue = textView.frame.maxY
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        selectedVisibleYValue = textView.frame.maxY
        let textViewToolBarHight:CGFloat = 20
        forceUpdateContentOffset(inset: textViewToolBarHight)
        setNeedsLayout()
    }
}

extension InterestsSelectionView {
    
    private func setupConstraints() {
        addSubview(scrollView)
        scrollView.addSubview(headerLabel)
        scrollView.addSubview(subHeaderLabel)
        scrollView.addSubview(aboutTextView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        subHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            headerLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            
            subHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            subHeaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            subHeaderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            
            aboutTextView.topAnchor.constraint(equalTo: subHeaderLabel.bottomAnchor, constant: 25),
            aboutTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            aboutTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
        ])
        
    }
}
