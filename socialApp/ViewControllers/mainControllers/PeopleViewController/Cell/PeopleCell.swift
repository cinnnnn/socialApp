//
//  PeopleCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class PeopleCell: UICollectionViewCell,PeopleConfigurationCell {

    static var reuseID = "PeopleCell"
    
    var person: MPeople?
    weak var delegate: PeopleCellDelegate?
    let scrollView = UIScrollView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: setup()
    private func setup() {
        backgroundColor = nil
        scrollView.backgroundColor = .red
        scrollView.isPagingEnabled = true
        
    }
    
    func configure(with value: MPeople, complition: @escaping()-> Void) {
        guard let imageURL = URL(string: value.userImage) else { fatalError("Incorrect URL")}
        setupImages(images:[imageURL])
    }
    
    override func prepareForReuse() {
        scrollView.subviews.forEach { view in
            if let view = view as? UIImageView {
                view.removeFromSuperview()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var countOfView = 0
        for view in scrollView.subviews {
            if let view = view as? UIImageView {
                
                view.frame = CGRect(x: 0,
                                    y: scrollView.frame.height * CGFloat(countOfView),
                                    width: scrollView.frame.width,
                                    height: scrollView.frame.height)
                countOfView += 1
            }
        }
        scrollView.contentSize.height = scrollView.frame.height * CGFloat(countOfView + 1)
    }
}

extension PeopleCell {
    private func setupImages(images:[URL]) {
        
        for imageURL in images {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.sd_setImage(with: imageURL, completed: nil)
            scrollView.addSubview(imageView)
        }
    }
}

//MARK: objc
extension PeopleCell {
    
    @objc func pressLike() {
        
    }
}

extension PeopleCell {
    
    private func setupConstraints() {
        
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
}
