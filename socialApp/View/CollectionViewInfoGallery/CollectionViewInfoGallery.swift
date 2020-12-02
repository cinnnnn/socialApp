//
//  CollectionViewInfoGallery.swift
//  socialApp
//
//  Created by Денис Щиголев on 22.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import CHIPageControl

class CollectionViewInfoGallery: UIView {
    private var collectionView: UICollectionView?
    private let collectionHeader = UILabel(labelText: "", textFont: .avenirBold(size: 34), textColor: .white)
    private let pageControl = CHIPageControlAleppo()
    private var elements: [MCollectionViewGalleryElement]
    private var timer: Timer?
    
    init(elements: [MCollectionViewGalleryElement], header: String?){
        self.elements = elements
        super.init(frame: .zero)
        setup()
        setupConstraints()
        
        guard let header = header else { return }
        collectionHeader.text = header
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBackgroundColor(color: UIColor) {
        if let collectionView = collectionView {
            collectionView.backgroundColor = color
        }
    }
    
    func setupHeader(text: String) {
        collectionHeader.text = text
    }
    
    func setupHeaderColor(color: UIColor) {
        collectionHeader.textColor = color
    }
    
    func setupHeaderFont(font: UIFont) {
        collectionHeader.font = font
    }
}

extension CollectionViewInfoGallery {
    private func setup() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        
        if let collectionView = collectionView {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(CollectionViewInfoCell.self, forCellWithReuseIdentifier: CollectionViewInfoCell.reuseID)
        }
        
        pageControl.numberOfPages = elements.count
        pageControl.hidesForSinglePage = false
        pageControl.tintColor = .white
        pageControl.radius = 4
        
        if timer == nil {
            
            
        }
    }
}


extension CollectionViewInfoGallery: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let progress = scrollView.contentOffset.x / scrollView.frame.width
        pageControl.progress = Double(progress)
    }
}

extension CollectionViewInfoGallery: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewInfoCell.reuseID,
                                                            for: indexPath) as? CollectionViewInfoCell else { fatalError("Can't cast to CollectionViewInfoCell") }
        cell.configure(item: elements[indexPath.item])
        return cell
    }
}

extension CollectionViewInfoGallery: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        CGSize(width: collectionView.frame.width,
               height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension CollectionViewInfoGallery {
    private func setupConstraints() {
        guard let collectionView = collectionView else { fatalError("collectionView in nil")}
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        collectionHeader.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(collectionView)
        addSubview(collectionHeader)
        addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            collectionHeader.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            collectionHeader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            pageControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])
    }
}
