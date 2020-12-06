//
//  TagsSetupView.swift
//  socialApp
//
//  Created by Денис Щиголев on 27.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class TagsSetupView: UIView {
    
    private let scrollView = UIScrollView()
    private var keybordMinYValue: CGFloat?
    private let headerLabel = UILabel(labelText: "", textFont: .avenirBold(size: 24),linesCount: 0)
    private var tagsCollectionView: TagsCollectionView?
    
    init(unselectTags: [String], tagsHeader: String, viewHeader: String){
        super.init(frame: .zero)
        headerLabel.text = viewHeader
        
        tagsCollectionView = TagsCollectionView(unselectTags: unselectTags,
                                                selectTags: [],
                                                headerText: tagsHeader,
                                                headerFont: .avenirBold(size: 16),
                                                headerColor: .myLabelColor(),
                                                textFieldPlaceholder: "Добавь свои")
        setup()
        setupConstraints()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        backgroundColor = .myWhiteColor()
        tagsCollectionView?.tagsDelegate = self
      
        
        scrollView.addSingleTapRecognizer(target: self,
                                          selector: #selector(singleTap))
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateView(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateView(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func updateScrollView() {
        scrollView.updateContentView(bottomOffset: 20)
    }
    
    func getSelectedTags() -> [String] {
        tagsCollectionView?.getSelectedTags() ?? []
    }
    
    func update() {
        tagsCollectionView?.firstSetup()
    }
    
}

//MARK: obcj
extension TagsSetupView {
    
    @objc private func singleTap() {
        endEditing(true)
    }
    
    //MARK: updateView
    @objc func updateView(notification: Notification?) {
        
        guard let tagsCollectionView = tagsCollectionView else { return }
        
        let info = notification?.userInfo
        guard let keyboardSize = info?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let size = keyboardSize.cgRectValue
        let toolBarHight:CGFloat = 100
        
        
        if notification?.name == UIResponder.keyboardWillShowNotification  {
            
            keybordMinYValue = size.minY
            let value = tagsCollectionView.frame.maxY
            let scrollValue  = value - size.minY + toolBarHight
            //if view under keyboard
            if value > size.minY - toolBarHight {
                let scrollPoint = CGPoint(x: 0, y: scrollValue)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
        
        if notification?.name == UIResponder.keyboardWillHideNotification {
            keybordMinYValue = nil
            let value = tagsCollectionView.frame.maxY
            var scrollValue  = value - scrollView.frame.height
            if scrollValue < 0 {
                scrollValue = 0
            }
            let scrollPoint = CGPoint(x: 0, y: scrollValue)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
    }
    
    //MARK: forceUpdateContentOffset
    private func forceUpdateContentOffset(inset: CGFloat) {
        
        guard let tagsCollectionView = tagsCollectionView else { return }
        
        let value = tagsCollectionView.frame.maxY
        var scrollValue  = value - scrollView.frame.height + inset
        //if keyboard is open
        if let keybordHight = keybordMinYValue {
            let toolBarHight:CGFloat = 100
            //if view under keyboard
            if value > keybordHight + toolBarHight {
                scrollValue = value - keybordHight + inset + toolBarHight
            } else {
                scrollValue = 0
            }
        }
        
        if scrollValue > inset {
            let scrollPoint = CGPoint(x: 0, y: scrollValue)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
        
    }
}

//MARK: TagsCollectionViewDelegate
extension TagsSetupView: TagsCollectionViewDelegate {

    func tagTextConstraintsDidChange(tagsCollectionView: TagsCollectionView) {
        forceUpdateContentOffset(inset: 70)
        scrollView.updateContentView()
        setNeedsLayout()
    }
}

//MARK: setupConstraints
extension TagsSetupView {
    private func setupConstraints() {
        guard let tagsCollectionView = tagsCollectionView else { return }
        
        addSubview(scrollView)
        scrollView.addSubview(headerLabel)
        scrollView.addSubview(tagsCollectionView)
       
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            headerLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            
            tagsCollectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            tagsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            tagsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            tagsCollectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
    }
}
