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
    
    private let scrollView = UIScrollView()
    private let galleryScrollView = GalleryView(profileImage: "", gallery: [:], showPrivate: false, showProtectButton: true)
    private let peopleName = UILabel(labelText: "Name", textFont: .avenirBold(size: 30), linesCount: 0)
    private let infoLabel = UILabel(labelText: "0.00KM", textFont: .avenirRegular(size: 14),textColor: .myGrayColor())
    private let distanceLabel = UILabel(labelText: "", textFont: .avenirRegular(size: 14),textColor: .myGrayColor())
    private let infoPremium = UILabel(labelText: "",
                              textFont: .avenirBold(size: 14),
                              textColor: .mySecondSatColor(),
                              aligment: .left,
                              linesCount: 0)
    private var advertLabel = UILabel(labelText: "",
                              textFont: .avenirRegular(size: 16),
                              textColor: .myLabelColor(),
                              aligment: .left,
                              linesCount: 0)
    private let geoImage = UIImageView(systemName: "location.circle", config: .init(font: .avenirRegular(size: 14)), tint: .myGrayColor())
    private let infoImage = UIImageView(systemName: "info.circle", config: .init(font: .avenirRegular(size: 14)), tint: .myGrayColor())
    private let timeImage = UIImageView(systemName: "timer", config: .init(font: .avenirRegular(size: 14)), tint: .myGrayColor())
    
    private let interestsHeader = UILabel(labelText: "Интересы",
                                  textFont: .avenirRegular(size: 14),
                                  textColor: .myGrayColor())
    private let desiresHeader = UILabel(labelText: "Желания",
                                textFont: .avenirRegular(size: 14),
                                textColor: .myGrayColor())
    private let interestLabel = UILabel(labelText: "",
                                textFont: .avenirRegular(size: 16),
                                textColor: .myLabelColor(),
                                linesCount: 0)
    private let desiresLabel = UILabel(labelText: "",
                               textFont: .avenirRegular(size: 16),
                               textColor: .myLabelColor(),
                               linesCount: 0)
    let timeButton = OneLineButton(info: "Последняя активность",
                                   textColor: .myGrayColor())
    let animateDislikeButton = AnimateDislikeButton()
    let animateLikeButton = AnimateLikeButton()
    
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
    
    //MARK: configure
    func configure(with value: MPeople, currentPeople: MPeople, showPrivatePhoto: Bool, complition: @escaping()-> Void) {
        peopleName.text = value.displayName
        
        if value.isGoldMember ||  value.isTestUser{
            infoPremium.text = "Flava premium"
        } else {
            infoPremium.text = ""
        }
        
        //setup image
        galleryScrollView.setupImages(profileImage: value.userImage,
                                      gallery: value.gallery,
                                      showPrivate: showPrivatePhoto,
                                      showProtectButton: !showPrivatePhoto) {
            complition()
        }
        galleryScrollView.setNeedsLayout()
        
        //setup advert
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 0.8
        paragraph.alignment = .left
        
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle : paragraph
        ]
        
        advertLabel.attributedText = NSMutableAttributedString(string: value.advert, attributes: attributes)
        
        //setup info
        infoLabel.text = [value.dateOfBirth.getStringAge(), value.gender, value.sexuality].joined(separator: ", ").lowercased()
        
        //setup LikeDislikePeopleButton
        animateLikeButton.actionPeople = value
        animateDislikeButton.actionPeople = value
        
        //setup location
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
        
        //setup last active date
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
        
        //setup interests
        if value.interests.isEmpty{
            interestsHeader.text = ""
        } else {
            interestLabel.text = value.interests.joined(separator: ", ")
        }
        
        
        //setup desires
        if value.desires.isEmpty {
            desiresHeader.text = ""
        } else {
            desiresLabel.text = value.desires.joined(separator: ", ")
        }
      
    }
    
    //prepareForRenew
    func prepareForRenew() {
        interestsHeader.text = "Интересы"
        desiresHeader.text = "Желания"
        interestLabel.text = ""
        desiresLabel.text = ""
        galleryScrollView.prepareReuseScrollView()
        advertLabel.text = ""
        animateDislikeButton.setupFirstFrame()
        animateDislikeButton.setupFirstFrame()
    }
    
    //layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.updateContentView(bottomOffset: 60)
    }
}

//MARK: setupConstraints
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
        scrollView.addSubview(interestsHeader)
        scrollView.addSubview(interestLabel)
        scrollView.addSubview(desiresHeader)
        scrollView.addSubview(desiresLabel)
        addSubview(animateLikeButton)
        addSubview(animateDislikeButton)
        
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
        interestsHeader.translatesAutoresizingMaskIntoConstraints = false
        interestLabel.translatesAutoresizingMaskIntoConstraints = false
        desiresHeader.translatesAutoresizingMaskIntoConstraints = false
        desiresLabel.translatesAutoresizingMaskIntoConstraints = false
        animateLikeButton.translatesAutoresizingMaskIntoConstraints = false
        animateDislikeButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            interestsHeader.leadingAnchor.constraint(equalTo: leadingAnchor),
            interestsHeader.trailingAnchor.constraint(equalTo: trailingAnchor),
            interestsHeader.topAnchor.constraint(equalTo: advertLabel.bottomAnchor, constant: 20),
            
            interestLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            interestLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            interestLabel.topAnchor.constraint(equalTo: interestsHeader.bottomAnchor, constant: 10),
            
            desiresHeader.leadingAnchor.constraint(equalTo: leadingAnchor),
            desiresHeader.trailingAnchor.constraint(equalTo: trailingAnchor),
            desiresHeader.topAnchor.constraint(equalTo: interestLabel.bottomAnchor, constant: 20),
            
            desiresLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            desiresLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            desiresLabel.topAnchor.constraint(equalTo: desiresHeader.bottomAnchor, constant: 10),
            
            animateLikeButton.trailingAnchor.constraint(equalTo: galleryScrollView.trailingAnchor),
            animateLikeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            animateLikeButton.heightAnchor.constraint(equalTo: galleryScrollView.widthAnchor, multiplier: 0.15),
            animateLikeButton.widthAnchor.constraint(equalTo: animateLikeButton.heightAnchor),
            
            animateDislikeButton.trailingAnchor.constraint(equalTo: animateLikeButton.leadingAnchor, constant: -20),
            animateDislikeButton.bottomAnchor.constraint(equalTo: animateLikeButton.bottomAnchor),
            animateDislikeButton.heightAnchor.constraint(equalTo: galleryScrollView.widthAnchor, multiplier: 0.15),
            animateDislikeButton.widthAnchor.constraint(equalTo: animateDislikeButton.heightAnchor),
        ])
    }
}


