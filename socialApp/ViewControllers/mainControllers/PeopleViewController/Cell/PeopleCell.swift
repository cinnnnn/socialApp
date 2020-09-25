//
//  PeopleCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class PeopleCell: UICollectionViewCell, PeopleConfigurationCell {
    
    
    static var reuseID = "PeopleCell"
    
    var person: MPeople?
    weak var delegate: PeopleCellDelegate?
    
    let profileImage = ProfileImageView()
    let nameLabel = UILabel(labelText: "", textFont: .systemFont(ofSize: 16, weight: .bold), textColor: .label)
    let distanceLabel = UILabel(labelText: "0.0km", textFont: .systemFont(ofSize: 16, weight: .light), textColor: .myHeaderColor())
    let topLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.backgroundColor = .myCellColor()
        return view
    }()
    let bottomLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.backgroundColor = .myCellColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let likeButton: UIButton = {
        let button = UIButton()
        
        button.clipsToBounds = true
        button.setTitle("Like", for: .normal)
        button.setTitleColor(.myHeaderColor(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .light)
        return button
    }()
    
    let backView: UIView = {
        let myView = UIView()
        myView.backgroundColor = .systemBackground
        myView.layer.borderColor = UIColor.label.cgColor
        myView.layer.borderWidth = 0
        myView.layer.cornerRadius = 0
        return myView
    }()
    
    let messageBox: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false //for autosize height
        textView.backgroundColor = nil
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .label
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
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
        //MARK: - setup()
    private func setup() {
        likeButton.addTarget(self, action: #selector(pressLike), for: .touchUpInside)
        
        backgroundColor = .systemBackground
        backView.isUserInteractionEnabled = true
        
        backView.translatesAutoresizingMaskIntoConstraints = false
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        messageBox.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        topLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backView)
        addSubview(distanceLabel)
        addSubview(messageBox)
        addSubview(likeButton)
        addSubview(profileImage)
        addSubview(nameLabel)
        addSubview(topLine)
        addSubview(bottomLine)
        
    }
    
    //MARK: - configure()
    func configure(with value: MPeople) {
        person = value
        
        
        messageBox.text = value.advert
        nameLabel.text = value.displayName == "" ? "Анон" : value.displayName
        
        let imageURL = URL(string: value.userImage)
        profileImage.profileImage.sd_setImage(with: imageURL, completed: nil)
        
        //        let likeImage = value.like ? nil : #imageLiteral(resourceName: "Heart")
        //        likeButton.setImage(likeImage, for: .normal)
        
    }
    
    override func prepareForReuse() {
        profileImage.profileImage.image = nil
    }
    private func setupConstraints(){
        
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: backView.bottomAnchor),
            
            profileImage.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 25),
            profileImage.topAnchor.constraint(equalTo: backView.topAnchor, constant: 8),
            profileImage.widthAnchor.constraint(equalToConstant: 50),
            profileImage.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -25),
            nameLabel.topAnchor.constraint(equalTo: profileImage.topAnchor),
            
            messageBox.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 3),
            messageBox.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -25),
            messageBox.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
           
            likeButton.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -25),
            likeButton.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -4),
            
            backView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backView.topAnchor.constraint(equalTo: topAnchor, constant: -1),
            backView.bottomAnchor.constraint(equalTo: messageBox.bottomAnchor, constant: 35),
            
            distanceLabel.leadingAnchor.constraint(equalTo: messageBox.leadingAnchor, constant: 5),
            distanceLabel.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -8),
            
            topLine.topAnchor.constraint(equalTo: topAnchor),
            topLine.heightAnchor.constraint(equalToConstant: 0.5),
            topLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            topLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 0.5),
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        likeButton.layer.cornerRadius = likeButton.frame.height / 2
        setupConstraints()
    }
    
}

