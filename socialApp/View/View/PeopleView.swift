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
    private var advertLabel = UILabel(labelText: " ",
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
    private let interestLabel = UILabel(labelText: " ",
                                textFont: .avenirRegular(size: 16),
                                textColor: .myLabelColor(),
                                linesCount: 0)
    private let desiresLabel = UILabel(labelText: " ",
                               textFont: .avenirRegular(size: 16),
                               textColor: .myLabelColor(),
                               linesCount: 0)
    private var reportTopConstraint: NSLayoutConstraint?
    let timeButton = OneLineButton(info: "Последняя активность",
                                   textColor: .myGrayColor())
    let animateDislikeButton = AnimateDislikeButton()
    let animateLikeButton = AnimateLikeButton()
    let reportButton = ReportPeopleOneLineButton(info: "Пожаловаться",
                                                 textColor: .myLabelColor(),
                                                 lineColor: .myLabelColor())
    
    weak var buttonDelegate: PeopleButtonTappedDelegate?
    
     init(withStatusBar: Bool = true) {
        super.init(frame: .zero)
        
        if !withStatusBar {
            let statusBarHieght = UIApplication.statusBarHeight
            scrollView.contentInset = UIEdgeInsets(top: -statusBarHieght, left: 0, bottom: 0, right: 0)
        }
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: setup
    private func setup() {
        scrollView.backgroundColor = .myWhiteColor()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        animateLikeButton.addTarget(self, action: #selector(likeTapped(sender:)), for: .touchUpInside)
        animateDislikeButton.addTarget(self, action: #selector(dislikeTapped(sender:)), for: .touchUpInside)
        timeButton.addTarget(self, action: #selector(timeTapped), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(reportTapped(sender:)), for: .touchUpInside)
    }
    
    
    //MARK: objc
    @objc private func likeTapped(sender: Any) {
        guard let sender = sender as? LikeDislikePeopleButton else { return }
        guard let people = sender.actionPeople else { return }
        
        sender.play { [weak self] in
            self?.buttonDelegate?.likePeople(people: people)
        }
    }
    
    @objc private func dislikeTapped(sender: Any) {
        guard let sender = sender as? LikeDislikePeopleButton else { return }
        guard let people = sender.actionPeople else { return }
        
        sender.play { [weak self] in
            self?.buttonDelegate?.dislikePeople(people: people)
        }
    }
    
    @objc private func timeTapped() {
        buttonDelegate?.timeTapped()
    }
    
    @objc private func reportTapped(sender: Any) {
        guard let sender = sender as? ReportPeopleButton else { return }
        guard let people = sender.people else { return }
        buttonDelegate?.reportTapped(people: people)
    }
  
    //MARK: configure
    func configure(with value: MPeople,
                   currentPeople: MPeople,
                   showPrivatePhoto: Bool,
                   buttonDelegate: PeopleButtonTappedDelegate?,
                   complition: @escaping()-> Void) {
        
        self.buttonDelegate = buttonDelegate
        
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
        reportButton.people = value
        
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
                timeButton.setText(text: "Недавняя активность в \(value.lastActiveDate.getFormattedDate(format: "HH:mm", withTime: true))")
            } else {
                timeButton.setText(text: "Последняя активность: \(value.lastActiveDate.getShortFormattedDate())")
            }
            timeButton.isEnabled = false
        } else {
            timeButton.setText(text: "Последняя активность")
            timeButton.isEnabled = true
        }
        
        //setup interests
        if value.interests.isEmpty{
            interestsHeader.text = ""
            interestLabel.text = ""
        } else {
            interestsHeader.text = "Интересы"
            interestLabel.text = value.interests.joined(separator: ", ")
        }
        
        
        //setup desires
        if value.desires.isEmpty {
            desiresHeader.text = ""
            desiresLabel.text = ""
        } else {
            desiresHeader.text = "Желания"
            desiresLabel.text = value.desires.joined(separator: ", ")
        }
        
        galleryScrollView.setNeedsLayout()
    }
    
    //prepareForRenew
    func prepareForRenew() {
//        interestsHeader.text = "Интересы"
//        desiresHeader.text = "Желания"
//        interestLabel.text = " "
//        desiresLabel.text = " "
        galleryScrollView.prepareReuseScrollView()
 //      advertLabel.text = " "
        animateDislikeButton.setupFirstFrame()
        animateDislikeButton.setupFirstFrame()
    }
    
    //layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
       // scrollView.updateContentView(bottomOffset: 0)
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
        scrollView.addSubview(reportButton)
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
        reportButton.translatesAutoresizingMaskIntoConstraints = false
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
            
            peopleName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            peopleName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            peopleName.topAnchor.constraint(equalTo: galleryScrollView.bottomAnchor, constant: 10),
            
            infoPremium.topAnchor.constraint(equalTo: peopleName.bottomAnchor),
            infoPremium.leadingAnchor.constraint(equalTo: peopleName.leadingAnchor),
            infoPremium.trailingAnchor.constraint(equalTo: peopleName.trailingAnchor),
            
            infoImage.leadingAnchor.constraint(equalTo: peopleName.leadingAnchor),
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
            
            advertLabel.leadingAnchor.constraint(equalTo: peopleName.leadingAnchor),
            advertLabel.trailingAnchor.constraint(equalTo: peopleName.trailingAnchor),
            advertLabel.topAnchor.constraint(equalTo: timeButton.bottomAnchor, constant: 10),
            
            interestsHeader.leadingAnchor.constraint(equalTo: peopleName.leadingAnchor),
            interestsHeader.trailingAnchor.constraint(equalTo: peopleName.trailingAnchor),
            interestsHeader.topAnchor.constraint(equalTo: advertLabel.bottomAnchor, constant: 20),
            
            interestLabel.leadingAnchor.constraint(equalTo: peopleName.leadingAnchor),
            interestLabel.trailingAnchor.constraint(equalTo: peopleName.trailingAnchor),
            interestLabel.topAnchor.constraint(equalTo: interestsHeader.bottomAnchor, constant: 10),
            
            desiresHeader.leadingAnchor.constraint(equalTo: peopleName.leadingAnchor),
            desiresHeader.trailingAnchor.constraint(equalTo: peopleName.trailingAnchor),
            desiresHeader.topAnchor.constraint(equalTo: interestLabel.bottomAnchor, constant: 20),
            
            desiresLabel.leadingAnchor.constraint(equalTo: peopleName.leadingAnchor),
            desiresLabel.trailingAnchor.constraint(equalTo: peopleName.trailingAnchor),
            desiresLabel.topAnchor.constraint(equalTo: desiresHeader.bottomAnchor, constant: 10),
            
            reportButton.leadingAnchor.constraint(equalTo: peopleName.leadingAnchor),
            reportButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            
            animateLikeButton.trailingAnchor.constraint(equalTo: peopleName.trailingAnchor ),
            animateLikeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            animateLikeButton.heightAnchor.constraint(equalTo: galleryScrollView.widthAnchor, multiplier: 0.15),
            animateLikeButton.widthAnchor.constraint(equalTo: animateLikeButton.heightAnchor),
            
            animateDislikeButton.trailingAnchor.constraint(equalTo: animateLikeButton.leadingAnchor, constant: -20),
            animateDislikeButton.bottomAnchor.constraint(equalTo: animateLikeButton.bottomAnchor),
            animateDislikeButton.heightAnchor.constraint(equalTo: galleryScrollView.widthAnchor, multiplier: 0.15),
            animateDislikeButton.widthAnchor.constraint(equalTo: animateDislikeButton.heightAnchor),
        ])
        
        reportTopConstraint = reportButton.topAnchor.constraint(equalTo: desiresLabel.bottomAnchor, constant: 30)
        reportTopConstraint?.isActive = true
    }
}


