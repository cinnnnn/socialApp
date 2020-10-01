//
//  PeopleCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class PeopleCell: UICollectionViewCell,PeopleConfigurationCell, UIScrollViewDelegate {

    static var reuseID = "PeopleCell"
    
    var person: MPeople?
    weak var delegate: PeopleCellDelegate?
    let cellView = PeopleCellView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with value: MPeople) {
        let imageURL = URL(string: value.userImage)
        cellView.profileImage.sd_setImage(with: imageURL, completed: nil)
        
    }

    //MARK: setup()
    private func setup() {
        backgroundColor = nil

    }
    
    override func prepareForReuse() {
        cellView.profileImage.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}

//MARK: objc
extension PeopleCell {
    
    @objc func pressLike() {
        
        //        person?.like.toggle()
        //
        //        guard let like = person?.like else { fatalError("Unknown like state")}
        //        let likeImage = like ? nil : #imageLiteral(resourceName: "Heart")
        //        likeButton.setImage(likeImage, for: .normal)
        //
        //        guard let newPerson = person else { fatalError("person unknown")}
        //        delegate?.likeTupped(user: newPerson)
        //        print("Like in cell")
        
    }
}

extension PeopleCell {
    
    //MARK: setupConstraints
    private func setupConstraints(){
        
        addSubview(cellView)
        cellView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellView.topAnchor.constraint(equalTo: topAnchor),
            cellView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
}
