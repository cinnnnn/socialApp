//
//  PeopleScrollView.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class PeopleView: UIView {
    
    let scrollView = UIScrollView()
    let galleryScrollView = GalleryView(profileImage: "", gallery: [:], showPrivate: false, showProtectButton: true)
    let peopleName = UILabel(labelText: "Name", textFont: .avenirBold(size: 30), linesCount: 0)
    var infoLabel = UILabel(labelText: "0.00KM", textFont: .avenirRegular(size: 14),textColor: .myGrayColor())
    var distanceLabel = UILabel(labelText: "", textFont: .avenirRegular(size: 14),textColor: .myGrayColor())
    let infoPremium = UILabel(labelText: "",
                              textFont: .avenirBold(size: 14),
                              textColor: .mySecondSatColor(),
                              aligment: .left,
                              linesCount: 0)
    var advertLabel = UILabel(labelText: "",
                              textFont: .avenirRegular(size: 18),
                              textColor: .myGrayColor(),
                              aligment: .left,
                              linesCount: 5)
    let geoImage = UIImageView(systemName: "location.circle", config: .init(font: .avenirRegular(size: 14)), tint: .myGrayColor())
    let infoImage = UIImageView(systemName: "info.circle", config: .init(font: .avenirRegular(size: 14)), tint: .myGrayColor())
    let timeImage = UIImageView(systemName: "timer", config: .init(font: .avenirRegular(size: 14)), tint: .myGrayColor())
    let timeButton = OneLineButton(info: "Последняя активность")
    let dislikeButton = LikeDisklikeButton(image: UIImage(systemName: "xmark",
                                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .large)) ?? #imageLiteral(resourceName: "reject"),
                                 tintColor: .myLabelColor(),
                                 backgroundColor: .myLightGrayColor())
    let likeButton = LikeDisklikeButton(image: UIImage(systemName: "suit.heart",
                                             withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .large)) ?? #imageLiteral(resourceName: "reject"),
                              tintColor: .myWhiteColor(),
                              backgroundColor: .myLabelColor())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        scrollView.updateContentView()
        scrollView.showsVerticalScrollIndicator = false
    }
    
    func configure(with value: MPeople, currentPeople: MPeople, showPrivatePhoto: Bool, complition: @escaping()-> Void) {
        peopleName.text = value.displayName
        if value.isGoldMember ||  value.isTestUser{
            infoPremium.text = "Flava premium"
        } else {
            infoPremium.text = ""
        }
        galleryScrollView.setupImages(profileImage: value.userImage,
                                      gallery: value.gallery,
                                      showPrivate: showPrivatePhoto,
                                      showProtectButton: !showPrivatePhoto) {
            complition()
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 0.8
        paragraph.alignment = .left
        
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle : paragraph
        ]
        
        advertLabel.attributedText = NSMutableAttributedString(string: value.advert, attributes: attributes)
        
        infoLabel.text = [value.dateOfBirth.getStringAge(), value.gender, value.sexuality].joined(separator: ", ").lowercased()
        
        likeButton.actionPeople = value
        dislikeButton.actionPeople = value
        
        let locationIndex = value.searchSettings[MSearchSettings.currentLocation.rawValue] ?? MSearchSettings.currentLocation.defaultValue
        let virtualLocation = MVirtualLocation(rawValue: locationIndex)
        switch virtualLocation {
        case .current:
            distanceLabel.text = "\(value.distance) км от тебя"
        case .forPlay:
            distanceLabel.text = MVirtualLocation.forPlay.description()
        default:
            distanceLabel.text = "\(value.distance) км от тебя"
        }
        
        if currentPeople.isGoldMember || currentPeople.isTestUser {
            if value.lastActiveDate.checkIsToday() {
                timeButton.infoLabel.text = "Недавняя активность в \(value.lastActiveDate.getFormattedDate(format: "HH:mm", withTime: true))"
            } else {
                timeButton.infoLabel.text = "Последняя активность: \(value.lastActiveDate.getShortFormattedDate())"
            }
            timeButton.isEnabled = false
        } else {
            timeButton.infoLabel.text = "Последняя активность"
            timeButton.isEnabled = true
        }
        galleryScrollView.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.updateContentView(bottomOffset: 60)
        likeButton.layer.cornerRadius = likeButton.frame.width / 2
        dislikeButton.layer.cornerRadius = dislikeButton.frame.width / 2
    }
}

extension PeopleView {
    private func setupConstraints() {
        
        addSubview(scrollView)
        scrollView.addSubview(galleryScrollView)
        scrollView.addSubview(peopleName)
        scrollView.addSubview(infoPremium)
        scrollView.addSubview(infoLabel)
        scrollView.addSubview(distanceLabel)
        scrollView.addSubview(advertLabel)
        scrollView.addSubview(geoImage)
        scrollView.addSubview(infoImage)
        scrollView.addSubview(timeImage)
        scrollView.addSubview(timeButton)
        scrollView.addSubview(likeButton)
        scrollView.addSubview(dislikeButton)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        galleryScrollView.translatesAutoresizingMaskIntoConstraints = false
        peopleName.translatesAutoresizingMaskIntoConstraints = false
        infoPremium.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        advertLabel.translatesAutoresizingMaskIntoConstraints = false
        geoImage.translatesAutoresizingMaskIntoConstraints = false
        infoImage.translatesAutoresizingMaskIntoConstraints = false
        timeImage.translatesAutoresizingMaskIntoConstraints = false
        timeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        dislikeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            galleryScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            galleryScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            galleryScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            galleryScrollView.heightAnchor.constraint(equalTo: galleryScrollView.widthAnchor, multiplier: 1.2),
            
            peopleName.leadingAnchor.constraint(equalTo: leadingAnchor),
            peopleName.trailingAnchor.constraint(equalTo: trailingAnchor),
            peopleName.topAnchor.constraint(equalTo: galleryScrollView.bottomAnchor, constant: 10),
            
            infoPremium.topAnchor.constraint(equalTo: peopleName.bottomAnchor),
            infoPremium.leadingAnchor.constraint(equalTo: peopleName.leadingAnchor),
            infoPremium.trailingAnchor.constraint(equalTo: peopleName.trailingAnchor),
            
            infoImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            infoImage.topAnchor.constraint(equalTo: infoPremium.bottomAnchor, constant: 10),
            
            infoLabel.leadingAnchor.constraint(equalTo: infoImage.trailingAnchor, constant: 7),
            infoLabel.topAnchor.constraint(equalTo: infoImage.topAnchor),
            
            geoImage.leadingAnchor.constraint(equalTo: infoImage.leadingAnchor),
            geoImage.topAnchor.constraint(equalTo: infoLabel.bottomAnchor),
            
            distanceLabel.leadingAnchor.constraint(equalTo: geoImage.trailingAnchor, constant: 7),
            distanceLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor),
            
            timeImage.leadingAnchor.constraint(equalTo: infoImage.leadingAnchor),
            timeImage.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor),
            
            timeButton.leadingAnchor.constraint(equalTo: timeImage.trailingAnchor, constant: 7),
            timeButton.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor),
            
            advertLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            advertLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            advertLabel.topAnchor.constraint(equalTo: timeButton.bottomAnchor, constant: 10),
            
            likeButton.trailingAnchor.constraint(equalTo: galleryScrollView.trailingAnchor),
            likeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            likeButton.heightAnchor.constraint(equalTo: galleryScrollView.widthAnchor, multiplier: 0.15),
            likeButton.widthAnchor.constraint(equalTo: likeButton.heightAnchor),
            
            dislikeButton.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -20),
            dislikeButton.bottomAnchor.constraint(equalTo: likeButton.bottomAnchor),
            dislikeButton.heightAnchor.constraint(equalTo: galleryScrollView.widthAnchor, multiplier: 0.15),
            dislikeButton.widthAnchor.constraint(equalTo: dislikeButton.heightAnchor),
        ])
    }
}


